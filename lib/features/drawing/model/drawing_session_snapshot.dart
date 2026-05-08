import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'drawing_point.dart';

class DrawingSessionSnapshot {
  const DrawingSessionSnapshot({
    required this.filledRegions,
    required this.selectedColorId,
    required this.brushSizeKey,
    required this.outline,
    required this.coloring,
  });

  final Map<String, int> filledRegions;
  final String? selectedColorId;
  final String brushSizeKey;
  final DrawingStepSnapshot outline;
  final ColoringStepSnapshot coloring;

  bool get hasVisibleProgress =>
      filledRegions.isNotEmpty ||
      outline.hasProgress ||
      coloring.hasProgress ||
      coloring.coloredStrokes.isNotEmpty;

  double progressForRegionCount(int regionCount) {
    if (regionCount <= 0) return 0.0;

    final outlineProgress = outline.progressForRegionCount(regionCount);
    final coloringProgress = coloring.progressForRegionCount(regionCount);
    final combined = (outlineProgress * 0.5) + (coloringProgress * 0.5);
    return combined.clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'filledRegions': filledRegions.map(
        (key, value) => MapEntry<String, dynamic>(key, value),
      ),
      'selectedColorId': selectedColorId,
      'brushSizeKey': brushSizeKey,
      'outline': outline.toJson(),
      'coloring': coloring.toJson(),
    };
  }

  factory DrawingSessionSnapshot.fromJson(Map<String, dynamic> json) {
    final filledMap = json['filledRegions'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    return DrawingSessionSnapshot(
      filledRegions: filledMap.map(
        (key, value) => MapEntry<String, int>(key, (value as num).toInt()),
      ),
      selectedColorId: json['selectedColorId'] as String?,
      brushSizeKey: json['brushSizeKey'] as String? ?? 'standard',
      outline: DrawingStepSnapshot.fromJson(
        json['outline'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      coloring: ColoringStepSnapshot.fromJson(
        json['coloring'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class DrawingStepSnapshot {
  const DrawingStepSnapshot({
    required this.completedPartIds,
    required this.completedRegionIds,
    required this.regionProgress,
    required this.currentIndex,
    required this.currentPartProgress,
  });

  final List<String> completedPartIds;
  final List<String> completedRegionIds;
  final Map<String, double> regionProgress;
  final int currentIndex;
  final double currentPartProgress;

  bool get hasProgress =>
      completedPartIds.isNotEmpty ||
      completedRegionIds.isNotEmpty ||
      currentPartProgress > 0 ||
      regionProgress.values.any((value) => value > 0);

  double progressForRegionCount(int regionCount) {
    if (regionCount <= 0) return 0.0;
    final normalizedCount = math.max(regionCount, 1);
    final completedRegionSet = completedRegionIds.toSet();
    double partialProgress = 0.0;
    for (final entry in regionProgress.entries) {
      if (completedRegionSet.contains(entry.key)) {
        continue;
      }
      partialProgress += entry.value.clamp(0.0, 1.0);
    }
    final total = completedRegionIds.length + partialProgress;
    return (total / normalizedCount).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'completedPartIds': completedPartIds,
      'completedRegionIds': completedRegionIds,
      'regionProgress': regionProgress.map(
        (key, value) => MapEntry<String, dynamic>(key, value),
      ),
      'currentIndex': currentIndex,
      'currentPartProgress': currentPartProgress,
    };
  }

  factory DrawingStepSnapshot.fromJson(Map<String, dynamic> json) {
    final regionProgressMap = json['regionProgress'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    return DrawingStepSnapshot(
      completedPartIds: (json['completedPartIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      completedRegionIds:
          (json['completedRegionIds'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(growable: false),
      regionProgress: regionProgressMap.map(
        (key, value) =>
            MapEntry<String, double>(key, (value as num).toDouble()),
      ),
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      currentPartProgress:
          (json['currentPartProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ColoringStepSnapshot {
  const ColoringStepSnapshot({
    required this.filledRegionIds,
    required this.fillProgress,
    required this.coverableCells,
    required this.paintedCells,
    required this.coloredStrokes,
    required this.activeRegionId,
    required this.pendingCompletedRegionId,
  });

  final List<String> filledRegionIds;
  final Map<String, double> fillProgress;
  final Map<String, List<String>> coverableCells;
  final Map<String, List<String>> paintedCells;
  final Map<String, List<DrawingStroke>> coloredStrokes;
  final String? activeRegionId;
  final String? pendingCompletedRegionId;

  bool get hasProgress =>
      filledRegionIds.isNotEmpty ||
      fillProgress.values.any((value) => value > 0) ||
      paintedCells.values.any((value) => value.isNotEmpty);

  double progressForRegionCount(int regionCount) {
    if (regionCount <= 0) return 0.0;
    final filledCount = filledRegionIds.length;
    final partialProgress = fillProgress.entries
        .where((entry) => !filledRegionIds.contains(entry.key))
        .fold<double>(
          0.0,
          (sum, entry) => sum + entry.value.clamp(0.0, 1.0),
        );
    return ((filledCount + partialProgress) / regionCount).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'filledRegionIds': filledRegionIds,
      'fillProgress': fillProgress.map(
        (key, value) => MapEntry<String, dynamic>(key, value),
      ),
      'coverableCells': coverableCells.map(
        (key, value) => MapEntry<String, dynamic>(key, value),
      ),
      'paintedCells': paintedCells.map(
        (key, value) => MapEntry<String, dynamic>(key, value),
      ),
      'coloredStrokes': coloredStrokes.map(
        (key, value) => MapEntry<String, dynamic>(
          key,
          value.map((stroke) => stroke.toJson()).toList(growable: false),
        ),
      ),
      'activeRegionId': activeRegionId,
      'pendingCompletedRegionId': pendingCompletedRegionId,
    };
  }

  factory ColoringStepSnapshot.fromJson(Map<String, dynamic> json) {
    final fillProgressMap = json['fillProgress'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final coverableCellsMap = json['coverableCells'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final paintedCellsMap = json['paintedCells'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final coloredStrokesMap = json['coloredStrokes'] as Map<String, dynamic>? ??
        const <String, dynamic>{};

    return ColoringStepSnapshot(
      filledRegionIds: (json['filledRegionIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      fillProgress: fillProgressMap.map(
        (key, value) =>
            MapEntry<String, double>(key, (value as num).toDouble()),
      ),
      coverableCells: coverableCellsMap.map(
        (key, value) => MapEntry<String, List<String>>(
          key,
          (value as List<dynamic>).whereType<String>().toList(growable: false),
        ),
      ),
      paintedCells: paintedCellsMap.map(
        (key, value) => MapEntry<String, List<String>>(
          key,
          (value as List<dynamic>).whereType<String>().toList(growable: false),
        ),
      ),
      coloredStrokes: coloredStrokesMap.map(
        (key, value) => MapEntry<String, List<DrawingStroke>>(
          key,
          ((value as List<dynamic>))
              .whereType<Map>()
              .map(
                (item) => DrawingStroke.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false),
        ),
      ),
      activeRegionId: json['activeRegionId'] as String?,
      pendingCompletedRegionId: json['pendingCompletedRegionId'] as String?,
    );
  }
}
