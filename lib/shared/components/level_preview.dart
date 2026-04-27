import 'package:flutter/material.dart';

import '../../features/levels/model/level_model.dart';

class LevelPreview extends StatelessWidget {
  const LevelPreview({
    super.key,
    required this.level,
    this.size = 72,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.style = LevelPreviewStyle.colored,
  });

  final LevelModel level;
  final double size;
  final Color backgroundColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final LevelPreviewStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: CustomPaint(
        painter: _LevelPreviewPainter(
          level: level,
          style: style,
        ),
        size: Size.square(size),
      ),
    );
  }
}

enum LevelPreviewStyle {
  colored,
  lineArt,
}

class _LevelPreviewPainter extends CustomPainter {
  const _LevelPreviewPainter({
    required this.level,
    required this.style,
  });

  final LevelModel level;
  final LevelPreviewStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    const sourceSize = Size(100, 100);
    final scale = size.shortestSide / sourceSize.shortestSide;
    final previewWidth = sourceSize.width * scale;
    final previewHeight = sourceSize.height * scale;
    final dx = (size.width - previewWidth) / 2;
    final dy = (size.height - previewHeight) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    for (final region in level.regions) {
      final path = region.toPath(sourceSize);
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = style == LevelPreviewStyle.lineArt
            ? Colors.white
            : level.getTargetColorForRegion(region.id)
        ..isAntiAlias = true;
      final outlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withValues(
          alpha: style == LevelPreviewStyle.lineArt ? 0.92 : 0.28,
        )
        ..strokeWidth = style == LevelPreviewStyle.lineArt ? 3 : 2
        ..isAntiAlias = true;

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, outlinePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LevelPreviewPainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.style != style;
  }
}
