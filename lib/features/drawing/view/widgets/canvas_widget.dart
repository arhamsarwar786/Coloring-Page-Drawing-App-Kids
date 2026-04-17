import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../levels/model/level_model.dart';
import '../../../skins/viewmodel/skins_viewmodel.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({
    super.key,
    required this.level,
    this.guideAsset,
    required this.filledRegions,
    required this.onFill,
  });

  final LevelModel level;
  final String? guideAsset;
  final Map<String, Color> filledRegions;
  final void Function(Offset point, Size canvasSize) onFill;

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  Offset? _dragPosition;
  bool _hasInteracted = false;

  void _handleInteraction(
      Offset globalPosition, Size canvasSize, BoxConstraints constraints) {
    final dimension = math.min(constraints.maxWidth, constraints.maxHeight);
    final dxOffset = (constraints.maxWidth - dimension) / 2;
    final dyOffset = (constraints.maxHeight - dimension) / 2;

    final localPosition = Offset(
      globalPosition.dx - dxOffset,
      globalPosition.dy - dyOffset,
    );

    setState(() {
      _dragPosition = localPosition;
      _hasInteracted = true;
    });
  }

  void _handleFill(
      Offset globalPosition, Size canvasSize, BoxConstraints constraints) {
    final dimension = math.min(constraints.maxWidth, constraints.maxHeight);
    final dxOffset = (constraints.maxWidth - dimension) / 2;
    final dyOffset = (constraints.maxHeight - dimension) / 2;

    final localPosition = Offset(
      globalPosition.dx - dxOffset,
      globalPosition.dy - dyOffset,
    );

    setState(() {
      _dragPosition = localPosition;
      _hasInteracted = true;
    });
    widget.onFill(localPosition, canvasSize);
  }

  void _clearInteraction() {
    // We do NOT set _dragPosition to null so the marker stays where it was left!
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = math.min(constraints.maxWidth, constraints.maxHeight);
        final canvasSize = Size.square(dimension);

        return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) => _handleInteraction(
                details.localPosition, canvasSize, constraints),
            onPanUpdate: (details) => _handleInteraction(
                details.localPosition, canvasSize, constraints),
            onPanEnd: (_) => _clearInteraction(),
            onPanCancel: () => _clearInteraction(),
            onTapDown: (details) => _handleInteraction(
                details.localPosition, canvasSize, constraints),
            onTapUp: (details) =>
                _handleFill(details.localPosition, canvasSize, constraints),
            onTapCancel: () => _clearInteraction(),
            child: Center(
              child: Container(
                width: dimension,
                height: dimension,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.08),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          if (widget.guideAsset != null)
                            Opacity(
                              opacity: 0.18,
                              child: Image.asset(
                                widget.guideAsset!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.medium,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.black26,
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                            ),
                          CustomPaint(
                            painter: _CanvasPainter(
                              level: widget.level,
                              filledRegions: widget.filledRegions,
                            ),
                            size: canvasSize,
                          ),
                        ],
                      ),
                    ),
                    Consumer<SkinsViewModel>(
                      builder: (context, skinsViewModel, _) {
                        final markerImage = skinsViewModel.selectedSkin.image;

                        final double defaultLeft = canvasSize.width - 120;
                        final double defaultTop = canvasSize.height - 120;

                        final double currentLeft =
                            _hasInteracted && _dragPosition != null
                                ? _dragPosition!.dx - 10
                                : defaultLeft;

                        final double currentTop =
                            _hasInteracted && _dragPosition != null
                                ? _dragPosition!.dy - 120
                                : defaultTop;

                        return Positioned(
                          left: currentLeft,
                          top: currentTop,
                          child: IgnorePointer(
                            child: Image.asset(
                              markerImage ?? 'assets/images/marker.png',
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({
    required this.level,
    required this.filledRegions,
  });

  final LevelModel level;
  final Map<String, Color> filledRegions;

  @override
  void paint(Canvas canvas, Size size) {
    final surfacePaint = Paint()..color = const Color(0xFFFFFEFB);
    canvas.drawRect(Offset.zero & size, surfacePaint);

    final guideFill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x00FFFFFF);

    final guideOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.01
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFD0D0D0);

    final solidOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.012
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF222222);

    for (final region in level.regions) {
      final path = region.toPath(size);
      final fillColor = filledRegions[region.id];
      canvas.drawPath(
        path,
        fillColor != null
            ? (Paint()
              ..style = PaintingStyle.fill
              ..color = fillColor.withOpacity(0.94))
            : guideFill,
      );
      if (fillColor == null) {
        _drawDashedPath(canvas, path, guideOutline);
      } else {
        canvas.drawPath(path, solidOutline);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path source, Paint paint) {
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      const double dashLength = 10;
      const double gapLength = 7;

      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return oldDelegate.filledRegions != filledRegions ||
        oldDelegate.level != level;
  }
}
