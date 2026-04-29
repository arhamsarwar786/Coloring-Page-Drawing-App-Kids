import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/drawing_point.dart';
import '../../../levels/model/level_model.dart';

enum GuidedCanvasPhase { outline, coloring, completed }

@immutable
class DrawingPartStep {
  const DrawingPartStep({
    required this.id,
    required this.label,
    required this.regionIds,
    required this.priority,
    required this.originalIndex,
  });

  final String id;
  final String label;
  final List<String> regionIds;
  final int priority;
  final int originalIndex;
}

class DrawingStepController extends ChangeNotifier {
  List<DrawingPartStep> _parts = <DrawingPartStep>[];
  final Set<String> _completedPartIds = <String>{};
  final Set<String> _completedRegionIds = <String>{};
  final Map<String, double> _regionProgress = <String, double>{};
  DrawingPartStep? _animatingPart;
  int _currentIndex = 0;
  double _currentPartProgress = 0.0;
  bool _pointerReleased = true;
  bool _awaitingFingerLift = false;

  GuidedCanvasPhase get phase {
    if (!isOutlineComplete) return GuidedCanvasPhase.outline;
    return GuidedCanvasPhase.coloring;
  }

  bool get isOutlineComplete =>
      _parts.isNotEmpty &&
      _completedPartIds.length >= _parts.length &&
      _animatingPart == null &&
      !_awaitingFingerLift;

  bool get isAnimating => _animatingPart != null;
  bool get isWaitingForFingerLift => _awaitingFingerLift;
  bool get hasCurrentPart => currentPart != null;
  double get currentPartProgress => _currentPartProgress;
  DrawingPartStep? get animatingPart => _animatingPart;
  DrawingPartStep? get currentPart =>
      _currentIndex < _parts.length ? _parts[_currentIndex] : null;
  String? get currentRegionId => currentPart?.regionIds.isNotEmpty == true
      ? currentPart!.regionIds.first
      : null;
  String? get animatingRegionId {
    if (_animatingPart == null) return null;
    for (final regionId in _animatingPart!.regionIds) {
      final prog = _regionProgress[regionId] ?? 0.0;
      if (prog > 0.0 && prog < 1.0) return regionId;
    }
    return _animatingPart!.regionIds.isNotEmpty
        ? _animatingPart!.regionIds.first
        : null;
  }

  List<String> get orderedRegionIds => List<String>.unmodifiable(
        _parts.expand((part) => part.regionIds).toList(growable: false),
      );

  void configure(LevelModel level) {
    _parts = _buildParts(level);
    _completedPartIds.clear();
    _completedRegionIds.clear();
    _regionProgress.clear();
    _animatingPart = null;
    _currentIndex = 0;
    _currentPartProgress = 0.0;
    _pointerReleased = true;
    _awaitingFingerLift = false;
    notifyListeners();
  }

  bool isRegionCompleted(String regionId) =>
      _completedRegionIds.contains(regionId);

  bool isRegionCurrent(String regionId) {
    final activePart = _animatingPart ?? currentPart;
    return activePart?.regionIds.contains(regionId) ?? false;
  }

  bool isPartRegion(String regionId, DrawingPartStep? part) =>
      part?.regionIds.contains(regionId) ?? false;

  double progressFor(String regionId) {
    if (_completedRegionIds.contains(regionId)) return 1.0;
    return _regionProgress[regionId] ?? 0.0;
  }

  bool beginCurrentPart() {
    if (!hasCurrentPart || isAnimating || _awaitingFingerLift) {
      return false;
    }

    _pointerReleased = false;
    _animatingPart = currentPart;
    if (_currentPartProgress <= 0.0) {
      for (final regionId in _animatingPart!.regionIds) {
        _regionProgress[regionId] = 0.0;
      }
    }
    notifyListeners();
    return true;
  }

