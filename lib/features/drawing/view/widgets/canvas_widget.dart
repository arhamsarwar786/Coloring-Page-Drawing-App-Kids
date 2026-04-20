import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../levels/model/level_model.dart';
import '../../../skins/model/skin_model.dart';
import '../../../skins/viewmodel/skins_viewmodel.dart';
import '../../viewmodel/drawing_viewmodel.dart';

// ─────────────────────────────────────────────────────────────
// CanvasWidget
// ─────────────────────────────────────────────────────────────
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
  final void Function(String regionId) onFill;

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget>
    with TickerProviderStateMixin {
  // ── Marker tracking ──────────────────────────────────────
  Offset? _dragPosition;
  bool _hasInteracted = false;

  // ── Fill animation ────────────────────────────────────────
  late AnimationController _fillAnimationController;
  String? _activeRegionId;
  Color? _activeRegionOriginalColor;

  // ── Tracing state ─────────────────────────────────────────
  // regionId → fraction of outline traced [0..1]
  final Map<String, double> _outlineProgress = {};
  // Regions whose outline is fully traced → fill is unlocked
  final Set<String> _outlineUnlocked = {};
  // regionId → fraction of interior scribbled [0..1]
  final Map<String, double> _fillProgress = {};
  // Cheap deduplication — gridded visited cells per region
  final Map<String, Set<String>> _visitedCells = {};

  // Grid cell size for tracing deduplication (logical pixels)
  static const double _cellSize = 14.0;

  int _getOutlineCellsNeeded(Path path) {
    final bounds = path.getBounds();
    final perimeter = 2 * (bounds.width + bounds.height);
    final cells = (perimeter * 0.6) / _cellSize;
    return cells.clamp(8.0, 100.0).toInt();
  }

  int _getFillCellsNeeded(Path path) {
    final bounds = path.getBounds();
    final area = bounds.width * bounds.height;
    // Require roughly 45% of the bounding box area to be covered
    // (Safe margin for complex/concave SVGs where bounding box is much larger than actual area)
    final cells = (area * 0.45) / (_cellSize * _cellSize);
    return cells.clamp(15.0, 300.0).toInt();
  }

  // Track the actual path the user is drawing during the fill phase
  final Map<String, Path> _scribblePaths = {};

  // ── Appreciation overlay ──────────────────────────────────
  bool _showAppreciation = false;
  String _appreciationText = '🌟 Great Job!';
  late AnimationController _appreciationController;
  late Animation<double> _appreciationScale;
  late Animation<Offset> _appreciationOffset;

  // ── Tap scale on marker ───────────────────────────────────
  late AnimationController _tapScaleController;

  static const List<String> _appreciationMessages = [
    '🌟 Great Job!',
    '🎉 Awesome!',
    '🔥 Super!',
    '🦄 Brilliant!',
    '👏 Well Done!',
    '🎨 Perfect!',
  ];

  @override
  void initState() {
    super.initState();
    _fillAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _appreciationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _appreciationScale = CurvedAnimation(
      parent: _appreciationController,
      curve: Curves.elasticOut,
    );
    _appreciationOffset = Tween<Offset>(
      begin: const Offset(0.0, 1.5), // Start below the bottom edge
      end: const Offset(0.0, 0.0),  // Stop exactly at the bottom edge
    ).animate(CurvedAnimation(
      parent: _appreciationController,
      curve: Curves.easeOutBack,
    ));
    _tapScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 1.0,
      upperBound: 1.12,
    );
  }

  @override
  void didUpdateWidget(CanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filledRegions != widget.filledRegions) {
      for (final entry in widget.filledRegions.entries) {
        if (oldWidget.filledRegions[entry.key] != entry.value) {
          setState(() {
            _activeRegionId = entry.key;
            _activeRegionOriginalColor =
                oldWidget.filledRegions[entry.key] ?? const Color(0x00FFFFFF);
          });
          _fillAnimationController.forward(from: 0.0);
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _fillAnimationController.dispose();
    _appreciationController.dispose();
    _tapScaleController.dispose();
    super.dispose();
  }

  // ── Coordinate helper ─────────────────────────────────────
  Offset _toLocal(Offset raw, Size canvasSize, BoxConstraints c) {
    final dim = math.min(c.maxWidth, c.maxHeight);
    return Offset(raw.dx - (c.maxWidth - dim) / 2,
        raw.dy - (c.maxHeight - dim) / 2);
  }

  String _cellKey(Offset p) {
    final gx = (p.dx / _cellSize).floor();
    final gy = (p.dy / _cellSize).floor();
    return '$gx,$gy';
  }

  // ── Path-proximity check (outline tracing) ────────────────
  bool _isNearOutline(Path path, Offset point,
      {double threshold = 18.0}) {
    for (final metric in path.computeMetrics()) {
      for (double t = 0; t < metric.length; t += 4.0) {
        final tangent = metric.getTangentForOffset(t);
        if (tangent == null) continue;
        if ((tangent.position - point).distance <= threshold) return true;
      }
    }
    return false;
  }

  // ── Main tracing logic ────────────────────────────────────
  void _handleTrace(Offset local, Size canvasSize, Color selectedColor) {
    bool changed = false;

    for (final region in widget.level.regions) {
      if (widget.filledRegions.containsKey(region.id)) continue;

      final path = region.toPath(canvasSize);
      final cell = _cellKey(local);
      _visitedCells.putIfAbsent(region.id, () => {});

      if (!_outlineUnlocked.contains(region.id)) {
        // ── Step 1: Trace the outline ─────────────────────
        if (_isNearOutline(path, local)) {
          if (_visitedCells[region.id]!.add(cell)) {
            final visited = _visitedCells[region.id]!.length;
            final needed = _getOutlineCellsNeeded(path);
            _outlineProgress[region.id] =
                (visited / needed).clamp(0.0, 1.0);

            if (visited >= needed) {
              _outlineUnlocked.add(region.id);
              // Reset cells for fill phase
              _visitedCells[region.id]!.clear();
              HapticFeedback.selectionClick();
            }
            changed = true;
          }
        }
      } else {
        // ── Step 2: Scribble inside to fill ──────────────
        if (path.contains(local)) {
          // Track the exact scribble path
          if (!_scribblePaths.containsKey(region.id)) {
            _scribblePaths[region.id] = Path()..moveTo(local.dx, local.dy);
          } else {
            _scribblePaths[region.id]!.lineTo(local.dx, local.dy);
          }

          if (_visitedCells[region.id]!.add(cell)) {
            final visited = _visitedCells[region.id]!.length;
            final needed = _getFillCellsNeeded(path);
            _fillProgress[region.id] =
                (visited / needed).clamp(0.0, 1.0);

            if (visited >= needed) {
              // Complete — trigger actual fill
              _fillProgress.remove(region.id);
              _visitedCells.remove(region.id);
              _outlineUnlocked.remove(region.id);
              _outlineProgress.remove(region.id);
              _scribblePaths.remove(region.id); // clear scribble path
              widget.onFill(region.id);
              _triggerAppreciation(selectedColor);
            }
            changed = true;
          } else {
            // Even if no new cell visited, we added a point to the path, so repaint
            changed = true;
          }
        }
      }
    }

    if (changed) setState(() {});
  }

  void _triggerAppreciation(Color color) {
    final msg = _appreciationMessages[
        math.Random().nextInt(_appreciationMessages.length)];
    setState(() {
      _showAppreciation = true;
      _appreciationText = msg;
    });
    _appreciationController.forward(from: 0.0);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      _appreciationController.reverse().then((_) {
        if (mounted) setState(() => _showAppreciation = false);
      });
    });
  }

  // ── Gesture handlers ──────────────────────────────────────
  void _onPanStart(
      Offset local, Size canvasSize, Color selectedColor) {
    _dragPosition = local;
    _hasInteracted = true;
    _tapScaleController.forward().then((_) => _tapScaleController.reverse());
    
    // When a new pan starts, we want to reset the scribble path's starting point
    // so it doesn't draw a straight line from the last lift point.
    for (var region in widget.level.regions) {
      if (_outlineUnlocked.contains(region.id) && !widget.filledRegions.containsKey(region.id)) {
        if (_scribblePaths.containsKey(region.id)) {
           _scribblePaths[region.id]!.moveTo(local.dx, local.dy);
        }
      }
    }
    
    _handleTrace(local, canvasSize, selectedColor);
    setState(() {});
  }

  void _onPanUpdate(
      Offset local, Size canvasSize, Color selectedColor) {
    _dragPosition = local;
    _handleTrace(local, canvasSize, selectedColor);
    setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer2<SkinsViewModel, DrawingViewModel>(
      builder: (context, skinsVm, drawingVm, _) {
        final selectedColor =
            drawingVm.selectedColor?.color ?? Colors.deepPurple;
        final skin = skinsVm.selectedSkin;

        return LayoutBuilder(builder: (context, constraints) {
          final dim = math.min(constraints.maxWidth, constraints.maxHeight);
          final canvasSize = Size.square(dim);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (d) => _onPanStart(
                _toLocal(d.localPosition, canvasSize, constraints),
                canvasSize,
                selectedColor),
            onPanUpdate: (d) => _onPanUpdate(
                _toLocal(d.localPosition, canvasSize, constraints),
                canvasSize,
                selectedColor),
            onPanEnd: (_) {},
            onPanCancel: () {},
            onTapDown: (d) {
              setState(() {
                _dragPosition =
                    _toLocal(d.localPosition, canvasSize, constraints);
                _hasInteracted = true;
              });
            },
            onTapUp: (d) {
              _tapScaleController
                  .forward()
                  .then((_) => _tapScaleController.reverse());
              // We removed tap-to-fill, user must trace to fill.
            },
            child: Center(
              child: Container(
                width: dim,
                height: dim,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 12)),
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Canvas ────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: AnimatedBuilder(
                        animation: _fillAnimationController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: AdvancedCanvasPainter(
                              level: widget.level,
                              filledRegions: widget.filledRegions,
                              activeRegionId: _activeRegionId,
                              activeRegionOriginalColor:
                                  _activeRegionOriginalColor,
                              animationValue: _fillAnimationController.value,
                              outlineUnlocked: _outlineUnlocked,
                              outlineProgress: _outlineProgress,
                              fillProgress: _fillProgress,
                              scribblePaths: _scribblePaths,
                              tracingColor: selectedColor,
                            ),
                            size: canvasSize,
                          );
                        },
                      ),
                    ),

                    // ── Appreciation ──────────────────────
                    if (_showAppreciation)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SlideTransition(
                          position: _appreciationOffset,
                          child: ScaleTransition(
                            scale: _appreciationScale,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedColor.withValues(alpha: 0.4),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(
                                    color: selectedColor.withValues(alpha: 0.7),
                                    width: 2.5),
                              ),
                              child: Text(
                                _appreciationText,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── Marker (body + colored nib) ───────
                    _buildMarker(skin, selectedColor, dim),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildMarker(SkinModel skin, Color selectedColor, double dim) {
    final double defaultLeft = dim - 120;
    final double defaultTop = dim - 120;

    final double left = _hasInteracted && _dragPosition != null
        ? _dragPosition!.dx - 10
        : defaultLeft;
    final double top = _hasInteracted && _dragPosition != null
        ? _dragPosition!.dy - 120
        : defaultTop;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 60),
      curve: Curves.easeOutQuad,
      left: left,
      top: top,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _tapScaleController,
          builder: (context, child) => Transform.scale(
            scale: _tapScaleController.value,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Marker body (original PNG) ─────────
                if (skin.image != null)
                  Image.asset(
                    skin.image!,
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),

                // ── Nib color overlay ──────────────────
                // The nib is at the bottom-tip of the marker image.
                // We paint a small colored circle at nib position.
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CustomPaint(
                      painter: _NibPainter(color: selectedColor),
                      size: const Size(18, 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Nib Painter — small teardrop shaped nib at marker tip
// ─────────────────────────────────────────────────────────────
class _NibPainter extends CustomPainter {
  _NibPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..cubicTo(0, size.height * 0.6, 0, 0, size.width / 2, 0)
      ..cubicTo(size.width, 0, size.width, size.height * 0.6,
          size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Tiny glint
    final glint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.35, size.height * 0.22),
            width: 3,
            height: 4),
        glint);
  }

  @override
  bool shouldRepaint(_NibPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────
// AdvancedCanvasPainter
// ─────────────────────────────────────────────────────────────
class AdvancedCanvasPainter extends CustomPainter {
  AdvancedCanvasPainter({
    required this.level,
    required this.filledRegions,
    this.activeRegionId,
    this.activeRegionOriginalColor,
    this.animationValue = 1.0,
    required this.outlineUnlocked,
    required this.outlineProgress,
    required this.fillProgress,
    required this.scribblePaths,
    required this.tracingColor,
  });

  final LevelModel level;
  final Map<String, Color> filledRegions;
  final String? activeRegionId;
  final Color? activeRegionOriginalColor;
  final double animationValue;
  final Set<String> outlineUnlocked;
  final Map<String, double> outlineProgress;
  final Map<String, double> fillProgress;
  final Map<String, Path> scribblePaths;
  final Color tracingColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFFFFEFB));

    final guideOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.01
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFCCCCCC);

    final solidOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.013
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black26;

    for (final region in level.regions) {
      final path = region.toPath(size);
      final fillColor = filledRegions[region.id];
      final isFilled = fillColor != null;
      final progress = outlineProgress[region.id] ?? 0.0;
      final isUnlocked = outlineUnlocked.contains(region.id);
      final scribbleProgress = fillProgress[region.id] ?? 0.0;

      // ── Shadow for filled regions ─────────────────────────
      if (isFilled) {
        canvas.drawShadow(path, Colors.black, 3, true);
      }

      // ── Fill layer ────────────────────────────────────────
      if (isFilled) {
        final p = Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

        if (region.id == activeRegionId) {
          final from = activeRegionOriginalColor ?? const Color(0x00FFFFFF);
          p.color = Color.lerp(from, fillColor, animationValue)!;
        } else {
          p.color = fillColor;
        }

        p.shader = LinearGradient(
          colors: [p.color.withValues(alpha: 0.82), p.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(path.getBounds());

        canvas.drawPath(path, p);
      } else if (isUnlocked && scribbleProgress > 0) {
        // Scribble fill in progress
        final scribblePath = scribblePaths[region.id];
        if (scribblePath != null) {
          canvas.save();
          // Clip the drawing to the exact bounds of the region
          canvas.clipPath(path);
          
          canvas.drawPath(
            scribblePath,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..strokeWidth = size.shortestSide * 0.12 // very thick marker
              ..color = tracingColor
              ..isAntiAlias = true,
          );
          canvas.restore();
        }
      } else {
        // Unfilled background — transparent
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(0x00FFFFFF),
        );
      }

      // ── Outline layer ─────────────────────────────────────
      if (isFilled) {
        canvas.drawPath(path, solidOutline);
      } else if (isUnlocked) {
        // Outline fully traced — draw solid selected-color outline
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.shortestSide * 0.015
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = tracingColor
            ..maskFilter =
                const MaskFilter.blur(BlurStyle.normal, 2),
        );
      } else if (progress > 0) {
        // Partially traced — show progress via colored dash
        _drawPartialOutline(canvas, path, progress, size);
        _drawDashedPath(canvas, path, guideOutline);
      } else {
        // Not yet touched — dashed grey
        _drawDashedPath(canvas, path, guideOutline);
      }

      // ── Active region highlight ───────────────────────────
      if (region.id == activeRegionId) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.shortestSide * 0.016
            ..color = Colors.orangeAccent
            ..isAntiAlias = true,
        );
      }
    }
  }

  /// Draw only the first [progress] fraction of the path in the tracing color.
  void _drawPartialOutline(
      Canvas canvas, Path path, double progress, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.014
      ..strokeCap = StrokeCap.round
      ..color = tracingColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    for (final metric in path.computeMetrics()) {
      final end = metric.length * progress;
      if (end > 0) {
        canvas.drawPath(metric.extractPath(0, end), paint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path source, Paint paint) {
    for (final metric in source.computeMetrics()) {
      double d = 0;
      const double dash = 10;
      const double gap = 7;
      while (d < metric.length) {
        final next = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, next), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant AdvancedCanvasPainter old) => true;
}
