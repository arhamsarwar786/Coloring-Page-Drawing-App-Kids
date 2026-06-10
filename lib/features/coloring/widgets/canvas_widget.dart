// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/coloring_viewmodel.dart';

// ── CanvasWidget ──────────────────────────────────────────────────────────────
//
//  Layer order (bottom → top):
//   1. Warm-white background
//   2. coloredImage      — 640×640 pixel buffer the child paints into
//   3. Highlight overlay — pulsing amber glow on the active region
//   4. originalOutlineImage — full-res PNG with BlendMode.multiply for crisp
//                             black outlines above all paint
//
//  Interaction:
//   • 1 finger  → paint (GestureDetector.onScaleStart/Update/End)
//   • 2 fingers → pinch-zoom / pan (InteractiveViewer takes over)
//
//  Coordinate mapping:
//   Because GestureDetector lives INSIDE InteractiveViewer's Transform,
//   Flutter's render-tree hit-test already applies the inverse matrix when
//   delivering pointer events.  localFocalPoint is therefore already in
//   unscaled canvas space — no manual matrix inversion is needed.
//
// ─────────────────────────────────────────────────────────────────────────────

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget>
    with TickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Zoom animation ─────────────────────────────────────────────────────────
  late final AnimationController _zoomCtrl;
  Animation<Matrix4>? _zoomAnim;

  int _pointerCount = 0;
  String? _lastLoadedItemId;
  String? _lastAutoZoomKey;
  bool _wasAutoZoomEnabled = true;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _zoomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Smooth slower zoom
    );
    _zoomCtrl.addListener(_onZoomTick);
  }

  void _onZoomTick() {
    final anim = _zoomAnim;
    if (anim == null) return;
    _controller.value = anim.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowCtrl.dispose();
    _zoomCtrl.dispose();
    super.dispose();
  }

  // void _scheduleAutoZoom(
  //   ColoringProvider provider,
  //   double viewportWidth,
  //   double viewportHeight,
  // ) {
  //   if (!provider.autoZoomEnabled ||
  //       provider.activeRegionBoundsFraction == null ||
  //       provider.isPartByPartComplete) {
  //     return;
  //   }

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!mounted) return;
  //     _applyAutoZoom(provider, viewportWidth, viewportHeight);
  //   });
  // }

  void _applyAutoZoom(
    ColoringProvider provider,
    double viewportWidth,
    double viewportHeight,
  ) {
    final bounds = provider.activeRegionBoundsFraction;
    if (bounds == null) return;

    var imageRect = provider.imageDisplayRect;
    if (imageRect.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        imageRect = provider.imageDisplayRect;
        if (imageRect.isEmpty) return;
        _applyAutoZoom(provider, viewportWidth, viewportHeight);
      });
      return;
    }

    final regionRect = Rect.fromLTRB(
      imageRect.left + bounds.left * imageRect.width,
      imageRect.top + bounds.top * imageRect.height,
      imageRect.left + bounds.right * imageRect.width,
      imageRect.top + bounds.bottom * imageRect.height,
    );

    if (regionRect.width < 1 || regionRect.height < 1) return;

    const padding = 1.35;
    final scale = math
        .min(
          viewportWidth / (regionRect.width * padding),
          viewportHeight / (regionRect.height * padding),
        )
        .clamp(1.0, 8.0);

    final center = regionRect.center;
    final viewportCenter = Offset(viewportWidth / 2, viewportHeight / 2);
    final targetMatrix = Matrix4.identity()
      ..translate(viewportCenter.dx, viewportCenter.dy)
      ..scale(scale)
      ..translate(-center.dx, -center.dy);

    // Animate from the current transform to the target smoothly.
    _zoomCtrl.stop();
    _zoomAnim = Matrix4Tween(
      begin: _controller.value.clone(),
      end: targetMatrix,
    ).animate(CurvedAnimation(parent: _zoomCtrl, curve: Curves.easeInOutCubic));
    _zoomCtrl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColoringProvider>(
      builder: (context, provider, _) {
        if (!provider.isLoaded) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
              strokeWidth: 4,
            ),
          );
        }

        if (_lastLoadedItemId != provider.currentItemId) {
          _lastLoadedItemId = provider.currentItemId;
          _lastAutoZoomKey = null;
          _isCompleted = false;
          _controller.value = Matrix4.identity();
        }

        // Handle auto zoom-out to normal on level completion
        final isComplete = provider.isPartByPartComplete;
        if (isComplete && !_isCompleted) {
          _isCompleted = true;
          _lastAutoZoomKey = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _zoomCtrl.stop();
            _zoomAnim = Matrix4Tween(
              begin: _controller.value.clone(),
              end: Matrix4.identity(),
            ).animate(
              CurvedAnimation(
                parent: _zoomCtrl,
                curve: Curves.easeInOutCubic,
              ),
            );
            _zoomCtrl
              ..reset()
              ..forward();
          });
        }

        final zoomKey =
            '${provider.currentItemId}_${provider.activeRegionIndex}';
        final autoZoomTurnedOn =
            provider.autoZoomEnabled && !_wasAutoZoomEnabled;
        _wasAutoZoomEnabled = provider.autoZoomEnabled;

        final shouldAutoZoom = provider.autoZoomEnabled &&
            !provider.isPartByPartComplete &&
            provider.activeRegionBoundsFraction != null;
        var needsAutoZoom = false;
        if (shouldAutoZoom &&
            (zoomKey != _lastAutoZoomKey || autoZoomTurnedOn)) {
          needsAutoZoom = true;
          _lastAutoZoomKey = zoomKey;
        }
        if (!provider.autoZoomEnabled) {
          _lastAutoZoomKey = null;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final side = math.min(constraints.maxWidth, constraints.maxHeight);

            // if (needsAutoZoom) {
            //   _scheduleAutoZoom(
            //     provider,
            //     constraints.maxWidth,
            //     constraints.maxHeight,
            //   );
            // }

            return ClipRect(
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1.0,
                maxScale: 10.0,
                panEnabled: false, // 1 finger draws, so disable 1-finger pan
                scaleEnabled: true, // 2 fingers will zoom AND pan
                boundaryMargin: EdgeInsets.zero,
                constrained: true,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  // ── Single-finger draw ────────────────────────────────────
                  onPointerDown: (e) {
                    _pointerCount++;
                    if (_pointerCount == 1) {
                      provider.handlePanStart(e.localPosition);
                    }
                  },
                  onPointerMove: (e) {
                    if (_pointerCount == 1) {
                      provider.handlePanUpdate(e.localPosition);
                    }
                  },
                  onPointerUp: (e) {
                    _pointerCount--;
                    if (_pointerCount == 0) {
                      provider.handlePanEnd();
                    }
                  },
                  onPointerCancel: (e) {
                    _pointerCount--;
                    if (_pointerCount == 0) {
                      provider.handlePanEnd();
                    }
                  },

                  // ── Canvas & Bouncing Indicator Stack ─────────────────────
                  child: SizedBox(
                    width: side,
                    height: side,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: AnimatedBuilder(
                              animation: _glowAnim,
                              builder: (context, _) {
                                return CustomPaint(
                                  size: Size.square(side),
                                  painter: ColoringPainter(
                                    coloredImage: provider.coloredImage,
                                    originalOutlineImage:
                                        provider.originalOutlineImage,
                                    activeRegionHighlightImage:
                                        provider.activeRegionHighlightImage,
                                    activeRegionProgress:
                                        provider.activePartProgress,
                                    glowPulse: _glowAnim.value,
                                    onImageRect: (rect) {
                                      // Tell the provider where the image lives in
                                      // widget space for touch→pixel coordinate mapping.
                                      if (provider.imageDisplayRect != rect) {
                                        provider.imageDisplayRect = rect;
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Modern guide rule: A beautiful bouncing hand cursor pointing to the active region.
                        // Vanishes instantly when drawing starts so it never gets in the child's artistic way!
                        if (provider.activeRegionBoundsFraction != null &&
                            !provider.isDragging &&
                            !provider.isPartByPartComplete) ...[
                          Positioned(
                            left:
                                provider.activeRegionBoundsFraction!.center.dx *
                                        side -
                                    24,
                            top:
                                provider.activeRegionBoundsFraction!.center.dy *
                                        side -
                                    24,
                            child: AnimatedBuilder(
                              animation: _glowAnim,
                              builder: (context, _) {
                                // Smooth organic sine-wave bounce
                                final double bounce =
                                    14.0 * math.sin(_glowAnim.value * math.pi);
                                return Transform.translate(
                                  offset: Offset(0, -bounce),
                                  child: IgnorePointer(
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const ui.Color.fromARGB(
                                                    255, 28, 45, 143)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.12,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: const Color(0xFF7B3FE4),
                                          width: 3.5,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.touch_app_rounded,
                                          color: Color(0xFF7B3FE4),
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── ColoringPainter ───────────────────────────────────────────────────────────

class ColoringPainter extends CustomPainter {
  const ColoringPainter({
    required this.coloredImage,
    required this.originalOutlineImage,
    required this.activeRegionHighlightImage,
    required this.activeRegionProgress,
    required this.glowPulse,
    required this.onImageRect,
  });

  final ui.Image? coloredImage;
  final ui.Image? originalOutlineImage;
  final ui.Image? activeRegionHighlightImage;
  final double activeRegionProgress;
  final double glowPulse;
  final void Function(Rect) onImageRect;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Warm-white background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFFEFB),
    );

    if (coloredImage == null) return;

    // 2. Compute BoxFit.contain layout rect
    final imgSize = Size(
      coloredImage!.width.toDouble(),
      coloredImage!.height.toDouble(),
    );
    final fitted = applyBoxFit(BoxFit.contain, imgSize, size);
    final imageRect = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );

    // Report rect to provider for coordinate mapping.
    onImageRect(imageRect);

    // 3. Painted pixel buffer
    paintImage(
      canvas: canvas,
      rect: imageRect,
      image: coloredImage!,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );

    // 4. Active-region guide (blinks and fades as region fills up)
    final highlightImage = activeRegionHighlightImage;
    if (highlightImage != null) {
      final fillPulse = (1 - activeRegionProgress).clamp(0.0, 1.0);

      // Use a gorgeous pulsing neon-purple border contour matching the indicator.
      final alpha = (0.35 + glowPulse * 0.55) * fillPulse;

      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: highlightImage,
        fit: BoxFit.fill,
        colorFilter: ColorFilter.mode(
          const ui.Color.fromARGB(255, 233, 120, 27)
              .withValues(alpha: 1.0), // Change alpha to 1.0 for solid
          BlendMode.srcIn,
        ),
        // ColorFilter.mode(
        //   const Color(
        //     0xFF7B3FE4,
        //   ).withValues(alpha: alpha), // Brilliant Neon Purple
        //   BlendMode.srcIn,
        // ),
        filterQuality: FilterQuality.medium,
      );
    }

    // 5. Crisp full-resolution outline on top via Multiply blend
    if (originalOutlineImage != null) {
      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: originalOutlineImage!,
        fit: BoxFit.fill,
        blendMode: BlendMode.multiply,
        filterQuality: FilterQuality.high,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ColoringPainter old) =>
      old.coloredImage != coloredImage ||
      old.originalOutlineImage != originalOutlineImage ||
      old.activeRegionHighlightImage != activeRegionHighlightImage ||
      old.activeRegionProgress != activeRegionProgress ||
      old.glowPulse != glowPulse;
}
