import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maps each animal letter to its dedicated uncolored outline PNG.
class _AnimalAssetMap {
  static String assetFor(String letter) {
    switch (letter.toUpperCase()) {
      case 'A':
        return 'assets/images/un_colored_alligator.png';
      case 'B':
        return 'assets/images/un_colored_bear.png';
      case 'C':
        return 'assets/images/un_colored_cat.png';
      case 'D':
        return 'assets/images/un_colored_dog.png';
      case 'E':
        return 'assets/images/un_colored_elephant.png';
      case 'L':
        return 'assets/images/un_colored_lion.png';
      default:
        return 'assets/images/un_colored_alligator.png';
    }
  }
}

/// Pixel-level BFS coloring canvas.
/// Expose [undo] and [clear] via a [GlobalKey<PixelColoringCanvasState>].
class PixelColoringCanvas extends StatefulWidget {
  final String animalLetter;
  final Color activeColor;
  final double brushRadius;

  const PixelColoringCanvas({
    super.key,
    required this.animalLetter,
    required this.activeColor,
    required this.brushRadius,
  });

  @override
  State<PixelColoringCanvas> createState() => PixelColoringCanvasState();
}

class PixelColoringCanvasState extends State<PixelColoringCanvas> {
  ui.Image? _coloredImage;
  Uint32List? _pixelData;
  Uint32List? _originalPixelData;
  int _imgWidth = 0;
  int _imgHeight = 0;

  final List<Uint32List> _undoStack = [];
  Uint8List? _currentRegionMask;

  DateTime _lastRebuild = DateTime.fromMillisecondsSinceEpoch(0);
  static const _rebuildInterval = Duration(milliseconds: 32); // ~30 fps

  bool _isRebuilding = false;
  Rect _imageRect = Rect.zero;

