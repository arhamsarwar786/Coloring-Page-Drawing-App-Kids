import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../levels/model/level_model.dart';
import '../../../skins/model/skin_model.dart';
import '../../../skins/viewmodel/skins_viewmodel.dart';
import '../../model/drawing_point.dart';
import '../../model/drawing_session_snapshot.dart';
import '../../view/controllers/guided_painting_controllers.dart';
import '../../viewmodel/drawing_viewmodel.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({
    super.key,
    required this.level,
    required this.repaintBoundaryKey,
    this.guideAsset,
    required this.filledRegions,
    required this.onFill,
    this.enableColoring = true,
    this.onPhaseChanged,
    this.onRegionFilled,
    this.initialSnapshot,
    this.onSnapshotChanged,
    this.onPreviewStateChanged,
    this.onShowAgainButtonStateChanged,
  });
// final String? guideAsset;
  final LevelModel level;
  final GlobalKey repaintBoundaryKey;
  final String? guideAsset;
  final Map<String, Color> filledRegions;
  final Future<void> Function(String regionId) onFill;
  final bool enableColoring;
  final ValueChanged<GuidedCanvasPhase>? onPhaseChanged;
  final ValueChanged<String>? onRegionFilled;
  final DrawingSessionSnapshot? initialSnapshot;
  final ValueChanged<DrawingSessionSnapshot>? onSnapshotChanged;
  final ValueChanged<bool>? onPreviewStateChanged;
  final ValueChanged<bool>? onShowAgainButtonStateChanged;

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget>
    with TickerProviderStateMixin {
  final DrawingStepController _drawingStepController = DrawingStepController();
  final ColoringStepController _coloringStepController =
      ColoringStepController();
  final ActivePartHighlighter _activePartHighlighter =
      const ActivePartHighlighter();
  final ValueNotifier<Offset?> _markerPosition = ValueNotifier<Offset?>(null);
  final ValueNotifier<String?> _appreciationMessage =
      ValueNotifier<String?>(null);
  late final DrawingViewModel _drawingViewModel;
  Timer? _snapshotDebounce;

  late final GestureCoordinator _gestureCoordinator;
  late final AnimationController _outlineAnimationController;
  late final AnimationController _fillAnimationController;
  late final AnimationController _highlightPulseController;
  late final Animation<double> _highlightPulse;
  late final AnimationController _appreciationController;
  late final AnimationController _tapScaleController;
  late final Animation<double> _appreciationScale;
  late final Animation<Offset> _appreciationOffset;

  final Map<String, Path> _pathCache = <String, Path>{};
  final Map<String, Path> _paintPathCache = <String, Path>{};
  final Map<String, Path> _dashedPathCache = <String, Path>{};
  final Map<String, List<ui.PathMetric>> _metricsCache =
      <String, List<ui.PathMetric>>{};
  final Set<int> _activePointerIds = <int>{};
  Map<String, double> _activeOutlineRegionShares = <String, double>{};
  Size? _cachedCanvasSize;
  String? _activeRegionId;
  Color? _activeRegionOriginalColor;
  GuidedCanvasPhase? _lastReportedPhase;
  String? _markerAlignedRegionId;
  bool _showPreview = true;
  bool _showAgainButton = false;
  bool _showAgainUsed = false;
  String? _show3DMessage;
  bool _hasShownPenTutorial = false;
  bool _isPenTutorialOpening = false;
  Timer? _previewTimer;
  Timer? _message3DTimer;

  void _startPreviewTimer() {
    _previewTimer?.cancel();
    setState(() {
      _showPreview = true;
      _showAgainButton = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onPreviewStateChanged?.call(true);
      widget.onShowAgainButtonStateChanged?.call(false);
    });
    _previewTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      setState(() {
        _showPreview = false;
        if (!_showAgainUsed) {
          _showAgainButton = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            widget.onShowAgainButtonStateChanged?.call(true);
          });
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onPreviewStateChanged?.call(false);
      });
    });
  }

  void _handleShowAgain() {
    if (_showAgainUsed) return;
    setState(() {
      _showAgainUsed = true;
      _showAgainButton = false;
    });
    _startPreviewTimer();
  }

  // Public method to trigger show-again from parent widgets
  void showPreviewAgain() {
    _handleShowAgain();
  }

  void _show3DAppreciationMessage(String message) {
    _message3DTimer?.cancel();
    setState(() {
      _show3DMessage = message;
    });
    _appreciationController.reset();
    _appreciationController.forward();
    _message3DTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _show3DMessage = null;
        });
      }
    });
  }

  Future<void> _showPenTutorialDialogOnce({
    required String? markerAsset,
    required Color selectedColor,
  }) async {
    if (_hasShownPenTutorial || _isPenTutorialOpening) return;

    _hasShownPenTutorial = true;
    _isPenTutorialOpening = true;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Pen tutorial',
      barrierColor: Colors.black.withValues(alpha: 0.62),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _PenTutorialFullScreenDialog(
          level: widget.level,
          markerAsset: markerAsset ?? 'assets/images/marker.png',
          selectedColor: selectedColor,
          onClose: () => Navigator.of(dialogContext).maybePop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );

    _isPenTutorialOpening = false;
  }

  @override
  void initState() {
    super.initState();
    _gestureCoordinator = GestureCoordinator(
      drawingController: _drawingStepController,
      coloringController: _coloringStepController,
    );

    _startPreviewTimer();
    _drawingStepController.addListener(_notifyPhaseIfChanged);
    _coloringStepController.addListener(_notifyPhaseIfChanged);
    _drawingStepController.addListener(_scheduleSnapshotEmit);
    _coloringStepController.addListener(_scheduleSnapshotEmit);
    _outlineAnimationController = AnimationController(vsync: this)
      ..addListener(() {
        _drawingStepController.updateProgress(
          progress: _outlineAnimationController.value,
          regionShares: _activeOutlineRegionShares,
        );
        final regionId = _drawingStepController.animatingRegionId;
        if (regionId != null && _cachedCanvasSize != null) {
          final metrics = _metricsCache[regionId];
          if (metrics != null) {
            final progress = _drawingStepController.progressFor(regionId);
            for (final metric in metrics) {
              final tangent =
                  metric.getTangentForOffset(metric.length * progress);
              if (tangent != null) {
                _updateMarkerPosition(tangent.position);
              }
              break;
            }
          }
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _drawingStepController.finishCurrentPart();
          HapticFeedback.selectionClick();
        }
      });
    _fillAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _highlightPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _highlightPulse = CurvedAnimation(
      parent: _highlightPulseController,
      curve: Curves.easeInOut,
    );
    _appreciationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appreciationScale = CurvedAnimation(
      parent: _appreciationController,
      curve: Curves.elasticOut,
    );
    _appreciationOffset = Tween<Offset>(
      begin: const Offset(0.0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _appreciationController,
        curve: Curves.easeOutBack,
      ),
    );
    _tapScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 1.0,
      upperBound: 1.12,
    );
    _drawingViewModel = context.read<DrawingViewModel>();
    _drawingViewModel.brushSizeListenable.addListener(_handleBrushSizeChanged);
    _handleBrushSizeChanged();

    _configureControllers();
  }

  @override
  void didUpdateWidget(covariant CanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.level.id != widget.level.id) {
      _hasShownPenTutorial = false;
      _isPenTutorialOpening = false;
      _pathCache.clear();
      _paintPathCache.clear();
      _dashedPathCache.clear();
      _metricsCache.clear();
      _activeOutlineRegionShares = <String, double>{};
      _cachedCanvasSize = null;
      _markerPosition.value = null;
      _markerAlignedRegionId = null;
      _configureControllers();
    }

    if (!mapEquals(oldWidget.filledRegions, widget.filledRegions)) {
      _syncFilledRegions(oldWidget.filledRegions);
    }
  }

  @override
  void dispose() {
    _drawingStepController.removeListener(_notifyPhaseIfChanged);
    _coloringStepController.removeListener(_notifyPhaseIfChanged);
    _drawingStepController.removeListener(_scheduleSnapshotEmit);
    _coloringStepController.removeListener(_scheduleSnapshotEmit);
    _snapshotDebounce?.cancel();
    _previewTimer?.cancel();
    _message3DTimer?.cancel();
    _appreciationMessage.dispose();
    _markerPosition.dispose();
    _outlineAnimationController.dispose();
    _fillAnimationController.dispose();
    _highlightPulseController.dispose();
    _appreciationController.dispose();
    _tapScaleController.dispose();
    _drawingViewModel.brushSizeListenable
        .removeListener(_handleBrushSizeChanged);
    _drawingStepController.dispose();
    _coloringStepController.dispose();
    super.dispose();
  }

  void _handleBrushSizeChanged() {
    final brushSize = _drawingViewModel.brushSizeListenable.value;
    _coloringStepController.setBrushScale(brushSize.scale);
    _scheduleSnapshotEmit(immediate: true);
  }

  void _configureControllers() {
    _drawingStepController.configure(widget.level);
    _coloringStepController.configure(
      orderedRegionIds: _drawingStepController.orderedRegionIds,
      filledRegions: widget.filledRegions,
    );
    final initialSnapshot = widget.initialSnapshot;
    if (initialSnapshot != null) {
      _drawingStepController.restoreSnapshot(initialSnapshot.outline);
      _coloringStepController.restoreSnapshot(initialSnapshot.coloring);
    }
    _paintPathCache.clear();
    _markerAlignedRegionId = null;
    _notifyPhaseIfChanged();
    _scheduleSnapshotEmit(immediate: true);
  }

  void _syncFilledRegions(Map<String, Color> oldFilledRegions) {
    for (final entry in widget.filledRegions.entries) {
      if (oldFilledRegions[entry.key] != entry.value) {
        _activeRegionId = entry.key;
        _activeRegionOriginalColor = oldFilledRegions[entry.key] ?? entry.value;
        _fillAnimationController.forward(from: 0.0);
        break;
      }
    }

    _coloringStepController.syncFilledRegions(widget.filledRegions);
    _paintPathCache.clear();
    _notifyPhaseIfChanged();
    _scheduleSnapshotEmit();
  }

  void _scheduleSnapshotEmit({bool immediate = false}) {
    if (widget.onSnapshotChanged == null) return;

    _snapshotDebounce?.cancel();

    void emit() {
      if (!mounted) return;
      widget.onSnapshotChanged?.call(
        DrawingSessionSnapshot(
          filledRegions: widget.filledRegions.map(
            (key, value) => MapEntry<String, int>(key, value.toARGB32()),
          ),
          selectedColorId: _drawingViewModel.selectedColor?.id,
          brushSizeKey: _drawingViewModel.selectedBrushSize.name,
          outline: _drawingStepController.exportSnapshot(),
          coloring: _coloringStepController.exportSnapshot(),
        ),
      );
    }

    if (immediate) {
      emit();
    } else {
      _snapshotDebounce = Timer(const Duration(milliseconds: 250), emit);
    }
  }

  Offset _toLocal(
      Offset raw, BoxConstraints constraints, double canvasDimension) {
    return Offset(
      raw.dx - (constraints.maxWidth - canvasDimension) / 2,
      raw.dy - (constraints.maxHeight - canvasDimension) / 2,
    );
  }

  void _updateMarkerPosition(Offset localPosition) {
    _markerPosition.value = localPosition;
  }

  void _syncMarkerToDrawingPoint(Offset drawingPoint) {
    _updateMarkerPosition(drawingPoint);
  }

  Offset? _pathStartPoint(String regionId) {
    final metrics = _metricsCache[regionId];
    if (metrics != null && metrics.isNotEmpty) {
      return metrics.first.getTangentForOffset(0.0)?.position;
    }
    return null;
  }

  void _alignMarkerToCurrentOutlineStart(Size canvasSize) {
    if (_drawingStepController.phase != GuidedCanvasPhase.outline ||
        _drawingStepController.isAnimating) {
      return;
    }

    final regionId = _drawingStepController.currentRegionId;
    if (regionId == null || _markerAlignedRegionId == regionId) {
      return;
    }

    final startPoint = _pathStartPoint(regionId);
    if (startPoint == null) return;

    _markerAlignedRegionId = regionId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_drawingStepController.currentRegionId != regionId ||
          _drawingStepController.phase != GuidedCanvasPhase.outline ||
          _drawingStepController.isAnimating) {
        return;
      }
      _syncMarkerToDrawingPoint(startPoint);
    });
  }

  void _alignMarkerToCurrentColoringStart(Size canvasSize) {
    if (_gestureCoordinator.resolvePhase() != GuidedCanvasPhase.coloring ||
        _markerPosition.value != null) {
      return;
    }

    final activeRegionId = _coloringStepController.activeRegionId;
    if (activeRegionId == null) return;

    final regions = widget.level.regions.where((r) => r.id == activeRegionId);
    if (regions.isEmpty) return;

    final region = regions.first;
    final path = _pathFor(region.id, canvasSize);
    final bounds = path.getBounds();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateMarkerPosition(bounds.center);
    });
  }

  void _notifyPhaseIfChanged() {
    final phase = _gestureCoordinator.resolvePhase();
    if (_lastReportedPhase == phase) return;
    _lastReportedPhase = phase;
    widget.onPhaseChanged?.call(phase);
  }

  bool get _hasMultipleActivePointers => _activePointerIds.length > 1;

  void _handlePointerDown(PointerDownEvent event) {
    _activePointerIds.add(event.pointer);
    if (_hasMultipleActivePointers) {
      _outlineAnimationController.stop();
      _drawingStepController.pauseCurrentPart();
      _drawingStepController.handleFingerLift();
      _coloringStepController.handlePaintEnd();
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    _activePointerIds.remove(event.pointer);
  }

  Path _pathFor(String regionId, Size canvasSize) {
    if (_cachedCanvasSize != canvasSize) {
      _pathCache.clear();
      _paintPathCache.clear();
      _dashedPathCache.clear();
      _metricsCache.clear();
      _cachedCanvasSize = canvasSize;
    }

    return _pathCache.putIfAbsent(regionId, () {
      final region =
          widget.level.regions.firstWhere((item) => item.id == regionId);
      final path = region.toPath(canvasSize);

      final metrics = path.computeMetrics().toList();
      _metricsCache[regionId] = metrics;

      final dashedPath = Path();
      const dash = 10.0;
      const gap = 7.0;
      for (final metric in metrics) {
        double distance = 0;
        while (distance < metric.length) {
          final next = math.min(distance + dash, metric.length);
          dashedPath.addPath(metric.extractPath(distance, next), Offset.zero);
          distance += dash + gap;
        }
      }
      _dashedPathCache[regionId] = dashedPath;

      return path;
    });
  }

  Path _paintPathFor(String regionId, Size canvasSize) {
    if (_cachedCanvasSize != canvasSize) {
      _pathCache.clear();
      _paintPathCache.clear();
      _cachedCanvasSize = canvasSize;
    }

    return _paintPathCache.putIfAbsent(regionId, () {
      var paintPath = Path.from(_pathFor(regionId, canvasSize));
      final activeRegionId = _coloringStepController.activeRegionId;

      if (regionId != activeRegionId) {
        return paintPath;
      }

      final orderedRegionIds = _drawingStepController.orderedRegionIds;
      final activeIndex = orderedRegionIds.indexOf(regionId);
      if (activeIndex == -1) {
        return paintPath;
      }

      for (final candidateId in orderedRegionIds.skip(activeIndex + 1)) {
        if (_coloringStepController.filledRegionIds.contains(candidateId)) {
          continue;
        }

        final candidatePath = _pathFor(candidateId, canvasSize);
        if (!_shouldReserveNestedRegion(
          parentPath: paintPath,
          candidatePath: candidatePath,
        )) {
          continue;
        }

        final separatedPath = Path.combine(
          PathOperation.difference,
          paintPath,
          candidatePath,
        );
        if (!separatedPath.getBounds().isEmpty) {
          paintPath = separatedPath;
        }
      }

      return paintPath;
    });
  }

  bool _shouldReserveNestedRegion({
    required Path parentPath,
    required Path candidatePath,
  }) {
    final parentBounds = parentPath.getBounds();
    final candidateBounds = candidatePath.getBounds();
    if (parentBounds.isEmpty || candidateBounds.isEmpty) {
      return false;
    }

    if (!parentBounds.overlaps(candidateBounds)) {
      return false;
    }

    final samplePoints = <Offset>[
      candidateBounds.center,
      Offset(
        candidateBounds.left + (candidateBounds.width * 0.25),
        candidateBounds.top + (candidateBounds.height * 0.25),
      ),
      Offset(
        candidateBounds.right - (candidateBounds.width * 0.25),
        candidateBounds.top + (candidateBounds.height * 0.25),
      ),
      Offset(
        candidateBounds.left + (candidateBounds.width * 0.25),
        candidateBounds.bottom - (candidateBounds.height * 0.25),
      ),
      Offset(
        candidateBounds.right - (candidateBounds.width * 0.25),
        candidateBounds.bottom - (candidateBounds.height * 0.25),
      ),
    ];

    var nestedSampleCount = 0;
    for (final point in samplePoints) {
      if (candidatePath.contains(point) && parentPath.contains(point)) {
        nestedSampleCount += 1;
      }
    }

    return nestedSampleCount >= 2;
  }

  Map<String, double> _outlineSharesForPart(
    DrawingPartStep part,
    Size canvasSize,
  ) {
    final shares = <String, double>{};
    for (final regionId in part.regionIds) {
      double totalLength = 0.0;
      final metrics = _metricsCache[regionId] ??
          _pathFor(regionId, canvasSize).computeMetrics().toList();
      for (final metric in metrics) {
        totalLength += metric.length;
      }
      shares[regionId] = totalLength;
    }
    return shares;
  }

  Duration _durationForPart(DrawingPartStep part, Size canvasSize) {
    double totalLength = 0.0;
    for (final regionId in part.regionIds) {
      final metrics = _metricsCache[regionId] ??
          _pathFor(regionId, canvasSize).computeMetrics().toList();
      for (final metric in metrics) {
        totalLength += metric.length;
      }
    }

    final durationMs = (totalLength * 3.5).clamp(800.0, 4500.0).toInt();
    return Duration(milliseconds: durationMs);
  }

  Duration _remainingDurationForPart(DrawingPartStep part, Size canvasSize) {
    final total = _durationForPart(part, canvasSize);
    final remainingFactor =
        (1.0 - _drawingStepController.currentPartProgress).clamp(0.0, 1.0);
    final remainingMs =
        (total.inMilliseconds * remainingFactor).clamp(120.0, 2200.0).toInt();
    return Duration(milliseconds: remainingMs);
  }

  Future<void> _handleFillCompletion(
    String regionId,
    Color selectedColor,
  ) async {
    await widget.onFill(regionId);
    widget.onRegionFilled?.call(regionId);

    // Check for excellence/good-as-different message
    final drawingVm = _drawingViewModel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      drawingVm.checkExcellence();

      final allFilled =
          drawingVm.filledRegions.length == widget.level.regions.length;
      if (allFilled && _show3DMessage == null) {
        if (drawingVm.isExcellence) {
          _show3DAppreciationMessage('Excellence! +100');
        } else {
          _show3DAppreciationMessage('Good as Different');
        }
      }
    });
  }

  void _animateMarkerTap() {
    _tapScaleController.forward().then((_) {
      if (mounted) {
        _tapScaleController.reverse();
      }
    });
  }

  void _startOutlineSlideGesture({
    required Offset localPosition,
    required double canvasDimension,
  }) {
    if (!_gestureCoordinator.acceptsOutlineGestures) return;

    _updateMarkerPosition(localPosition);

    if (!_drawingStepController.beginCurrentPart()) {
      return;
    }

    final part = _drawingStepController.animatingPart;
    if (part == null) return;

    final canvasSize = Size.square(canvasDimension);
    _activeOutlineRegionShares = _outlineSharesForPart(part, canvasSize);
    _outlineAnimationController.duration =
        _remainingDurationForPart(part, canvasSize);
    _outlineAnimationController.forward(
      from: _drawingStepController.currentPartProgress,
    );
    _animateMarkerTap();
  }

  void _updateOutlineSlideGesture(Offset localPosition) {
    if (!_gestureCoordinator.acceptsOutlineGestures &&
        !_drawingStepController.isAnimating) {
      return;
    }

    _updateMarkerPosition(localPosition);
  }

  void _endOutlineSlideGesture() {
    _outlineAnimationController.stop();
    _drawingStepController.pauseCurrentPart();
    _drawingStepController.handleFingerLift();
  }

  void _onLongPressStart(
    LongPressStartDetails details,
    BoxConstraints constraints,
    double canvasDimension,
  ) {
    final local = _toLocal(details.localPosition, constraints, canvasDimension);
    _startOutlineSlideGesture(
      localPosition: local,
      canvasDimension: canvasDimension,
    );
  }

  void _onLongPressEnd() {
    _endOutlineSlideGesture();
  }

  void _onLongPressMoveUpdate(
    LongPressMoveUpdateDetails details,
    BoxConstraints constraints,
    double canvasDimension,
  ) {
    final local = _toLocal(details.localPosition, constraints, canvasDimension);
    _updateOutlineSlideGesture(local);
  }

  void _handleColorGesture({
    required Offset fingerLocal,
    required Size canvasSize,
    required Color selectedColor,
    required bool startStroke,
  }) {
    if (!widget.enableColoring) return;
    if (!_gestureCoordinator.acceptsColorGestures) return;

    final regionId = _coloringStepController.activeRegionId;
    if (regionId == null) return;

    final path = _paintPathFor(regionId, canvasSize);
    final drawingPoint = fingerLocal;
    _syncMarkerToDrawingPoint(drawingPoint);
    final paintedPoint = startStroke
        ? _coloringStepController.handlePaintStart(
            point: drawingPoint,
            path: path,
            color: selectedColor,
          )
        : _coloringStepController.handlePaintUpdate(
            point: drawingPoint,
            path: path,
            color: selectedColor,
          );

    if (paintedPoint != null && paintedPoint != drawingPoint) {
      _syncMarkerToDrawingPoint(paintedPoint);
    }
  }

  Future<void> _onColorGestureEnd(Color selectedColor) async {
    if (!widget.enableColoring) return;
    final completedRegionId = _coloringStepController.handlePaintEnd();
    if (completedRegionId != null) {
      await _handleFillCompletion(completedRegionId, selectedColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SkinsViewModel, DrawingViewModel>(
      builder: (context, skinsVm, drawingVm, _) {
        final selectedColor =
            drawingVm.selectedColor?.color ?? const Color(0xFF5C6BC0);
        final phase = _gestureCoordinator.resolvePhase();
        final isColoringActive =
            phase == GuidedCanvasPhase.coloring && widget.enableColoring;
        final markerTipColor = isColoringActive ? selectedColor : Colors.black;
        final activeColorRegionId = _coloringStepController.activeRegionId;
        final shouldShowColoringFade = isColoringActive &&
            activeColorRegionId != null &&
            !_coloringStepController.isPainting &&
            _coloringStepController.progressFor(activeColorRegionId) == 0.0;
        final repaintListenable = Listenable.merge(<Listenable>[
          _drawingStepController,
          _coloringStepController,
          _fillAnimationController,
        ]);

// return Container();

        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasDimension =
                  math.min(constraints.maxWidth, constraints.maxHeight);
              final canvasSize = Size.square(canvasDimension);
              final scaleFactor = canvasDimension / 300.0;
              final skin = skinsVm.selectedSkin;

              if (isColoringActive &&
                  !_hasShownPenTutorial &&
                  !_isPenTutorialOpening) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _showPenTutorialDialogOnce(
                    markerAsset: skin.image,
                    selectedColor: selectedColor,
                  );
                });
              }

              for (final region in widget.level.regions) {
                _pathFor(region.id, canvasSize);
                _paintPathFor(region.id, canvasSize);
              }
              _alignMarkerToCurrentOutlineStart(canvasSize);
              _alignMarkerToCurrentColoringStart(canvasSize);

              return Listener(
                onPointerDown: _handlePointerDown,
                onPointerUp: _handlePointerEnd,
                onPointerCancel: _handlePointerEnd,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPressStart: (details) {
                    if (_hasMultipleActivePointers) return;
                    _onLongPressStart(details, constraints, canvasDimension);
                  },
                  onLongPressMoveUpdate: (details) {
                    if (_hasMultipleActivePointers) return;
                    _onLongPressMoveUpdate(
                      details,
                      constraints,
                      canvasDimension,
                    );
                  },
                  onLongPressEnd: (_) {
                    if (_hasMultipleActivePointers) return;
                    _onLongPressEnd();
                  },
                  onPanStart: (details) {
                    if (_hasMultipleActivePointers) return;
                    final local = _toLocal(
                      details.localPosition,
                      constraints,
                      canvasDimension,
                    );
                    if (_gestureCoordinator.acceptsOutlineGestures) {
                      _startOutlineSlideGesture(
                        localPosition: local,
                        canvasDimension: canvasDimension,
                      );
                      return;
                    }

                    _animateMarkerTap();
                    _handleColorGesture(
                      fingerLocal: local,
                      canvasSize: canvasSize,
                      selectedColor: selectedColor,
                      startStroke: true,
                    );
                  },
                  onPanUpdate: (details) {
                    if (_hasMultipleActivePointers) return;
                    final local = _toLocal(
                      details.localPosition,
                      constraints,
                      canvasDimension,
                    );
                    if (_gestureCoordinator.acceptsOutlineGestures ||
                        _drawingStepController.isAnimating) {
                      _updateOutlineSlideGesture(local);
                      return;
                    }

                    _handleColorGesture(
                      fingerLocal: local,
                      canvasSize: canvasSize,
                      selectedColor: selectedColor,
                      startStroke: false,
                    );
                  },
                  onPanEnd: (_) {
                    if (_hasMultipleActivePointers) return;
                    if (_gestureCoordinator.acceptsOutlineGestures ||
                        _drawingStepController.isAnimating) {
                      _endOutlineSlideGesture();
                      return;
                    }

                    _onColorGestureEnd(selectedColor);
                  },
                  onPanCancel: () {
                    if (_hasMultipleActivePointers) return;
                    if (_gestureCoordinator.acceptsOutlineGestures ||
                        _drawingStepController.isAnimating) {
                      _endOutlineSlideGesture();
                      return;
                    }

                    _onColorGestureEnd(selectedColor);
                  },
                  child: Center(
                    child: Container(
                      width: canvasDimension,
                      height: canvasDimension,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          // if (widget.guideAsset != null)
                          //   Positioned.fill(
                          //     child: Opacity(
                          //       opacity: 0.2,
                          //       child: Image.asset(
                          //         widget.guideAsset!,
                          //         fit: BoxFit.contain,
                          //       ),
                          //     ),
                          //   ),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: RepaintBoundary(
                              key: widget.repaintBoundaryKey,
                              child: CustomPaint(
                                painter: AdvancedCanvasPainter(
                                  level: widget.level,
                                  paths: _pathCache,
                                  paintPaths: _paintPathCache,
                                  dashedPaths: _dashedPathCache,
                                  metricsCache: _metricsCache,
                                  filledRegions: widget.filledRegions,
                                  drawingController: _drawingStepController,
                                  coloringController: _coloringStepController,
                                  activePartHighlighter: _activePartHighlighter,
                                  fillAnimationValue:
                                      _fillAnimationController.value,
                                  activeFillRegionId: _activeRegionId,
                                  activeFillRegionOriginalColor:
                                      _activeRegionOriginalColor,
                                  repaint: repaintListenable,
                                ),
                                size: canvasSize,
                              ),
                            ),
                          ),

                          if (_showPreview && widget.guideAsset != null)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Opacity(
                                  opacity: 0.25,
                                  child: Image.asset(
                                    widget.guideAsset!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                          if (shouldShowColoringFade)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: FadeTransition(
                                  opacity: _highlightPulse,
                                  child: CustomPaint(
                                    painter: _ColoringHighlightOverlayPainter(
                                      activeRegionId: activeColorRegionId,
                                      paths: _pathCache,
                                      activePartHighlighter:
                                          _activePartHighlighter,
                                    ),
                                    size: canvasSize,
                                  ),
                                ),
                              ),
                            ),
                          ValueListenableBuilder<String?>(
                            valueListenable: _appreciationMessage,
                            builder: (context, message, _) {
                              if (message == null) {
                                return const SizedBox.shrink();
                              }

                              return Positioned(
                                left: 0,
                                right: 0,
                                bottom: -74 * scaleFactor,
                                child: SlideTransition(
                                  position: _appreciationOffset,
                                  child: ScaleTransition(
                                    scale: _appreciationScale,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24 * scaleFactor,
                                        vertical: 14 * scaleFactor,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            20 * scaleFactor),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: selectedColor.withValues(
                                                alpha: 0.4),
                                            blurRadius: 28 * scaleFactor,
                                            spreadRadius: 2 * scaleFactor,
                                          ),
                                        ],
                                        border: Border.all(
                                          color: selectedColor.withValues(
                                              alpha: 0.7),
                                          width: 2.5 * scaleFactor,
                                        ),
                                      ),
                                      child: Text(
                                        message,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 28 * scaleFactor,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF333333),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // 3D Appreciation message (Excellence / Good as Different)
                          if (_show3DMessage != null)
                            Positioned.fill(
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: _appreciationController,
                                  builder: (context, child) {
                                    final scale = 0.5 +
                                        0.5 * _appreciationController.value;
                                    final opacity =
                                        _appreciationController.value;
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..scale(scale, scale, 1.0)
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateX(0.2 * (1 - opacity)),
                                      child: Opacity(
                                        opacity: opacity,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 48 * scaleFactor,
                                            vertical: 28 * scaleFactor,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.25),
                                                blurRadius: 32,
                                                spreadRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _show3DMessage!.split('!')[0] +
                                                    '!',
                                                style: TextStyle(
                                                  fontSize: 52 * scaleFactor,
                                                  fontWeight: FontWeight.bold,
                                                  color: _show3DMessage!
                                                          .contains(
                                                              'Excellence')
                                                      ? Colors.amber.shade700
                                                      : Colors.blue.shade600,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 8,
                                                      offset: Offset(2, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_show3DMessage!
                                                  .contains('Excellence'))
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 12 * scaleFactor),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                          Icons.monetization_on,
                                                          color: Colors
                                                              .amber.shade700,
                                                          size:
                                                              32 * scaleFactor),
                                                      SizedBox(
                                                          width:
                                                              8 * scaleFactor),
                                                      Text(
                                                        '+100',
                                                        style: TextStyle(
                                                          fontSize:
                                                              36 * scaleFactor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .amber.shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          _MarkerOverlay(
                            markerPosition: _markerPosition,
                            tapScaleController: _tapScaleController,
                            skin: skin,
                            tipColor: markerTipColor,
                            canvasDimension: canvasDimension,
                            scaleFactor: scaleFactor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PenTutorialFullScreenDialog extends StatefulWidget {
  const _PenTutorialFullScreenDialog({
    required this.level,
    required this.markerAsset,
    required this.selectedColor,
    required this.onClose,
  });

  final LevelModel level;
  final String markerAsset;
  final Color selectedColor;
  final VoidCallback onClose;

  @override
  State<_PenTutorialFullScreenDialog> createState() =>
      _PenTutorialFullScreenDialogState();
}

class _PenTutorialFullScreenDialogState
    extends State<_PenTutorialFullScreenDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Colors.black.withValues(alpha: 0.48),
              const Color(0xFF16213A).withValues(alpha: 0.50),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.filled(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF242424),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.26),
                              blurRadius: 32,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              widget.level.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF242424),
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Flexible(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: _PenTutorialStage(
                                  level: widget.level,
                                  markerAsset: widget.markerAsset,
                                  selectedColor: widget.selectedColor,
                                  animation: _controller,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: widget.onClose,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2BBF5B),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PenTutorialStage extends StatelessWidget {
  const _PenTutorialStage({
    required this.level,
    required this.markerAsset,
    required this.selectedColor,
    required this.animation,
  });

  final LevelModel level;
  final String markerAsset;
  final Color selectedColor;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = math.min(constraints.maxWidth, constraints.maxHeight);
        final canvasSize = Size.square(dimension);
        final markerSize = dimension * 0.42;

        return Center(
          child: SizedBox(
            width: dimension,
            height: dimension,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final progress = Curves.easeInOut.transform(animation.value);
                final markerPosition = _markerPositionFor(canvasSize, progress);

                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFEFB),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFE7EDF5),
                            width: 2,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _PenTutorialPainter(
                            level: level,
                            selectedColor: selectedColor,
                            progress: progress,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: markerPosition.dx - (markerSize * 0.18),
                      top: markerPosition.dy - (markerSize * 0.78),
                      child: Transform.rotate(
                        angle: -0.72,
                        child: Image.asset(
                          markerAsset,
                          width: markerSize,
                          height: markerSize,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.low,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/marker.png',
                            width: markerSize,
                            height: markerSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Offset _markerPositionFor(Size size, double progress) {
    if (level.regions.isEmpty) {
      return Offset(size.width * 0.55, size.height * 0.56);
    }

    final objectSize = size.shortestSide * 0.82;
    final objectOffset = Offset(
      (size.width - objectSize) / 2,
      (size.height - objectSize) / 2,
    );
    final regionCount = level.regions.length;
    final rawIndex =
        (progress * regionCount).clamp(0.0, regionCount - 0.001).toDouble();
    final activeIndex = rawIndex.floor().clamp(0, regionCount - 1).toInt();
    final localProgress = rawIndex - activeIndex;
    final path = level.regions[activeIndex]
        .toPath(Size.square(objectSize))
        .shift(objectOffset);
    final bounds = path.getBounds();

    if (bounds.isEmpty) {
      return Offset(size.width * 0.55, size.height * 0.56);
    }

    final x = bounds.left + (bounds.width * (0.20 + (0.58 * localProgress)));
    final wave = math.sin(localProgress * math.pi * 2);
    final y = bounds.center.dy + (wave * bounds.height * 0.18);
    return Offset(x, y);
  }
}

class _PenTutorialPainter extends CustomPainter {
  const _PenTutorialPainter({
    required this.level,
    required this.selectedColor,
    required this.progress,
  });

  final LevelModel level;
  final Color selectedColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color(0xFFFFFEFB)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    if (level.regions.isEmpty) return;

    final objectSize = size.shortestSide * 0.82;
    final objectOffset = Offset(
      (size.width - objectSize) / 2,
      (size.height - objectSize) / 2,
    );
    final scaledSize = Size.square(objectSize);
    final regionCount = level.regions.length;
    final fillCursor = progress * regionCount;

    for (var index = 0; index < regionCount; index++) {
      final region = level.regions[index];
      final path = region.toPath(scaledSize).shift(objectOffset);
      final bounds = path.getBounds();
      if (bounds.isEmpty) continue;

      final targetColor = _targetColorFor(region.id);
      final regionProgress = (fillCursor - index).clamp(0.0, 1.0).toDouble();

      if (regionProgress > 0) {
        canvas.save();
        canvas.clipPath(path);

        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true
          ..shader = LinearGradient(
            colors: <Color>[
              targetColor.withValues(alpha: 0.74),
              targetColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);

        final fillRect = Rect.fromLTWH(
          bounds.left - (bounds.width * 0.08),
          bounds.top - (bounds.height * 0.12),
          (bounds.width * 1.18) * regionProgress,
          bounds.height * 1.24,
        );
        canvas.drawRect(fillRect, fillPaint);

        final strokePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = size.shortestSide * 0.035
          ..color = targetColor.withValues(alpha: 0.88)
          ..isAntiAlias = true;
        final strokeEnd =
            bounds.left + ((bounds.width * 1.05) * regionProgress);
        for (var stroke = 0; stroke < 5; stroke++) {
          final y = bounds.top + (bounds.height * (0.22 + (stroke * 0.14)));
          canvas.drawLine(
            Offset(bounds.left + (bounds.width * 0.06), y),
            Offset(strokeEnd, y - (bounds.height * 0.06)),
            strokePaint,
          );
        }

        canvas.restore();
      }

      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.0105
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.black
          ..isAntiAlias = true,
      );
    }
  }

  Color _targetColorFor(String regionId) {
    final targetColor = level.getTargetColorForRegion(regionId);
    if (targetColor == Colors.grey.shade300) {
      return selectedColor;
    }
    return targetColor;
  }

  @override
  bool shouldRepaint(covariant _PenTutorialPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.selectedColor != selectedColor ||
        oldDelegate.progress != progress;
  }
}

class _MarkerOverlay extends StatelessWidget {
  const _MarkerOverlay({
    required this.markerPosition,
    required this.tapScaleController,
    required this.skin,
    required this.tipColor,
    required this.canvasDimension,
    required this.scaleFactor,
  });

  final ValueNotifier<Offset?> markerPosition;
  final AnimationController tapScaleController;
  final SkinModel skin;
  final Color tipColor;
  final double canvasDimension;
  final double scaleFactor;

  double get _tipX => 28 * scaleFactor;
  double get _tipY => 150 * scaleFactor;
  double get _markerSize => 180 * scaleFactor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge(<Listenable>[markerPosition, tapScaleController]),
      child: RepaintBoundary(
        child: SizedBox(
          width: _markerSize,
          height: _markerSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              if (skin.image != null)
                Image.asset(
                  skin.image!,
                  width: _markerSize,
                  height: _markerSize,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.low,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              Positioned(
                left: _tipX - (10 * scaleFactor),
                top: _tipY - (29 * scaleFactor),
                child: CustomPaint(
                  painter: const _NibPainter(color: Colors.transparent),
                  size: Size(20 * scaleFactor, 22 * scaleFactor),
                ),
              ),
            ],
          ),
        ),
      ),
      builder: (context, child) {
        final position = markerPosition.value;
        final effectiveTipX = skin.face ? _tipX : _markerSize * 0.1;
        final effectiveTipY = skin.face ? _tipY : _markerSize * 0.78;
        final left =
            position != null ? position.dx - effectiveTipX : -effectiveTipX;
        final top = position != null
            ? position.dy - effectiveTipY
            : canvasDimension - effectiveTipY;
        return IgnorePointer(
          child: Transform.translate(
            offset: Offset(left, top),
            child: Transform.scale(
              scale: tapScaleController.value,
              alignment: Alignment.bottomLeft,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _NibPainter extends CustomPainter {
  const _NibPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final outlinePaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.18, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.1,
        size.height * 0.16,
        size.width * 0.36,
        size.height * 0.06,
      )
      ..lineTo(size.width * 0.64, size.height * 0.06)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.16,
        size.width * 0.82,
        size.height * 0.42,
      )
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.22), 2, false);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.16),
      Offset(size.width * 0.5, size.height * 0.86),
      Paint()
        ..color = Colors.transparent
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.32),
        width: size.width * 0.18,
        height: size.height * 0.14,
      ),
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _NibPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class AdvancedCanvasPainter extends CustomPainter {
  AdvancedCanvasPainter({
    required this.level,
    required this.paths,
    required this.paintPaths,
    required this.dashedPaths,
    required this.metricsCache,
    required this.filledRegions,
    required this.drawingController,
    required this.coloringController,
    required this.activePartHighlighter,
    required this.fillAnimationValue,
    required this.activeFillRegionId,
    required this.activeFillRegionOriginalColor,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final LevelModel level;
  final Map<String, Path> paths;
  final Map<String, Path> paintPaths;
  final Map<String, Path> dashedPaths;
  final Map<String, List<ui.PathMetric>> metricsCache;
  final Map<String, Color> filledRegions;
  final DrawingStepController drawingController;
  final ColoringStepController coloringController;
  final ActivePartHighlighter activePartHighlighter;
  final double fillAnimationValue;
  final String? activeFillRegionId;
  final Color? activeFillRegionOriginalColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFFEFB),
    );

    final guideOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.009
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFD1D1D1);

    final solidOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.0105
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black;

    for (final region in level.regions) {
      final path = paths[region.id] ?? region.toPath(size);
      final paintPath = paintPaths[region.id] ?? path;
      final filledColor = filledRegions[region.id];
      final outlineProgress = drawingController.progressFor(region.id);
      final isOutlineCompleted = drawingController.isRegionCompleted(region.id);
      final isCurrentOutlineRegion =
          drawingController.isRegionCurrent(region.id);
      final coloredStrokes = coloringController.strokesFor(region.id);

      if (filledColor != null) {
        _paintFilledRegion(canvas, paintPath, region.id, filledColor);
      } else if (coloredStrokes.isNotEmpty) {
        _paintRegionStrokes(canvas, paintPath, coloredStrokes);
      }

      if (isOutlineCompleted) {
        canvas.drawPath(path, solidOutline);
      } else if (outlineProgress > 0) {
        final dashedPath = dashedPaths[region.id];
        if (dashedPath != null) canvas.drawPath(dashedPath, guideOutline);
        _drawPartialOutline(
          canvas,
          metricsCache[region.id] ?? path.computeMetrics().toList(),
          outlineProgress,
          size,
          level.getTargetColorForRegion(region.id),
        );
      } else {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(0x00FFFFFF),
        );
        final dashedPath = dashedPaths[region.id];
        if (dashedPath != null) canvas.drawPath(dashedPath, guideOutline);
      }

      if (drawingController.phase == GuidedCanvasPhase.outline &&
          isCurrentOutlineRegion &&
          !isOutlineCompleted) {
        activePartHighlighter.paintOutlineHighlight(canvas, path, size);
      }
    }
  }

  void _paintFilledRegion(
    Canvas canvas,
    Path path,
    String regionId,
    Color color,
  ) {
    canvas.drawShadow(path, Colors.black, 3, true);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (regionId == activeFillRegionId) {
      final from = activeFillRegionOriginalColor ?? const Color(0x00FFFFFF);
      paint.color = Color.lerp(from, color, fillAnimationValue)!;
    } else {
      paint.color = color;
    }

    paint.shader = LinearGradient(
      colors: <Color>[paint.color.withValues(alpha: 0.82), paint.color],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(path.getBounds());

    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.black26,
    );
  }

  void _paintRegionStrokes(
    Canvas canvas,
    Path path,
    List<DrawingStroke> strokes,
  ) {
    canvas.save();
    canvas.clipPath(path);

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = stroke.strokeWidth * 3
        ..color = stroke.color
        ..isAntiAlias = true;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }

      canvas.drawPoints(ui.PointMode.polygon, stroke.points, paint);
    }

    canvas.restore();
  }

  void _drawPartialOutline(
    Canvas canvas,
    List<ui.PathMetric> metrics,
    double progress,
    Size size,
    Color color,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.0105
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black
      ..isAntiAlias = true;

    for (final metric in metrics) {
      final end = metric.length * progress;
      if (end > 0) {
        canvas.drawPath(metric.extractPath(0, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AdvancedCanvasPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.filledRegions != filledRegions ||
        oldDelegate.fillAnimationValue != fillAnimationValue ||
        oldDelegate.activeFillRegionId != activeFillRegionId ||
        oldDelegate.activeFillRegionOriginalColor !=
            activeFillRegionOriginalColor;
  }
}

class _ColoringHighlightOverlayPainter extends CustomPainter {
  const _ColoringHighlightOverlayPainter({
    required this.activeRegionId,
    required this.paths,
    required this.activePartHighlighter,
  });

  final String? activeRegionId;
  final Map<String, Path> paths;
  final ActivePartHighlighter activePartHighlighter;

  @override
  void paint(Canvas canvas, Size size) {
    final regionId = activeRegionId;
    if (regionId == null) return;

    final path = paths[regionId];
    if (path == null) return;

    activePartHighlighter.paintColoringHighlight(canvas, path, size);
  }

  @override
  bool shouldRepaint(covariant _ColoringHighlightOverlayPainter oldDelegate) {
    return oldDelegate.activeRegionId != activeRegionId ||
        oldDelegate.paths != paths ||
        oldDelegate.activePartHighlighter != activePartHighlighter;
  }
}