  void updateProgress({
    required double progress,
    required Map<String, double> regionShares,
  }) {
    final animatingPart = _animatingPart;
    if (animatingPart == null) return;

    final clamped = progress.clamp(0.0, 1.0);
    _currentPartProgress = clamped;
    final normalized = _normalizeShares(animatingPart.regionIds, regionShares);
    double lowerBound = 0.0;

    for (final regionId in animatingPart.regionIds) {
      final share = normalized[regionId] ?? 0.0;
      final upperBound = lowerBound + share;

      if (share <= 0) {
        _regionProgress[regionId] = clamped >= 1.0 ? 1.0 : 0.0;
      } else if (clamped <= lowerBound) {
        _regionProgress[regionId] = 0.0;
      } else if (clamped >= upperBound) {
        _regionProgress[regionId] = 1.0;
      } else {
        _regionProgress[regionId] =
            ((clamped - lowerBound) / share).clamp(0.0, 1.0);
      }

      lowerBound = upperBound;
    }

    notifyListeners();
  }

  void pauseCurrentPart() {
    if (_animatingPart == null || _awaitingFingerLift) return;
    _animatingPart = null;
    _pointerReleased = true;
    notifyListeners();
  }

  void finishCurrentPart() {
    final part = _animatingPart;
    if (part == null) return;

    _completedPartIds.add(part.id);
    for (final regionId in part.regionIds) {
      _completedRegionIds.add(regionId);
      _regionProgress[regionId] = 1.0;
    }
    _animatingPart = null;
    _currentPartProgress = 1.0;

    if (_pointerReleased) {
      _advanceQueue();
    } else {
      _awaitingFingerLift = true;
    }

    notifyListeners();
  }

  void handleFingerLift() {
    _pointerReleased = true;
    if (_awaitingFingerLift) {
      _advanceQueue();
      notifyListeners();
    }
  }

  Map<String, double> _normalizeShares(
    List<String> regionIds,
    Map<String, double> shares,
  ) {
    double total = 0.0;
    for (final regionId in regionIds) {
      total += math.max(0.0, shares[regionId] ?? 0.0);
    }

    if (total <= 0) {
      final fallbackShare = 1.0 / regionIds.length;
      return Map<String, double>.fromEntries(
        regionIds.map((regionId) => MapEntry<String, double>(
              regionId,
              fallbackShare,
            )),
      );
    }

    return Map<String, double>.fromEntries(
      regionIds.map((regionId) => MapEntry<String, double>(
            regionId,
            math.max(0.0, shares[regionId] ?? 0.0) / total,
          )),
    );
  }

  void _advanceQueue() {
    _awaitingFingerLift = false;
    if (_currentIndex < _parts.length) {
      _currentIndex += 1;
    }
    _currentPartProgress = 0.0;
  }

  List<DrawingPartStep> _buildParts(LevelModel level) {
    final grouped = <String, _GroupedStepBuilder>{};

    for (final entry in level.regions.indexed) {
      final index = entry.$1;
      final region = entry.$2;
      final blueprint = _blueprintForRegion(region, index);
      grouped
          .putIfAbsent(
            blueprint.id,
            () => _GroupedStepBuilder(
              id: blueprint.id,
              label: blueprint.label,
              priority: blueprint.priority,
              originalIndex: index,
            ),
          )
          .regionIds
          .add(region.id);
    }

    final parts = grouped.values
        .map(
          (builder) => DrawingPartStep(
            id: builder.id,
            label: builder.label,
            regionIds: List<String>.unmodifiable(builder.regionIds),
            priority: builder.priority,
            originalIndex: builder.originalIndex,
          ),
        )
        .toList()
      ..sort((a, b) {
        final priorityCompare = a.priority.compareTo(b.priority);
        if (priorityCompare != 0) return priorityCompare;
        return a.originalIndex.compareTo(b.originalIndex);
      });

    return parts;
  }