  bool get canUndo => _undoStack.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadImage(widget.animalLetter);
  }

  @override
  void didUpdateWidget(PixelColoringCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animalLetter != widget.animalLetter) {
      _loadImage(widget.animalLetter);
    }
  }

  // ── Image loading ──────────────────────────────────────────────────────────

  Future<void> _loadImage(String letter) async {
    final path = _AnimalAssetMap.assetFor(letter);
    try {
      final data = await rootBundle.load(path);
      final codec =
          await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final byteData =
          await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null || !mounted) return;

      final pixels = byteData.buffer.asUint32List();
      setState(() {
        _imgWidth = img.width;
        _imgHeight = img.height;
        _originalPixelData = Uint32List.fromList(pixels);
        _pixelData = Uint32List.fromList(pixels);
        _undoStack.clear();
        _currentRegionMask = null;
        _coloredImage = null;
      });
      await _rebuildColoredImage(_pixelData!);
    } catch (e) {
      debugPrint('PixelColoringCanvas: failed to load "$path" – $e');
    }
  }

  // ── Image rebuild ──────────────────────────────────────────────────────────

  Future<void> _rebuildColoredImage(Uint32List pixels) async {
    if (_isRebuilding || _imgWidth == 0) return;
    _isRebuilding = true;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      Uint32List.fromList(pixels).buffer.asUint8List(),
      _imgWidth,
      _imgHeight,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final img = await completer.future;
    if (mounted) {
      setState(() {
        _coloredImage = img;
        _isRebuilding = false;
      });
    } else {
      _isRebuilding = false;
    }
  }

  // ── Coordinate mapping ─────────────────────────────────────────────────────

  Offset? _toImageCoords(Offset localPos) {
    if (_imageRect.isEmpty) return null;
    final sx = _imgWidth / _imageRect.width;
    final sy = _imgHeight / _imageRect.height;
    final x = ((localPos.dx - _imageRect.left) * sx).round();
    final y = ((localPos.dy - _imageRect.top) * sy).round();
    if (x < 0 || y < 0 || x >= _imgWidth || y >= _imgHeight) return null;
    return Offset(x.toDouble(), y.toDouble());
  }

  // ── Outline detection ──────────────────────────────────────────────────────

  /// Returns true for pixels that BFS must NOT cross:
  /// dark outline strokes AND fully transparent background pixels.
  bool _isOutline(Uint32List pix, int i) {
    final p = pix[i];
    final a = (p >> 24) & 0xFF;
    if (a < 128) return true;  // transparent = background boundary ← key fix
    final r = p & 0xFF;
    final g = (p >> 8) & 0xFF;
    final b = (p >> 16) & 0xFF;
    return r < 80 && g < 80 && b < 80;
  }

  // ── BFS region mask ────────────────────────────────────────────────────────

  Uint8List _computeRegionMask(int startX, int startY) {
    final mask = Uint8List(_imgWidth * _imgHeight);
    final orig = _originalPixelData;
    if (orig == null) return mask;

    final startIdx = startY * _imgWidth + startX;
    if (_isOutline(orig, startIdx)) return mask;

    final target = orig[startIdx];
    const tol = 60;
    final queue = <int>[startIdx];
    mask[startIdx] = 1;

    while (queue.isNotEmpty) {
      final idx = queue.removeLast();
      if (_isOutline(orig, idx)) continue;

      final c = orig[idx];
      final cr = c & 0xFF;
      final cg = (c >> 8) & 0xFF;
      final cb = (c >> 16) & 0xFF;
      final tr = target & 0xFF;
      final tg = (target >> 8) & 0xFF;
      final tb = (target >> 16) & 0xFF;
      if ((cr - tr).abs() > tol || (cg - tg).abs() > tol || (cb - tb).abs() > tol) continue;

      final x = idx % _imgWidth;
      final y = idx ~/ _imgWidth;

      void enqueue(int nx, int ny) {
        if (nx < 0 || ny < 0 || nx >= _imgWidth || ny >= _imgHeight) return;
        final ni = ny * _imgWidth + nx;
        if (mask[ni] == 0) {
          mask[ni] = 1;
          queue.add(ni);
        }
      }

      enqueue(x - 1, y);
      enqueue(x + 1, y);
      enqueue(x, y - 1);
      enqueue(x, y + 1);
    }
    return mask;
  }

  // ── Brush paint ────────────────────────────────────────────────────────────

  int _toUint32(Color color) {
    final r = (color.r * 255).round().clamp(0, 255);
    final g = (color.g * 255).round().clamp(0, 255);
    final b = (color.b * 255).round().clamp(0, 255);
    final a = (color.a * 255).round().clamp(0, 255);
    return (a << 24) | (b << 16) | (g << 8) | r;
  }

  void _paintBrush(int cx, int cy) {
    final px = _pixelData;
    final orig = _originalPixelData;
    final mask = _currentRegionMask;
    if (px == null || mask == null || orig == null) return;

    final fillColor = _toUint32(widget.activeColor.withAlpha(230));
    final r = widget.brushRadius.toInt();

    for (int dy = -r; dy <= r; dy++) {
      for (int dx = -r; dx <= r; dx++) {
        if (dx * dx + dy * dy > r * r) continue;
        final nx = cx + dx;
        final ny = cy + dy;
        if (nx < 0 || ny < 0 || nx >= _imgWidth || ny >= _imgHeight) continue;
        final i = ny * _imgWidth + nx;
        if (mask[i] == 0) continue;
        // Never paint transparent (background) pixels
        final origAlpha = (orig[i] >> 24) & 0xFF;
        if (origAlpha < 128) continue;
        px[i] = fillColor;
      }
    }
  }

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onPanStart(Offset pos) {
    final coords = _toImageCoords(pos);
    if (coords == null) return;
    _pushUndo();
    _currentRegionMask =
        _computeRegionMask(coords.dx.toInt(), coords.dy.toInt());
    _paintBrush(coords.dx.toInt(), coords.dy.toInt());
    _throttledRebuild();
  }

  void _onPanUpdate(Offset pos) {
    final coords = _toImageCoords(pos);
    if (coords == null) return;
    _paintBrush(coords.dx.toInt(), coords.dy.toInt());
    _throttledRebuild();
  }

  void _onPanEnd() {
    _currentRegionMask = null;
    if (_pixelData != null) _rebuildColoredImage(_pixelData!);
  }

  void _throttledRebuild() {
    final now = DateTime.now();
    if (now.difference(_lastRebuild) >= _rebuildInterval && !_isRebuilding) {
      _lastRebuild = now;
      _rebuildColoredImage(_pixelData!);
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void _pushUndo() {
    if (_pixelData == null) return;
    _undoStack.add(Uint32List.fromList(_pixelData!));
    if (_undoStack.length > 20) _undoStack.removeAt(0);
  }

  /// Returns the current painted image — call via GlobalKey before navigating away.
  ui.Image? get coloredImage => _coloredImage;

  /// Call via GlobalKey to undo the last brush stroke.
  void undo() {
    if (_undoStack.isEmpty || _isRebuilding) return;
    final prev = _undoStack.removeLast();
    _pixelData = prev;
    _rebuildColoredImage(prev);
    setState(() {});
  }

  /// Call via GlobalKey to clear all painting.
  void clear() {
    _loadImage(widget.animalLetter);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_coloredImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) => _onPanStart(d.localPosition),
            onPanUpdate: (d) => _onPanUpdate(d.localPosition),
            onPanEnd: (_) => _onPanEnd(),
            child: CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _PixelImagePainter(
                image: _coloredImage!,
                onLayout: (rect) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _imageRect != rect) {
                      setState(() => _imageRect = rect);
                    }
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────────────────

class _PixelImagePainter extends CustomPainter {
  final ui.Image image;
  final void Function(Rect) onLayout;

  const _PixelImagePainter({required this.image, required this.onLayout});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final imgSize = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.contain, imgSize, size);
    final outputRect =
        Alignment.center.inscribe(fitted.destination, Offset.zero & size);

    onLayout(outputRect);

    paintImage(
      canvas: canvas,
      rect: outputRect,
      image: image,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _PixelImagePainter old) =>
      old.image != image;
}
