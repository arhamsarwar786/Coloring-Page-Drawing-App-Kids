import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../drawing/model/color_model.dart';

enum RegionShapeType {
  circle,
  oval,
  polygon,
  path;

  static RegionShapeType fromString(String value) {
    switch (value) {
      case 'circle':
        return RegionShapeType.circle;
      case 'oval':
        return RegionShapeType.oval;
      case 'polygon':
        return RegionShapeType.polygon;
      case 'path':
        return RegionShapeType.path;
      default:
        return RegionShapeType.oval;
    }
  }
}

class LevelRegionModel {
  const LevelRegionModel({
    required this.id,
    required this.label,
    required this.shapeType,
    this.cx,
    this.cy,
    this.radius,
    this.rx,
    this.ry,
    this.svgPath,
    this.points = const <Offset>[],
  });

  final String id;
  final String label;
  final RegionShapeType shapeType;
  final double? cx;
  final double? cy;
  final double? radius;
  final double? rx;
  final double? ry;
  final String? svgPath;
  final List<Offset> points;

  factory LevelRegionModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = (json['points'] as List<dynamic>?)
            ?.map(
              (point) => Offset(
                ((point as List<dynamic>)[0] as num).toDouble(),
                (point[1] as num).toDouble(),
              ),
            )
            .toList() ??
        const <Offset>[];

    return LevelRegionModel(
      id: json['id'] as String,
      label: json['label'] as String,
      shapeType: RegionShapeType.fromString(json['type'] as String),
      cx: (json['cx'] as num?)?.toDouble(),
      cy: (json['cy'] as num?)?.toDouble(),
      radius: (json['radius'] as num?)?.toDouble(),
      rx: (json['rx'] as num?)?.toDouble(),
      ry: (json['ry'] as num?)?.toDouble(),
      svgPath: json['svgPath'] as String?,
      points: rawPoints,
    );
  }

  Path toPath(Size size) {
    switch (shapeType) {
      case RegionShapeType.circle:
        return Path()
          ..addOval(
            Rect.fromCircle(
              center:
                  Offset((cx ?? 0) * size.width, (cy ?? 0) * size.height),
              radius: (radius ?? 0) * size.shortestSide,
            ),
          );
      case RegionShapeType.oval:
        return Path()
          ..addOval(
            Rect.fromCenter(
              center:
                  Offset((cx ?? 0) * size.width, (cy ?? 0) * size.height),
              width: ((rx ?? 0) * 2) * size.width,
              height: ((ry ?? 0) * 2) * size.height,
            ),
          );
      case RegionShapeType.polygon:
        final path = Path();
        if (points.isEmpty) return path;
        path.moveTo(
          points.first.dx * size.width,
          points.first.dy * size.height,
        );
        for (final point in points.skip(1)) {
          path.lineTo(point.dx * size.width, point.dy * size.height);
        }
        path.close();
        return path;
      case RegionShapeType.path:
        if (svgPath == null) return Path();
        final rawPath = parseSvgPathData(svgPath!);
        // Assuming SVG coordinates are in 0-100 range
        final matrix = Matrix4.identity()
          ..scale(size.width / 100, size.height / 100);
        return rawPath.transform(matrix.storage);
    }
  }

  bool contains(Offset point, Size size) {
    return toPath(size).contains(point);
  }
}

class LevelModel {
  const LevelModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.rewardCoins,
    required this.recommendedBrushSize,
    required this.palette,
    required this.regions,
    this.guideAsset,
    this.isCompleted = false,
    this.stars = 0,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String difficulty;
  final int rewardCoins;
  final double recommendedBrushSize;
  final List<DrawingColorModel> palette;
  final List<LevelRegionModel> regions;
  final String? guideAsset;
  final bool isCompleted;
  final int stars;
  final bool isFavorite;

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      difficulty: json['difficulty'] as String,
      rewardCoins: json['rewardCoins'] as int,
      recommendedBrushSize:
          (json['recommendedBrushSize'] as num).toDouble(),
      guideAsset: json['guideAsset'] as String?,
      palette: (json['palette'] as List<dynamic>)
          .map((item) =>
              DrawingColorModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      regions: (json['regions'] as List<dynamic>)
          .map((item) =>
              LevelRegionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  LevelModel copyWith({bool? isCompleted, int? stars, bool? isFavorite}) {
    return LevelModel(
      id: id,
      title: title,
      subtitle: subtitle,
      difficulty: difficulty,
      rewardCoins: rewardCoins,
      recommendedBrushSize: recommendedBrushSize,
      palette: palette,
      regions: regions,
      guideAsset: guideAsset,
      isCompleted: isCompleted ?? this.isCompleted,
      stars: stars ?? this.stars,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Color get accentColor => palette.isNotEmpty ? palette.first.color : Colors.grey;

  String? getTargetColorIdForRegion(String regionId) {
    final regionName = regionId.toLowerCase();
    
    // Explicit color mapping based on region/level names to enforce strict coloring
    if (id == 'apple') {
      if (regionName.contains('body') || regionName.contains('shine')) return 'red';
      if (regionName.contains('leaf')) return 'green';
      if (regionName.contains('stem')) return 'brown';
    } else if (id == 'banana') {
      if (regionName.contains('body')) return 'yellow';
      if (regionName.contains('tip')) return 'brown';
    } else if (id == 'cat') {
      if (regionName.contains('face') || regionName.contains('ear_left') || regionName.contains('ear_right')) return 'orange';
      if (regionName.contains('inner') || regionName.contains('nose')) return 'pink';
      if (regionName.contains('muzzle')) return 'white';
    } else if (id == 'fish') {
      if (regionName.contains('body') || regionName.contains('tail')) return 'blue';
      if (regionName.contains('fin')) return 'orange';
      if (regionName.contains('eye')) return 'yellow';
    } else if (id == 'football') {
      if (regionName.contains('body')) return 'white';
      if (regionName.contains('patch')) return 'black';
    } else if (id == 'tennis') {
      if (regionName.contains('head') || regionName.contains('throat')) return 'blue';
      if (regionName.contains('handle') || regionName.contains('grip')) return 'gray';
    } else if (id == 'car') {
      if (regionName.contains('body') || regionName.contains('roof') || regionName.contains('taillight')) return 'red';
      if (regionName.contains('window')) return 'blue';
      if (regionName.contains('wheel')) return 'black';
      if (regionName.contains('headlight')) return 'gray';
    } else if (id == 'sunflower') {
      if (regionName.contains('petal')) return 'yellow';
      if (regionName.contains('center')) return 'brown';
      if (regionName.contains('stem')) return 'green';
    }

    // Fallback heuristic like before
    for (final p in palette) {
      if (regionName.contains(p.id.toLowerCase())) {
        return p.id;
      }
    }
    return null;
  }

  Color getTargetColorForRegion(String regionId) {
    final targetId = getTargetColorIdForRegion(regionId);
    if (targetId != null) {
      try {
        return palette.firstWhere((p) => p.id == targetId).color;
      } catch (_) {}
    }
    return Colors.grey.shade300;
  }
}
