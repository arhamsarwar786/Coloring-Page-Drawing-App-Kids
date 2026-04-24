import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../levels/model/level_model.dart';
import '../../../skins/model/skin_model.dart';
import '../../../skins/viewmodel/skins_viewmodel.dart';
import '../../model/drawing_point.dart';
import '../../view/controllers/guided_painting_controllers.dart';
import '../../viewmodel/drawing_viewmodel.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({
    super.key,
    required this.level,
    this.guideAsset,
    required this.filledRegions,
    required this.onFill,
    this.enableColoring = true,
    this.onPhaseChanged,
    this.onRegionFilled,
  });

  final LevelModel level;
  final String? guideAsset;
  final Map<String, Color> filledRegions;
  final Future<void> Function(String regionId) onFill;
  final bool enableColoring;
  final ValueChanged<GuidedCanvasPhase>? onPhaseChanged;
  final ValueChanged<String>? onRegionFilled;

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

  late final GestureCoordinator _gestureCoordinator;
  late final AnimationController _outlineAnimationController;
  late final AnimationController _fillAnimationController;
  late final AnimationController _appreciationController;
  late final AnimationController _tapScaleController;
  late final Animation<double> _appreciationScale;
  late final Animation<Offset> _appreciationOffset;

  final Map<String, Path> _pathCache = <String, Path>{};
  final Map<String, Path> _paintPathCache = <String, Path>{};
  Map<String, double> _activeOutlineRegionShares = <String, double>{};
  Size? _cachedCanvasSize;
  String? _activeRegionId;
  Color? _activeRegionOriginalColor;
  GuidedCanvasPhase? _lastReportedPhase;

  static const List<String> _appreciationMessages = <String>[
    'Great Job!',
    'Awesome!',
    'Super!',
    'Brilliant!',
    'Well Done!',
    'Perfect!',
  ];

  @override
  void initState() {
    super.initState();
    _gestureCoordinator = GestureCoordinator(
      drawingController: _drawingStepController,
      coloringController: _coloringStepController,
    );
    _drawingStepController.addListener(_notifyPhaseIfChanged);
    _coloringStepController.addListener(_notifyPhaseIfChanged);
    _outlineAnimationController = AnimationController(vsync: this)
      ..addListener(() {
        _drawingStepController.updateProgress(
          progress: _outlineAnimationController.value,
          regionShares: _activeOutlineRegionShares,
        );
        final regionId = _drawingStepController.animatingRegionId;
        if (regionId != null && _cachedCanvasSize != null) {
          final path = _pathCache[regionId];
          if (path != null) {
            final progress = _drawingStepController.progressFor(regionId);
            for (final metric in path.computeMetrics()) {
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

    _configureControllers();
  }

  @override
  void didUpdateWidget(covariant CanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.level.id != widget.level.id) {
      _pathCache.clear();
      _paintPathCache.clear();
      _activeOutlineRegionShares = <String, double>{};
      _cachedCanvasSize = null;
      _markerPosition.value = null;
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
    _appreciationMessage.dispose();
    _markerPosition.dispose();
    _outlineAnimationController.dispose();
    _fillAnimationController.dispose();
    _appreciationController.dispose();
    _tapScaleController.dispose();
    _drawingStepController.dispose();
    _coloringStepController.dispose();
    super.dispose();
  }

  void _configureControllers() {
    _drawingStepController.configure(widget.level);
    _coloringStepController.configure(
      orderedRegionIds: _drawingStepController.orderedRegionIds,
      filledRegions: widget.filledRegions,
    );
    _paintPathCache.clear();
    _notifyPhaseIfChanged();
  }

  void _syncFilledRegions(Map<String, Color> oldFilledRegions) {
    for (final entry in widget.filledRegions.entries) {
      if (oldFilledRegions[entry.key] != entry.value) {
        _activeRegionId = entry.key;
        _activeRegionOriginalColor =
            oldFilledRegions[entry.key] ?? const Color(0x00FFFFFF);
        _fillAnimationController.forward(from: 0.0);
        break;
      }
    }

    _coloringStepController.syncFilledRegions(widget.filledRegions);
    _paintPathCache.clear();
    _notifyPhaseIfChanged();
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

  void _notifyPhaseIfChanged() {
    final phase = _gestureCoordinator.resolvePhase();
    if (_lastReportedPhase == phase) return;
    _lastReportedPhase = phase;
    widget.onPhaseChanged?.call(phase);
  }

  Path _pathFor(String regionId, Size canvasSize) {
    if (_cachedCanvasSize != canvasSize) {
      _pathCache.clear();
      _paintPathCache.clear();
      _cachedCanvasSize = canvasSize;
    }

    return _pathCache.putIfAbsent(regionId, () {
      final region =
          widget.level.regions.firstWhere((item) => item.id == regionId);
      return region.toPath(canvasSize);
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
      for (final metric in _pathFor(regionId, canvasSize).computeMetrics()) {
        totalLength += metric.length;
      }
      shares[regionId] = totalLength;
    }
    return shares;
  }

  Duration _durationForPart(DrawingPartStep part, Size canvasSize) {
    double totalLength = 0.0;
    for (final regionId in part.regionIds) {
      for (final metric in _pathFor(regionId, canvasSize).computeMetrics()) {
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
      String regionId, Color selectedColor) async {
    await widget.onFill(regionId);
    _triggerAppreciation(selectedColor);
    widget.onRegionFilled?.call(regionId);
  }

  void _triggerAppreciation(Color color) {
    final randomIndex = math.Random().nextInt(_appreciationMessages.length);
    _appreciationMessage.value = _appreciationMessages[randomIndex];
    _appreciationController.forward(from: 0.0);
    HapticFeedback.mediumImpact();

    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      _appreciationController.reverse().then((_) {
        if (mounted && _appreciationController.value == 0.0) {
          _appreciationMessage.value = null;
        }
      });
    });
  }

  void _animateMarkerTap() {
    _tapScaleController.forward().then((_) {
      if (mounted) {
        _tapScaleController.reverse();
      }
    });
  }

  void _onLongPressStart(
    LongPressStartDetails details,
    BoxConstraints constraints,
    double canvasDimension,
  ) {
    if (!_gestureCoordinator.acceptsOutlineGestures) return;

    final local = _toLocal(details.localPosition, constraints, canvasDimension);
    _updateMarkerPosition(local);

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

  void _onLongPressEnd() {
    _outlineAnimationController.stop();
    _drawingStepController.pauseCurrentPart();
    _drawingStepController.handleFingerLift();
  }

  void _onLongPressMoveUpdate(
    LongPressMoveUpdateDetails details,
    BoxConstraints constraints,
    double canvasDimension,
  ) {
    if (!_gestureCoordinator.acceptsOutlineGestures &&
        !_drawingStepController.isAnimating) {
      return;
    }

    final local = _toLocal(details.localPosition, constraints, canvasDimension);
    _updateMarkerPosition(local);
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
        final markerTipColor =
            isColoringActive ? selectedColor : Colors.black;
        final repaintListenable = Listenable.merge(<Listenable>[
          _drawingStepController,
          _coloringStepController,
          _fillAnimationController,
        ]);

        return LayoutBuilder(
          builder: (context, constraints) {
            final canvasDimension =
                math.min(constraints.maxWidth, constraints.maxHeight);
            final canvasSize = Size.square(canvasDimension);
            final skin = skinsVm.selectedSkin;

            for (final region in widget.level.regions) {
              _pathFor(region.id, canvasSize);
              _paintPathFor(region.id, canvasSize);
            }

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPressStart: (details) =>
                  _onLongPressStart(details, constraints, canvasDimension),
              onLongPressMoveUpdate: (details) => _onLongPressMoveUpdate(
                details,
                constraints,
                canvasDimension,
              ),
              onLongPressEnd: (_) => _onLongPressEnd(),
              onPanStart: (details) {
                final local = _toLocal(
                  details.localPosition,
                  constraints,
                  canvasDimension,
                );
                _animateMarkerTap();
                _handleColorGesture(
                  fingerLocal: local,
                  canvasSize: canvasSize,
                  selectedColor: selectedColor,
                  startStroke: true,
                );
              },
              onPanUpdate: (details) {
                final local = _toLocal(
                  details.localPosition,
                  constraints,
                  canvasDimension,
                );
                _handleColorGesture(
                  fingerLocal: local,
                  canvasSize: canvasSize,
                  selectedColor: selectedColor,
                  startStroke: false,
                );
              },
              onPanEnd: (_) => _onColorGestureEnd(selectedColor),
              onPanCancel: () => _onColorGestureEnd(selectedColor),
              child: Center(
                child: Container(
                  width: canvasDimension,
                  height: canvasDimension,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                      width: 2,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: AdvancedCanvasPainter(
                              level: widget.level,
                              paths: _pathCache,
                              paintPaths: _paintPathCache,
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
                      ValueListenableBuilder<String?>(
                        valueListenable: _appreciationMessage,
                        builder: (context, message, _) {
                          if (message == null) {
                            return const SizedBox.shrink();
                          }

                          return Positioned(
                            left: 0,
                            right: 0,
                            bottom: -74,
                            child: SlideTransition(
                              position: _appreciationOffset,
                              child: ScaleTransition(
                                scale: _appreciationScale,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: selectedColor.withValues(
                                            alpha: 0.4),
                                        blurRadius: 28,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    border: Border.all(
                                      color:
                                          selectedColor.withValues(alpha: 0.7),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: Text(
                                    message,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      _MarkerOverlay(
                        markerPosition: _markerPosition,
                        tapScaleController: _tapScaleController,
                        skin: skin,
                        tipColor: markerTipColor,
                        canvasDimension: canvasDimension,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MarkerOverlay extends StatelessWidget {
  const _MarkerOverlay({
    required this.markerPosition,
    required this.tapScaleController,
    required this.skin,
    required this.tipColor,
    required this.canvasDimension,
  });

  final ValueNotifier<Offset?> markerPosition;
  final AnimationController tapScaleController;
  final SkinModel skin;
  final Color tipColor;
  final double canvasDimension;

  static const double _tipX = 28;
  static const double _tipY = 150;
  static const double _markerSize = 180;

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
                left: _tipX - 10,
                top: _tipY - 29,
                child: CustomPaint(
                  painter: _NibPainter(color: Colors.transparent),
                  size: const Size(20, 22),
                ),
              ),
            ],
          ),
        ),
      ),
      builder: (context, child) {
        final position = markerPosition.value;
        final left = position != null ? position.dx - _tipX : -_tipX;
        final top =
            position != null ? position.dy - _tipY : canvasDimension - _tipY;
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
      ..strokeWidth = size.shortestSide * 0.01
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFD1D1D1);

    final solidOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.013
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black26;

    for (final region in level.regions) {
      final path = paths[region.id] ?? region.toPath(size);
      final paintPath = paintPaths[region.id] ?? path;
      final filledColor = filledRegions[region.id];
      final outlineProgress = drawingController.progressFor(region.id);
      final isOutlineCompleted = drawingController.isRegionCompleted(region.id);
      final isCurrentOutlineRegion =
          drawingController.isRegionCurrent(region.id);
      final isActiveColorRegion =
          coloringController.activeRegionId == region.id;
      final coloredStrokes = coloringController.strokesFor(region.id);

      if (filledColor != null) {
        _paintFilledRegion(canvas, paintPath, region.id, filledColor);
      } else if (coloredStrokes.isNotEmpty) {
        _paintRegionStrokes(canvas, paintPath, coloredStrokes);
      }

      if (isOutlineCompleted) {
        canvas.drawPath(path, solidOutline);
      } else if (outlineProgress > 0) {
        _drawDashedPath(canvas, path, guideOutline);
        _drawPartialOutline(
          canvas,
          path,
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
        _drawDashedPath(canvas, path, guideOutline);
      }

      if (drawingController.phase == GuidedCanvasPhase.outline &&
          isCurrentOutlineRegion &&
          !isOutlineCompleted) {
        activePartHighlighter.paintOutlineHighlight(canvas, path, size);
      }

      if (drawingController.isOutlineComplete && isActiveColorRegion) {
        activePartHighlighter.paintColoringHighlight(canvas, path, size);
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
        ..strokeWidth = stroke.strokeWidth
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

      final strokePath = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        strokePath.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(strokePath, paint);
    }

    canvas.restore();
  }

  void _drawPartialOutline(
    Canvas canvas,
    Path path,
    double progress,
    Size size,
    Color color,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.024
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    for (final metric in path.computeMetrics()) {
      final end = metric.length * progress;
      if (end > 0) {
        canvas.drawPath(metric.extractPath(0, end), paint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path source, Paint paint) {
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      const dash = 10.0;
      const gap = 7.0;

      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
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
