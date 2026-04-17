import 'package:flutter/material.dart';

enum DrawingActionType {
  stroke,
  fill,
}

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

class DrawingAction {
  const DrawingAction.stroke({
    required this.stroke,
  })  : type = DrawingActionType.stroke,
        regionId = null,
        previousColor = null,
        nextColor = null;

  const DrawingAction.fill({
    required this.regionId,
    required this.previousColor,
    required this.nextColor,
  })  : type = DrawingActionType.fill,
        stroke = null;

  final DrawingActionType type;
  final DrawingStroke? stroke;
  final String? regionId;
  final Color? previousColor;
  final Color? nextColor;
}