  _PartBlueprint _blueprintForRegion(LevelRegionModel region, int index) {
    final key = '${region.id} ${region.label}'.toLowerCase();

    if (_containsAny(key, <String>['body', 'base', 'main', 'center', 'face'])) {
      return _PartBlueprint(
        id: _containsAny(key, <String>['roof']) ? 'main_body' : 'main_core',
        label: 'Main Shape',
        priority: 0,
      );
    }
    if (_containsAny(key, <String>['roof'])) {
      return const _PartBlueprint(
        id: 'main_body',
        label: 'Main Body',
        priority: 0,
      );
    }
    if (_containsAny(key, <String>['petal'])) {
      return const _PartBlueprint(
        id: 'petals',
        label: 'Petals',
        priority: 1,
      );
    }
    if (_containsAny(key, <String>['ear']) &&
        !_containsAny(key, <String>['inner'])) {
      return const _PartBlueprint(
        id: 'outer_ears',
        label: 'Outer Ears',
        priority: 1,
      );
    }
    if (_containsAny(key, <String>['inner'])) {
      return const _PartBlueprint(
        id: 'inner_details',
        label: 'Inner Details',
        priority: 2,
      );
    }
    if (_containsAny(key, <String>['leaf'])) {
      return const _PartBlueprint(
        id: 'leaves',
        label: 'Leaves',
        priority: 1,
      );
    }
    if (_containsAny(key, <String>['tail'])) {
      return const _PartBlueprint(
        id: 'tail',
        label: 'Tail',
        priority: 1,
      );
    }
    if (_containsAny(key, <String>['fin'])) {
      return const _PartBlueprint(
        id: 'fins',
        label: 'Fins',
        priority: 1,
      );
    }
    if (_containsAny(key, <String>['window'])) {
      return const _PartBlueprint(
        id: 'windows',
        label: 'Windows',
        priority: 1,
      );
    }
    if (_containsAny(key, <String>['wheel'])) {
      return const _PartBlueprint(
        id: 'wheels',
        label: 'Wheels',
        priority: 2,
      );
    }
    if (_containsAny(key, <String>['patch'])) {
      return _containsAny(key, <String>['center'])
          ? const _PartBlueprint(
              id: 'patch_center',
              label: 'Center Patch',
              priority: 1,
            )
          : const _PartBlueprint(
              id: 'patches',
              label: 'Decorative Patches',
              priority: 2,
            );
    }
    if (_containsAny(key, <String>['tip', 'stem', 'throat', 'handle'])) {
      return const _PartBlueprint(
        id: 'support_parts',
        label: 'Support Parts',
        priority: 2,
      );
    }
    if (_containsAny(key, <String>['grip', 'headlight', 'taillight', 'eye'])) {
      return const _PartBlueprint(
        id: 'detail_parts',
        label: 'Details',
        priority: 3,
      );
    }
    if (_containsAny(key, <String>['nose', 'muzzle'])) {
      return const _PartBlueprint(
        id: 'face_details',
        label: 'Face Details',
        priority: 3,
      );
    }

    return _PartBlueprint(
      id: 'region_$index',
      label: region.label,
      priority: 4,
    );
  }

  bool _containsAny(String value, List<String> tokens) {
    for (final token in tokens) {
      if (value.contains(token)) return true;
    }
    return false;
  }
}

class ColoringStepController extends ChangeNotifier {
  ColoringStepController({
    this.cellSize = 5.0,
    this.brushRadius = 18.0,
    this.completionThreshold = 0.94,
  });

  static const double _strokeWidthMultiplier = 2.8;
  static const double _renderStrokeWidthScale = 3.0;
  static const double _interpolationSpacingFactor = 0.3;
  static const double _motionSmoothingFactor = 0.94;

  final double cellSize;
  final double brushRadius;
  final double completionThreshold;
  List<String> _orderedRegionIds = <String>[];
  Set<String> _filledRegionIds = <String>{};
  final Map<String, double> _fillProgress = <String, double>{};
  final Map<String, Set<String>> _coverableCells = <String, Set<String>>{};
  final Map<String, Set<String>> _paintedCells = <String, Set<String>>{};
  final Map<String, List<DrawingStroke>> _coloredStrokes =
      <String, List<DrawingStroke>>{};
  String? _activeRegionId;
  String? _pendingCompletedRegionId;
  Color? _activePaintColor;
  bool _isPainting = false;
  Offset? _lastPaintPoint;

