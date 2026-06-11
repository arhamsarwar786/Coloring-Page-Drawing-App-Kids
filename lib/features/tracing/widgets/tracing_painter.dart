import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/tracing/constants/app_colors.dart';
import 'package:play_craft_kids/features/tracing/widgets/letter_path_data.dart';

// ═══════════════════════════════════════════════════════════
//  TRACING PAINTER  — High Fidelity Edition
//
//  Implemented Layers:
//  1. Static Hollow Letter Background (outlined brown)
//  2. Static Guide Layer (Dashed lines + Directional Arrows)
//  3. Dynamic User Strokes (Thick purple fill)
//  4. Numbered Goal Nodes (Orange active, Faded upcoming)
// ═══════════════════════════════════════════════════════════
class TracingPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> completedStrokes;
  final List<Offset> currentStroke;
  final List<Offset> wrongPoints;
  final int activeStrokeIndex;
  final Color strokeColor;
  final double padding;

  const TracingPainter({
    required this.letter,
    required this.completedStrokes,
    required this.currentStroke,
    required this.wrongPoints,
    required this.activeStrokeIndex,
    required this.strokeColor,
    this.padding = 0.0,
  });

  // ── TUNING ────────────────────────────────────────────────
  static const double _guideStrokeWidth = 84.0;
  static const Color _borderColor = AppColors.deepPurple;
  static const Color _fillColor = AppColors.white;
  static const Color _guideColor = AppColors.butterflyPurple;

  @override
  void paint(Canvas canvas, Size size) {
    final strokes = LetterPathData.getStrokes(letter);

    canvas.save();

    if (padding > 0) {
      final double scaleX = (size.width - padding * 2) / size.width;
      final double scaleY = (size.height - padding * 2) / size.height;
      final double scale = scaleX < scaleY ? scaleX : scaleY;

      final double dx = (size.width - size.width * scale) / 2;
      final double dy = (size.height - size.height * scale) / 2;

      canvas.translate(dx, dy);
      canvas.scale(scale);
    }

    // ── Layer 1: The Hollow Letter Shape (Static Background) ──
    _drawHollowLetter(canvas, size, strokes);

    // ── Layer 2: The Guide (Dashes & Arrows) ──
    _drawGuideLayer(canvas, size, strokes);

    // ── Layer 3: Completed User Strokes ──
    for (final stroke in completedStrokes) {
      _drawUserStroke(canvas, stroke);
    }

    // ── Layer 4: Current User Stroke ──
    if (currentStroke.isNotEmpty) {
      _drawUserStroke(canvas, currentStroke);
    }

    // ── Layer 5: Numbered Goal Nodes ──
    _drawNumberedNodes(canvas, size, strokes);

    canvas.restore();
  }

  // ────────────────────────────────────────────────────────────
  //  LAYER 1 — HOLLOW LETTER
  // ────────────────────────────────────────────────────────────
  void _drawHollowLetter(Canvas canvas, Size size, List<List<Offset>> strokes) {
    final borderPaint = Paint()
      ..color = _borderColor
      ..strokeWidth = _guideStrokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final innerFillPaint = Paint()
      ..color = _fillColor
      ..strokeWidth = _guideStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      final pts = LetterPathData.scale(stroke, size);
      if (pts.length < 2) continue;
      final path = _pointsToPath(_getSmoothPoints(pts));
      canvas.drawPath(path, borderPaint);
      canvas.drawPath(path, innerFillPaint);
    }
  }

  // ────────────────────────────────────────────────────────────
  //  LAYER 2 — GUIDE LAYER (Dashes + Arrows)
  // ────────────────────────────────────────────────────────────
  void _drawGuideLayer(Canvas canvas, Size size, List<List<Offset>> strokes) {
    final dashPaint = Paint()
      ..color = _guideColor.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < strokes.length; i++) {
      // Don't draw guide for already completed strokes
      if (i < activeStrokeIndex) continue;

      final pts = LetterPathData.scale(strokes[i], size);
      if (pts.length < 2) continue;

      final smoothPts = _getSmoothPoints(pts);

      // Draw Dashes
      _drawDashed(canvas, smoothPts, dashPaint);

      // Draw Directional Arrows
      _drawArrows(canvas, smoothPts);
    }
  }

  void _drawArrows(Canvas canvas, List<Offset> points) {
    if (points.length < 15) return;

    final arrowPaint = Paint()
      ..color = _borderColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Draw arrows at 33% and 66% along the path
    final indices = [points.length ~/ 3, (points.length * 2) ~/ 3];

    for (final i in indices) {
      if (i + 1 >= points.length) continue;
      final p1 = points[i];
      final p2 = points[i + 1];
      final dir = p2 - p1;
      final angle = dir.direction;

      canvas.save();
      canvas.translate(p1.dx, p1.dy);
      canvas.rotate(angle);

      final path = Path();
      path.moveTo(0, -6);
      path.lineTo(10, 0);
      path.lineTo(0, 6);
      path.close();

      canvas.drawPath(path, arrowPaint);
      canvas.restore();
    }
  }

  // ────────────────────────────────────────────────────────────
  //  LAYER 3 — USER STROKE
  // ────────────────────────────────────────────────────────────
  void _drawUserStroke(Canvas canvas, List<Offset> points) {
    if (points.isEmpty) return;

    final smoothPts = _getSmoothPoints(points);
    final path = _pointsToPath(smoothPts);

    final paint = Paint()
      ..color = strokeColor // Fully opaque
      ..strokeWidth =
          _guideStrokeWidth + 1 // Slightly overlap to eliminate side borders
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  // ────────────────────────────────────────────────────────────
  //  LAYER 5 — NUMBERED NODES
  // ────────────────────────────────────────────────────────────
  void _drawNumberedNodes(
    Canvas canvas,
    Size size,
    List<List<Offset>> strokes,
  ) {
    if (activeStrokeIndex >= strokes.length) return;

    final scaled = LetterPathData.scale(strokes[activeStrokeIndex], size);
    if (scaled.isEmpty) return;

    final nodeColor = AppColors.smartOrange;

    // Start Node
    _drawNode(canvas, scaled.first, '${activeStrokeIndex * 2 + 1}', nodeColor);
    // End Node
    _drawNode(canvas, scaled.last, '${activeStrokeIndex * 2 + 2}', nodeColor);
  }

  void _drawNode(Canvas canvas, Offset pos, String label, Color color) {
    const radius = 20.0;
    // Circle Shadow/Glow
    canvas.drawCircle(
      pos,
      radius + 2,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Main Circle
    canvas.drawCircle(pos, radius, Paint()..color = color);
    // White Border
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Number Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontFamily: "Regular",
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
    );
  }

  // ────────────────────────────────────────────────────────────
  //  HELPERS
  // ────────────────────────────────────────────────────────────
  List<Offset> _getSmoothPoints(List<Offset> points) {
    if (points.length <= 2) return points;
    final List<Offset> smoothPts = [points.first];
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[0];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      for (double t = 0.1; t <= 1.0; t += 0.15) {
        final t2 = t * t;
        final t3 = t2 * t;
        final qx = 0.5 *
            (2.0 * p1.dx +
                (-p0.dx + p2.dx) * t +
                (2.0 * p0.dx - 5.0 * p1.dx + 4.0 * p2.dx - p3.dx) * t2 +
                (-p0.dx + 3.0 * p1.dx - 3.0 * p2.dx + p3.dx) * t3);
        final qy = 0.5 *
            (2.0 * p1.dy +
                (-p0.dy + p2.dy) * t +
                (2.0 * p0.dy - 5.0 * p1.dy + 4.0 * p2.dy - p3.dy) * t2 +
                (-p0.dy + 3.0 * p1.dy - 3.0 * p2.dy + p3.dy) * t3);
        smoothPts.add(Offset(qx, qy));
      }
    }
    return smoothPts;
  }

  Path _pointsToPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    return path;
  }

  void _drawDashed(Canvas canvas, List<Offset> pts, Paint paint) {
    const dashLen = 14.0;
    const gapLen = 12.0;
    double acc = 0;
    bool drawing = true;
    for (int i = 0; i < pts.length - 1; i++) {
      final seg = pts[i + 1] - pts[i];
      final segLen = seg.distance;
      if (segLen == 0) continue;
      final dir = seg / segLen;
      double pos = 0;
      while (pos < segLen) {
        final needed = drawing ? (dashLen - acc) : (gapLen - acc);
        final take = needed.clamp(0.0, segLen - pos);
        if (drawing) {
          canvas.drawLine(
            pts[i] + dir * pos,
            pts[i] + dir * (pos + take),
            paint,
          );
        }
        acc += take;
        pos += take;
        if (drawing && acc >= dashLen) {
          acc = 0;
          drawing = false;
        } else if (!drawing && acc >= gapLen) {
          acc = 0;
          drawing = true;
        }
      }
    }
  }

  @override
  bool shouldRepaint(TracingPainter old) =>
      old.letter != letter ||
      old.completedStrokes != completedStrokes ||
      old.currentStroke != currentStroke ||
      old.activeStrokeIndex != activeStrokeIndex;
}
