import 'package:flutter/material.dart';

import '../../features/levels/model/level_model.dart';

class LevelPreview extends StatefulWidget {
  const LevelPreview({
    super.key,
    required this.level,
    this.size = 72,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.style = LevelPreviewStyle.colored,
    this.animate = true,
    this.filledRegions,
  });

  final LevelModel level;
  final double size;
  final Color backgroundColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final LevelPreviewStyle style;
  final bool animate;
  final Map<String, Color>? filledRegions;

  @override
  State<LevelPreview> createState() => _LevelPreviewState();
}

class _LevelPreviewState extends State<LevelPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LevelPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0.5; // mid point, i.e., scale 1.0
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget previewChild = Container(
      width: widget.size,
      height: widget.size,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
      ),
      child: CustomPaint(
        painter: _LevelPreviewPainter(
          level: widget.level,
          style: widget.style,
          filledRegions: widget.filledRegions,
        ),
        size: Size.square(widget.size),
      ),
    );

    if (widget.animate) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: previewChild,
      );
    }
    return previewChild;
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
    this.filledRegions,
  });

  final LevelModel level;
  final LevelPreviewStyle style;
  final Map<String, Color>? filledRegions;

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
      
      Color fillColor;
      if (style == LevelPreviewStyle.lineArt) {
        fillColor = Colors.white;
      } else if (filledRegions != null) {
        fillColor = filledRegions![region.id] ?? Colors.white;
      } else {
        fillColor = level.getTargetColorForRegion(region.id);
      }

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = fillColor
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
    return oldDelegate.level != level || 
        oldDelegate.style != style ||
        oldDelegate.filledRegions != filledRegions;
  }
}