  String? get activeRegionId => _activeRegionId;
  Color? get activePaintColor => _activePaintColor;
  bool get hasActiveRegion => _activeRegionId != null;
  bool get isPainting => _isPainting;
  Offset? get lastPaintPoint => _lastPaintPoint;
  double get _storedStrokeWidth => brushRadius * _strokeWidthMultiplier;
  double get _effectiveCoverageRadius =>
      (_storedStrokeWidth * _renderStrokeWidthScale) / 2;
  UnmodifiableSetView<String> get filledRegionIds =>
      UnmodifiableSetView<String>(_filledRegionIds);

  void configure({
    required List<String> orderedRegionIds,
    required Map<String, Color> filledRegions,
  }) {
    _orderedRegionIds = List<String>.from(orderedRegionIds);
    _fillProgress.clear();
    _coverableCells.clear();
    _paintedCells.clear();
    _coloredStrokes.clear();
    _activePaintColor = null;
    _pendingCompletedRegionId = null;
    _isPainting = false;
    _lastPaintPoint = null;
    syncFilledRegions(filledRegions);
  }

  void syncFilledRegions(Map<String, Color> filledRegions) {
    final removedRegionIds =
        _filledRegionIds.difference(filledRegions.keys.toSet());
    _filledRegionIds = filledRegions.keys.toSet();

    for (final regionId in removedRegionIds) {
      _fillProgress.remove(regionId);
      _paintedCells.remove(regionId);
      _coverableCells.remove(regionId);
      _coloredStrokes.remove(regionId);
    }

    final nextIndex = _orderedRegionIds.indexWhere(
      (regionId) => !_filledRegionIds.contains(regionId),
    );
    _activeRegionId = nextIndex == -1 ? null : _orderedRegionIds[nextIndex];

    if (_activeRegionId == null) {
      _activePaintColor = null;
      _pendingCompletedRegionId = null;
      _isPainting = false;
      _lastPaintPoint = null;
    }

    notifyListeners();
  }

  double progressFor(String regionId) => _fillProgress[regionId] ?? 0.0;
  List<DrawingStroke> strokesFor(String regionId) =>
      _coloredStrokes[regionId] ?? const <DrawingStroke>[];

  Offset? handlePaintStart({
    required Offset point,
    required Path path,
    required Color color,
  }) {
    final regionId = _activeRegionId;
    if (regionId == null) return null;

    final startPoint = _resolvePaintablePoint(point, path);

    _isPainting = true;
    _lastPaintPoint = startPoint;
    _activePaintColor = color;
    _pendingCompletedRegionId = null;

    final strokes = _coloredStrokes.putIfAbsent(
      regionId,
      () => <DrawingStroke>[],
    );
    strokes.add(
      DrawingStroke(
        points: <Offset>[startPoint],
        color: color,
        strokeWidth: _storedStrokeWidth,
      ),
    );

    _registerCoverage(
      regionId: regionId,
      path: path,
      points: <Offset>[startPoint],
    );
    notifyListeners();
    return startPoint;
  }

