import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/coloring/model/drawing_point.dart';
import 'package:play_craft_kids/features/levels/model/level_model.dart';
import 'package:play_craft_kids/features/coloring/widgets/animal_path_data.dart';
import 'package:play_craft_kids/features/coloring/widgets/guided_painting_controllers.dart';

class ColoredLine {
  const ColoredLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
}

class ColoringPainter extends CustomPainter {
  final List<ColoredLine> completedLines;
  final List<Offset> currentLinePoints;
  final Color activeColor;
  final double activeStrokeWidth;
  final String animal;

  // Modern region-based painting parameters
  final LevelModel? level;
  final Map<String, Color>? filledRegions;
  final ColoringStepController? coloringController;

  ColoringPainter({
    required this.completedLines,
    required this.currentLinePoints,
    required this.activeColor,
    required this.activeStrokeWidth,
    required this.animal,
    this.level,
    this.filledRegions,
    this.coloringController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activeLevel = level;
    final controller = coloringController;

    if (activeLevel != null) {
      // 1. Draw each region's painted strokes confined perfectly inside the region path
      for (final region in activeLevel.regions) {
        final path = region.toPath(size);

        // Draw solid background color for region first
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(0xFFFFFEFB),
        );

        if (controller != null) {
          final strokes = controller.strokesFor(region.id);
          if (strokes.isNotEmpty) {
            _paintRegionStrokes(canvas, path, strokes);
          }
        }

        // Draw filled regions if any fallback filled regions exist
        final filledColor = filledRegions?[region.id];
        if (filledColor != null) {
          final paint = Paint()
            ..style = PaintingStyle.fill
            ..isAntiAlias = true
            ..color = filledColor;
          canvas.drawPath(path, paint);
        }
      }

      // 2. Draw bold black animal outline guide paths on top!
      final guidePaint = Paint()
        ..color = const Color(0xFF1E1E24)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (final region in activeLevel.regions) {
        final path = region.toPath(size);
        canvas.drawPath(path, guidePaint);
      }
      return;
    }

    // Legacy freehand drawing fallback
    for (final line in completedLines) {
      if (line.points.length < 2) {
        if (line.points.isNotEmpty) {
          canvas.drawCircle(
            line.points.first,
            line.strokeWidth / 2,
            Paint()
              ..color = line.color
              ..style = PaintingStyle.fill,
          );
        }
        continue;
      }
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final strokePath = Path()
        ..moveTo(line.points.first.dx, line.points.first.dy);
      for (int i = 1; i < line.points.length; i++) {
        strokePath.lineTo(line.points[i].dx, line.points[i].dy);
      }
      canvas.drawPath(strokePath, paint);
    }

    if (currentLinePoints.isNotEmpty) {
      if (currentLinePoints.length < 2) {
        canvas.drawCircle(
          currentLinePoints.first,
          activeStrokeWidth / 2,
          Paint()
            ..color = activeColor
            ..style = PaintingStyle.fill,
        );
      } else {
        final paint = Paint()
          ..color = activeColor
          ..strokeWidth = activeStrokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final strokePath = Path()
          ..moveTo(currentLinePoints.first.dx, currentLinePoints.first.dy);
        for (int i = 1; i < currentLinePoints.length; i++) {
          strokePath.lineTo(currentLinePoints[i].dx, currentLinePoints[i].dy);
        }
        canvas.drawPath(strokePath, paint);
      }
    }

    final guidePaint = Paint()
      ..color = const Color(0xFF1E1E24)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final animalPath = AnimalPathData.getAnimalPath(animal, size);
    canvas.drawPath(animalPath, guidePaint);
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

      final curvePath = Path();
      curvePath.moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];
        final midX = (p1.dx + p2.dx) / 2;
        final midY = (p1.dy + p2.dy) / 2;
        curvePath.quadraticBezierTo(p1.dx, p1.dy, midX, midY);
      }
      curvePath.lineTo(stroke.points.last.dx, stroke.points.last.dy);
      canvas.drawPath(curvePath, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ColoringPainter oldDelegate) {
    return oldDelegate.completedLines != completedLines ||
        oldDelegate.currentLinePoints != currentLinePoints ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.activeStrokeWidth != activeStrokeWidth ||
        oldDelegate.animal != animal ||
        oldDelegate.level != level ||
        oldDelegate.filledRegions != filledRegions ||
        oldDelegate.coloringController != coloringController;
  }
}
