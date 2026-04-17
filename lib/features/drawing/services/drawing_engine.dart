import 'package:flutter/material.dart';

import '../model/drawing_point.dart';

class DrawingEngine {
  const DrawingEngine();

  DrawingStroke beginStroke({
    required Offset start,
    required Color color,
    required double strokeWidth,
  }) {
    return DrawingStroke(
      points: <Offset>[start],
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  DrawingStroke appendPoint({
    required DrawingStroke stroke,
    required Offset point,
  }) {
    return stroke.copyWith(
      points: <Offset>[
        ...stroke.points,
        point,
      ],
    );
  }
}