  Offset? handlePaintUpdate({
    required Offset point,
    required Path path,
    required Color color,
  }) {
    final regionId = _activeRegionId;
    if (regionId == null) {
      return null;
    }

    if (!_isPainting || _lastPaintPoint == null) {
      return handlePaintStart(point: point, path: path, color: color);
    }

    _activePaintColor = color;
    final smoothedPoint = _smoothTargetPoint(_lastPaintPoint!, point);
    final targetPoint = _resolvePaintablePoint(smoothedPoint, path);
    final interpolatedPoints =
        _interpolatePoints(_lastPaintPoint!, targetPoint);
    var acceptedPoints = interpolatedPoints
        .where((candidate) => path.contains(candidate))
        .toList(growable: false);

    if (acceptedPoints.isEmpty) {
      final recoveredPoint = _resolvePaintablePoint(point, path);
      acceptedPoints = <Offset>[recoveredPoint];
    }

    final strokes = _coloredStrokes.putIfAbsent(
      regionId,
      () => <DrawingStroke>[],
    );
    if (strokes.isEmpty) {
      strokes.add(
        DrawingStroke(
          points: acceptedPoints,
          color: color,
          strokeWidth: _storedStrokeWidth,
        ),
      );
    } else {
      strokes.last.points.addAll(acceptedPoints);
    }

    _lastPaintPoint = acceptedPoints.last;
    _registerCoverage(
      regionId: regionId,
      path: path,
      points: acceptedPoints,
    );
    notifyListeners();
    return _lastPaintPoint;
  }

  String? handlePaintEnd() {
    if (!_isPainting) {
      return _finalizeActiveRegionIfReady();
    }

    _isPainting = false;
    _lastPaintPoint = null;
    final completedRegionId = _finalizeActiveRegionIfReady();
    notifyListeners();
    return completedRegionId;
  }

  void _completeRegion(String regionId) {
    _fillProgress.remove(regionId);
    _filledRegionIds = <String>{..._filledRegionIds, regionId};
    _pendingCompletedRegionId = null;
    _isPainting = false;
    _lastPaintPoint = null;

    final nextIndex = _orderedRegionIds.indexWhere(
      (candidate) => !_filledRegionIds.contains(candidate),
    );
    _activeRegionId = nextIndex == -1 ? null : _orderedRegionIds[nextIndex];
    if (_activeRegionId == null) {
      _activePaintColor = null;
    }
  }

  String? _finalizeActiveRegionIfReady() {
    final regionId = _activeRegionId;
    if (regionId == null) return null;

    final isPendingRegion = _pendingCompletedRegionId == regionId;
    if (!isPendingRegion && !_isRegionCovered(regionId)) {
      return null;
    }

    _completeRegion(regionId);
    return regionId;
  }

  void _registerCoverage({
    required String regionId,
    required Path path,
    required List<Offset> points,
  }) {
    final coverable = _coverableCells.putIfAbsent(
      regionId,
      () => _buildCoverableCells(path),
    );
    final painted = _paintedCells.putIfAbsent(regionId, () => <String>{});
    final coverageRadius = _effectiveCoverageRadius;

    for (final point in points) {
      final minX = ((point.dx - coverageRadius) / cellSize).floor();
      final maxX = ((point.dx + coverageRadius) / cellSize).floor();
      final minY = ((point.dy - coverageRadius) / cellSize).floor();
      final maxY = ((point.dy + coverageRadius) / cellSize).floor();

      for (int gx = minX; gx <= maxX; gx += 1) {
        for (int gy = minY; gy <= maxY; gy += 1) {
          final key = '$gx,$gy';
          if (!coverable.contains(key)) continue;

          final cellCenter = Offset(
            (gx * cellSize) + cellSize / 2,
            (gy * cellSize) + cellSize / 2,
          );
          if ((cellCenter - point).distance <= coverageRadius) {
            painted.add(key);
          }
        }
      }
    }

    final coverage =
        coverable.isEmpty ? 0.0 : painted.length / coverable.length;
    _fillProgress[regionId] = coverage.clamp(0.0, 1.0);

    if (_isRegionCovered(regionId)) {
      _pendingCompletedRegionId = regionId;
    }
  }

  bool _isRegionCovered(String regionId) {
    final progress = _fillProgress[regionId] ?? 0.0;
    final coverableCellCount = _coverableCells[regionId]?.length ?? 0;
    final requiredThreshold =
        _completionThresholdForCellCount(coverableCellCount);
    return progress >= requiredThreshold;
  }

  double _completionThresholdForCellCount(int cellCount) {
    if (cellCount <= 4) return 0.55;
    if (cellCount <= 8) return 0.68;
    if (cellCount <= 16) return 0.78;
    if (cellCount <= 28) return 0.86;
    return completionThreshold;
  }

