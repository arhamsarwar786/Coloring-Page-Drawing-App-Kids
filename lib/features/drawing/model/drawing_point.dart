import 'package:flutter/material.dart';

class DrawingPoint {
  const DrawingPoint({
    required this.offset,
  });

  final Offset offset;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dx': offset.dx,
      'dy': offset.dy,
    };
  }

  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    return DrawingPoint(
      offset: Offset(
        (json['dx'] as num?)?.toDouble() ?? 0.0,
        (json['dy'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }
}

class DrawingStroke {
  const DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawingStroke copyWith({
    List<Offset>? points,
  }) {
    return DrawingStroke(
      points: points ?? this.points,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'points': points
          .map(
            (point) => <String, dynamic>{
              'dx': point.dx,
              'dy': point.dy,
            },
          )
          .toList(growable: false),
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
    };
  }

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>? ?? const <dynamic>[];
    return DrawingStroke(
      points: rawPoints
          .whereType<Map>()
          .map(
            (point) => Offset(
              ((point['dx'] as num?) ?? 0).toDouble(),
              ((point['dy'] as num?) ?? 0).toDouble(),
            ),
          )
          .toList(growable: true),
      color: Color((json['color'] as num?)?.toInt() ?? 0xFF000000),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
