import 'package:flutter/material.dart';

class DrawingPoint {
  const DrawingPoint({
    required this.offset,
  });

  final Offset offset;
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
}