  Set<String> _buildCoverableCells(Path path) {
    final cells = <String>{};
    final bounds = path.getBounds();

    for (double x = bounds.left; x < bounds.right; x += cellSize) {
      for (double y = bounds.top; y < bounds.bottom; y += cellSize) {
        final probe = Offset(x + cellSize / 2, y + cellSize / 2);
        if (path.contains(probe)) {
          cells.add(_cellKey(probe));
        }
      }
    }

    if (cells.isEmpty && !bounds.isEmpty) {
      cells.add(_cellKey(bounds.center));
    }

    return cells;
  }

  List<Offset> _interpolatePoints(Offset start, Offset end) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) return <Offset>[end];

    final spacing = _effectiveCoverageRadius * _interpolationSpacingFactor;
    final steps = math.max(1, (distance / spacing).ceil());
    return List<Offset>.generate(
      steps,
      (index) {
        final t = (index + 1) / steps;
        return Offset.lerp(start, end, t)!;
      },
      growable: false,
    );
  }

  Offset _smoothTargetPoint(Offset start, Offset rawTarget) {
    if (start == rawTarget) return rawTarget;
    return Offset.lerp(start, rawTarget, _motionSmoothingFactor)!;
  }

  Offset _resolvePaintablePoint(Offset point, Path path) {
    if (path.contains(point)) return point;

    Offset? nearestPoint;
    double minDistance = double.infinity;

    for (final metric in path.computeMetrics()) {
      const samples = 100;
      final step = metric.length / samples;
      for (int i = 0; i <= samples; i++) {
        final pos = metric.getTangentForOffset(i * step)?.position;
        if (pos != null) {
          final dist = (pos - point).distanceSquared;
          if (dist < minDistance) {
            minDistance = dist;
            nearestPoint = pos;
          }
        }
      }
    }

    return nearestPoint ?? point;
  }

  String _cellKey(Offset point) {
    final gx = (point.dx / cellSize).floor();
    final gy = (point.dy / cellSize).floor();
    return '$gx,$gy';
  }
}

class GestureCoordinator {
  GestureCoordinator({
    required this.drawingController,
    required this.coloringController,
  });

  final DrawingStepController drawingController;
  final ColoringStepController coloringController;

  GuidedCanvasPhase resolvePhase() {
    if (!drawingController.isOutlineComplete) {
      return GuidedCanvasPhase.outline;
    }
    if (coloringController.hasActiveRegion) {
      return GuidedCanvasPhase.coloring;
    }
    return GuidedCanvasPhase.completed;
  }

  bool get acceptsOutlineGestures =>
      resolvePhase() == GuidedCanvasPhase.outline &&
      !drawingController.isAnimating;

  bool get acceptsColorGestures => resolvePhase() == GuidedCanvasPhase.coloring;
}

class ActivePartHighlighter {
  const ActivePartHighlighter();

  void paintOutlineHighlight(Canvas canvas, Path path, Size size) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.018
        ..color = const Color(0x66FFB74D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void paintColoringHighlight(Canvas canvas, Path path, Size size) {
    final strokeWidth = size.shortestSide * 0.016;
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0x30FFB74D)
        ..isAntiAlias = true,
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.9
        ..color = const Color(0x61FFC46B)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
        ..isAntiAlias = true,
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = const Color(0xF2FF9800)
        ..isAntiAlias = true,
    );
  }
}

class _GroupedStepBuilder {
  _GroupedStepBuilder({
    required this.id,
    required this.label,
    required this.priority,
    required this.originalIndex,
  });

  final String id;
  final String label;
  final int priority;
  final int originalIndex;
  final List<String> regionIds = <String>[];
}

@immutable
class _PartBlueprint {
  const _PartBlueprint({
    required this.id,
    required this.label,
    required this.priority,
  });

  final String id;
  final String label;
  final int priority;
}
