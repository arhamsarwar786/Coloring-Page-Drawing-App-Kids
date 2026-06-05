import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:play_craft_kids/features/coloring/model/color_model.dart';
import 'package:play_craft_kids/features/coloring/model/level_model.dart';
import 'package:play_craft_kids/features/coloring/widgets/coloring_levels_data.dart';
import 'package:play_craft_kids/features/tracing/viewmodel/activity_item.dart';

// ── ColoringProvider ────────────────────────────────────────────────────────
//
//  Free-flow pixel painting engine.
//
//  How it works:
//   1. The outline PNG is loaded and downsampled to 640×640.
//   2. Dark pixels  → `_isOutline` mask  (painting is blocked here).
//   3. BFS from all 4 image borders fills every pixel reachable without
//      crossing an outline.  Those pixels form `_isOutside`.
//   4. `_isInside = !isOutline && !isOutside`
//      Every enclosed cavity (head, ears, body, legs …) becomes its own
//      natural "region" — defined purely by the outline walls drawn in the
//      PNG, with zero manual bounding-box configuration.
//   5. When the user drags the brush, only `_isInside` pixels are painted,
//      so the colour is automatically contained within the current cavity.
//   6. The `originalOutlineImage` (full-resolution PNG) is composited on top
//      with BlendMode.multiply to keep outlines razor-sharp.
//
// ────────────────────────────────────────────────────────────────────────────

class ColoringProvider extends ChangeNotifier {
  // ── Activity state ────────────────────────────────────────────────────────
  ActivityItem? _currentItem;
  int _currentCategoryId = 1;
  LevelModel? _currentLevel;
  List<_ColoringPart> _orderedParts = const [];
  int _activeRegionIndex = 0;
  final Set<String> _completedRegionIds = <String>{};

  // ── Brush / color state ───────────────────────────────────────────────────
  Color _activeColor = Colors.red;
  List<Color> _palette = const [];
  double _brushScale = 1.0;

  // ── Score / time state ────────────────────────────────────────────────────
  int _stars = 0;
  int _scorePercentage = 0;
  final Stopwatch _stopwatch = Stopwatch();

  // ── Pixel-canvas state ────────────────────────────────────────────────────
  ui.Image? coloredImage;
  ui.Image? originalOutlineImage;

  /// Working pixel buffer that the user paints into.
  Uint32List? _pixels;

  /// Inside mask: 1 = paintable interior pixel, 0 = outline or outside.
  Uint8List? _isInside;
  Uint8List? _paintedPixels;
  Uint8List? _activeRegionMask;

  int imgWidth = 0;
  int imgHeight = 0;

  /// Undo stack — each entry is a full snapshot before a stroke.
  final List<_ColoringUndoSnapshot> _undoStack = [];
  _ColoringUndoSnapshot? _strokeSnapshot; // snapshot taken at panStart

  // ── Geometry — set by the canvas painter callback ─────────────────────────
  /// Screen-space rect where the image is actually rendered (BoxFit.contain).
  Rect imageDisplayRect = Rect.zero;

  // ── Auto-zoom preference ──────────────────────────────────────────────────
  bool _autoZoomEnabled = true;

  // ── Gesture state ─────────────────────────────────────────────────────────
  Offset? _lastImagePoint;
  bool _isDragging = false;

  // ── Rebuild throttle ──────────────────────────────────────────────────────
  bool _rebuildPending = false;
  bool _isRebuilding = false;
  DateTime _lastRebuild = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _rebuildInterval = Duration(
    milliseconds: 16,
  ); // ~60 fps

  // ── Canvas key (for completion screen capture) ────────────────────────────
  GlobalKey? canvasKey;
  ui.Image? activeRegionHighlightImage;

  // ── Public getters ────────────────────────────────────────────────────────
  ActivityItem? get currentItem => _currentItem;
  int get currentCategoryId => _currentCategoryId;
  String get currentItemId => _currentItem?.id ?? 'A';
  LevelModel? get currentLevel => _currentLevel;
  Color get activeColor => _activeColor;
  List<Color> get palette => _palette;
  int get stars => _stars;
  int get scorePercentage => _scorePercentage;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get isLoaded => coloredImage != null;
  bool get isDragging => _isDragging;
  bool get autoZoomEnabled => _autoZoomEnabled;
  int get activeRegionIndex => _activeRegionIndex;
  double get brushScale => _brushScale;
  int get brushSizePercent => (_brushScale * 100).round();
  int get totalParts => _orderedParts.length;
  int get completedParts => _completedRegionIds.length;
  bool get isPartByPartComplete =>
      _orderedParts.isNotEmpty && completedParts >= totalParts;
  _ColoringPart? get _activePart => _activeRegionIndex < _orderedParts.length
      ? _orderedParts[_activeRegionIndex]
      : null;
  String get activePartLabel => _activePart?.label ?? 'picture';
  double get activePartProgress {
    if (_activePart == null || _paintedPixels == null || _isInside == null) {
      return 1.0;
    }
    return _coverageForActiveRegion();
  }

  Rect? get activeRegionBoundsFraction {
    final region = _activePart;
    if (region == null) return null;
    return _fractionalBoundsFor(region);
  }

  String get formattedTime {
    final e = _stopwatch.elapsed;
    final m = e.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = e.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Constructor ───────────────────────────────────────────────────────────
  ColoringProvider();

  // ── Activity configuration ───────────────────────────────────────────────

  void _configureItem() {
    if (_currentItem == null) return;

    // Load palette from level data (purely for suggested colors).
    final levelData = ColoringLevelsData.getLevel(
      _currentItem!.id,
      _currentCategoryId,
    );
    _currentLevel = levelData;
    _orderedParts = const [];
    _activeRegionIndex = 0;
    _completedRegionIds.clear();
    // _brushScale = (levelData.recommendedBrushSize / 28.0).clamp(0.65, 1.7);

    // final fromLevel = levelData.palette.map((e) => e.color).toList();
    final extras = <Color>[
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
    ];
    // _palette = <Color>{...fromLevel, ...extras}.toList();

    if (_palette.isNotEmpty) {
      _activeColor = _palette.first;
    }

    _stopwatch
      ..reset()
      ..start();

    _loadImage();
  }

  void setItem(ActivityItem item, int categoryId, {dynamic level}) {
    log('----.............${item.imagePath}---....${item.id}');
    _currentItem = item;
    _currentCategoryId = categoryId;
    if (level != null) {
      _currentLevel = LevelModel(
        id: level.id as String,
        title: level.title as String,
        subtitle: level.subtitle as String,
        difficulty: level.difficulty as String,
        rewardCoins: level.rewardCoins as int,
        recommendedBrushSize: (level.recommendedBrushSize as num).toDouble(),
        palette: (level.palette as List<dynamic>).map((p) => DrawingColorModel(
          id: p.id as String,
          label: p.label as String,
          color: p.color as Color,
        )).toList(),
        regions: (level.regions as List<dynamic>).map((r) => LevelRegionModel(
          id: r.id as String,
          label: r.label as String,
          shapeType: RegionShapeType.values.firstWhere(
            (e) => e.toString().split('.').last == r.shapeType.toString().split('.').last,
            orElse: () => RegionShapeType.path,
          ),
          cx: (r.cx as num?)?.toDouble(),
          cy: (r.cy as num?)?.toDouble(),
          radius: (r.radius as num?)?.toDouble(),
          rx: (r.rx as num?)?.toDouble(),
          ry: (r.ry as num?)?.toDouble(),
          svgPath: r.svgPath as String?,
          viewBoxSize: (r.viewBoxSize as num?)?.toDouble(),
          targetColorId: r.targetColorId as String?,
          points: List<Offset>.from(r.points as List<dynamic>),
        )).toList(),
        guideAsset: level.guideAsset as String?,
        isCompleted: level.isCompleted as bool? ?? false,
        stars: level.stars as int? ?? 0,
        isFavorite: level.isFavorite as bool? ?? false,
      );

      _orderedParts = const [];
      _activeRegionIndex = 0;
      _completedRegionIds.clear();

      final fromLevel = _currentLevel!.palette.map((e) => e.color).toList();
      final extras = <Color>[
        Colors.red,
        Colors.pink,
        Colors.purple,
        Colors.deepPurple,
        Colors.indigo,
        Colors.blue,
        Colors.lightBlue,
        Colors.cyan,
        Colors.teal,
        Colors.green,
        Colors.lightGreen,
        Colors.lime,
        Colors.yellow,
        Colors.amber,
        Colors.orange,
        Colors.deepOrange,
        Colors.brown,
        Colors.grey,
        Colors.blueGrey,
        Colors.black,
        Colors.white,
      ];
      _palette = <Color>{...fromLevel, ...extras}.toList();

      if (_palette.isNotEmpty) {
        _activeColor = _palette.first;
      }

      _stopwatch
        ..reset()
        ..start();

      _loadImage();
    } else {
      _configureItem();
    }
    notifyListeners();
  }

  // ── Image loading & mask construction ─────────────────────────────────────

  Future<void> _loadImage() async {
    // if (_currentItem == null || _currentLevel == null) return;

    // Reset canvas state while loading
    coloredImage = null;
    originalOutlineImage = null;
    activeRegionHighlightImage = null;
    _pixels = null;
    _isInside = null;
    _paintedPixels = null;
    _activeRegionMask = null;
    imgWidth = 0;
    imgHeight = 0;
    _undoStack.clear();
    notifyListeners();

    // Use the resolved level ID for the asset name
    // Use the imagePath from the current ActivityItem if provided; otherwise fallback to dolphin.
    final assetPath =
        _currentItem?.imagePath ?? 'assets/images/un_colored_dolphin.webp';

    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();

      // ── Full-resolution outline for the top-layer overlay ────────────────
      final fullCodec = await ui.instantiateImageCodec(bytes);
      final fullFrame = await fullCodec.getNextFrame();
      originalOutlineImage = fullFrame.image;

      // ── 640×640 working canvas ───────────────────────────────────────────
      const kCanvasSize = 640;
      final thumbCodec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: kCanvasSize,
        targetHeight: kCanvasSize,
      );
      final thumbFrame = await thumbCodec.getNextFrame();
      final thumbImg = thumbFrame.image;

      final bd = await thumbImg.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bd == null) return;

      final rawPixels = bd.buffer.asUint32List();
      final w = kCanvasSize;
      final h = kCanvasSize;
      imgWidth = w;
      imgHeight = h;

      // ── Step 1: Detect outline pixels ────────────────────────────────────
      final outlineMask = Uint8List(w * h);
      for (int i = 0; i < rawPixels.length; i++) {
        if (_isOutlinePixel(rawPixels[i])) outlineMask[i] = 1;
      }

      // ── Step 2: BFS from border → mark outside pixels ────────────────────
      final outsideMask = Uint8List(w * h);
      final queue = <int>[];

      void enqueue(int x, int y) {
        final idx = y * w + x;
        if (outlineMask[idx] == 1 || outsideMask[idx] == 1) return;
        outsideMask[idx] = 1;
        queue.add(idx);
      }

      for (int x = 0; x < w; x++) {
        enqueue(x, 0);
        enqueue(x, h - 1);
      }
      for (int y = 0; y < h; y++) {
        enqueue(0, y);
        enqueue(w - 1, y);
      }

      int head = 0;
      while (head < queue.length) {
        final idx = queue[head++];
        final x = idx % w;
        final y = idx ~/ w;
        if (x > 0) enqueue(x - 1, y);
        if (x < w - 1) enqueue(x + 1, y);
        if (y > 0) enqueue(x, y - 1);
        if (y < h - 1) enqueue(x, y + 1);
      }

      // ── Step 3: Inside = not outline AND not outside ──────────────────────
      final insideMask = Uint8List(w * h);
      for (int i = 0; i < w * h; i++) {
        if (outlineMask[i] == 0 && outsideMask[i] == 0) {
          insideMask[i] = 1;
        }
      }
      _isInside = insideMask;
      _orderedParts = _buildExactPartsFromImage(insideMask, w, h);

      // ── Step 4: Build clean white canvas (transparent bg, white inside) ──
      final cleanPixels = Uint32List(w * h);
      for (int i = 0; i < rawPixels.length; i++) {
        final a = (rawPixels[i] >> 24) & 0xFF;
        if (a < 128) {
          cleanPixels[i] = 0x00000000; // transparent background
        } else {
          cleanPixels[i] = 0xFFFFFFFF; // white paintable interior
        }
      }
      _pixels = cleanPixels;
      _paintedPixels = Uint8List(w * h);
      await _refreshActiveRegionMask();

      await _rebuildColoredImage(_pixels!);
      notifyListeners();
    } catch (e) {
      debugPrint('ColoringProvider: failed to load "$assetPath" – $e');
      // Fallback: Create a simple white circle image for coloring
      await _createFallbackImage();
    }
  }

  /// Creates a fallback white circle image when the asset fails to load
  Future<void> _createFallbackImage() async {
    const kCanvasSize = 640;
    const kRadius = kCanvasSize / 2.5;
    const centerX = kCanvasSize / 2;
    const centerY = kCanvasSize / 2;

    // Create white circle pixels
    final pixels = Uint32List(kCanvasSize * kCanvasSize);
    for (int y = 0; y < kCanvasSize; y++) {
      for (int x = 0; x < kCanvasSize; x++) {
        final dx = x - centerX;
        final dy = y - centerY;
        final distanceFromCenter = math.sqrt(dx * dx + dy * dy);

        final idx = y * kCanvasSize + x;
        if (distanceFromCenter <= kRadius) {
          pixels[idx] = 0xFFFFFFFF; // White inside circle
        } else {
          pixels[idx] = 0x00000000; // Transparent outside
        }
      }
    }

    // Create a simple outline for the circle (dark gray border)
    final outlineMask = Uint8List(kCanvasSize * kCanvasSize);
    for (int y = 0; y < kCanvasSize; y++) {
      for (int x = 0; x < kCanvasSize; x++) {
        final dx = x - centerX;
        final dy = y - centerY;
        final distanceFromCenter = math.sqrt(dx * dx + dy * dy);
        final idx = y * kCanvasSize + x;

        // Mark border pixels as outline
        if (distanceFromCenter >= kRadius - 5 &&
            distanceFromCenter <= kRadius + 5) {
          outlineMask[idx] = 1;
        }
      }
    }

    // Create inside mask
    final insideMask = Uint8List(kCanvasSize * kCanvasSize);
    for (int i = 0; i < pixels.length; i++) {
      if ((pixels[i] >> 24) & 0xFF > 100 && outlineMask[i] == 0) {
        insideMask[i] = 1;
      }
    }

    _isInside = insideMask;
    _pixels = pixels;
    _paintedPixels = Uint8List(kCanvasSize * kCanvasSize);
    imgWidth = kCanvasSize;
    imgHeight = kCanvasSize;
    _orderedParts = [
      _ColoringPart(
        id: 'circle_main',
        label: 'Circle',
        targetColorId: 'main_color',
        sequenceIndex: 0,
        bounds: const Rect.fromLTWH(0.2, 0.2, 0.6, 0.6),
        pixels: pixels,
      ),
    ];
    _activeRegionIndex = 0;
    _completedRegionIds.clear();

    // Create simple circle outline image
    final circlePixels = Uint32List(kCanvasSize * kCanvasSize);
    for (int i = 0; i < circlePixels.length; i++) {
      if (outlineMask[i] == 1) {
        circlePixels[i] = 0xFF1E1E24; // Dark outline
      } else {
        circlePixels[i] = 0x00000000; // Transparent
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      circlePixels.buffer.asUint8List(),
      kCanvasSize,
      kCanvasSize,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    originalOutlineImage = await completer.future;

    await _refreshActiveRegionMask();
    await _rebuildColoredImage(_pixels!);
    notifyListeners();
  }

  // ── Pixel helpers ─────────────────────────────────────────────────────────

  /// Returns true if the RGBA pixel is a dark outline line.
  bool _isOutlinePixel(int rgba) {
    final r = rgba & 0xFF;
    final g = (rgba >> 8) & 0xFF;
    final b = (rgba >> 16) & 0xFF;
    final a = (rgba >> 24) & 0xFF;
    return a > 100 && r < 110 && g < 110 && b < 110;
  }

  int _colorToRgba(Color c, int alpha) {
    final r = (c.r * 255).round() & 0xFF;
    final g = (c.g * 255).round() & 0xFF;
    final b = (c.b * 255).round() & 0xFF;
    return (alpha & 0xFF) << 24 | (b << 16) | (g << 8) | r;
  }

  Rect _fractionalBoundsFor(_ColoringPart part) {
    return part.bounds;
  }

  bool _isPixelInActiveRegion(int x, int y) {
    final mask = _activeRegionMask;
    if (mask == null || imgWidth == 0 || imgHeight == 0) return false;
    if (x < 0 || y < 0 || x >= imgWidth || y >= imgHeight) return false;
    return mask[y * imgWidth + x] == 1;
  }

  Offset? _nearestActiveRegionPoint(int cx, int cy) {
    if (_isPixelInActiveRegion(cx, cy)) {
      return Offset(cx.toDouble(), cy.toDouble());
    }

    final mask = _activeRegionMask;
    if (mask == null || imgWidth == 0 || imgHeight == 0) return null;

    // Reduced radius: user must place finger very close to the actual part
    final radius = math.max(
      (_brushRadius * 1.5).round(),
      (imgWidth * 0.03).round(),
    );
    final minX = math.max(0, cx - radius);
    final maxX = math.min(imgWidth - 1, cx + radius);
    final minY = math.max(0, cy - radius);
    final maxY = math.min(imgHeight - 1, cy + radius);
    final rSq = radius * radius;
    var bestDistSq = rSq + 1;
    Offset? bestPoint;

    for (int y = minY; y <= maxY; y++) {
      for (int x = minX; x <= maxX; x++) {
        if (mask[y * imgWidth + x] != 1) continue;
        final dx = x - cx;
        final dy = y - cy;
        final distSq = dx * dx + dy * dy;
        if (distSq > rSq || distSq >= bestDistSq) continue;
        bestDistSq = distSq;
        bestPoint = Offset(x.toDouble(), y.toDouble());
      }
    }

    return bestPoint;
  }

  List<_ColoringPart> _buildExactPartsFromImage(
    Uint8List insideMask,
    int width,
    int height,
  ) {
    final level = _currentLevel;
    if (level == null) return const <_ColoringPart>[];

    final visited = Uint8List(width * height);
    final stack = <int>[];
    final parts = <_ColoringPart>[];
    var componentNumber = 0;

    for (int start = 0; start < insideMask.length; start++) {
      if (insideMask[start] != 1 || visited[start] == 1) continue;

      stack
        ..clear()
        ..add(start);
      visited[start] = 1;
      final pixels = <int>[];
      var minX = width - 1;
      var maxX = 0;
      var minY = height - 1;
      var maxY = 0;

      while (stack.isNotEmpty) {
        final idx = stack.removeLast();
        pixels.add(idx);
        final x = idx % width;
        final y = idx ~/ width;
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
        minY = math.min(minY, y);
        maxY = math.max(maxY, y);

        void enqueue(int nx, int ny) {
          if (nx < 0 || ny < 0 || nx >= width || ny >= height) return;
          final ni = ny * width + nx;
          if (visited[ni] == 1 || insideMask[ni] != 1) return;
          visited[ni] = 1;
          stack.add(ni);
        }

        enqueue(x - 1, y);
        enqueue(x + 1, y);
        enqueue(x, y - 1);
        enqueue(x, y + 1);
      }

      if (pixels.length < 45) continue;

      final componentBounds = Rect.fromLTRB(
        minX / width,
        minY / height,
        (maxX + 1) / width,
        (maxY + 1) / height,
      );
      final matchedRegion = _bestRegionForBounds(
        componentBounds,
        level.regions,
      );
      final label = _labelForComponent(
        componentBounds,
        pixels.length / (width * height),
        matchedRegion,
      );
      final sequence = _sequenceForComponent(label, matchedRegion, minY, minX);

      parts.add(
        _ColoringPart(
          id: 'part_${componentNumber++}',
          label: label,
          targetColorId: matchedRegion?.targetColorId,
          sequenceIndex: sequence,
          bounds: componentBounds,
          pixels: Uint32List.fromList(pixels),
        ),
      );
    }

    parts.sort((a, b) {
      final sequenceCompare = a.sequenceIndex.compareTo(b.sequenceIndex);
      if (sequenceCompare != 0) return sequenceCompare;
      final yCompare = a.bounds.top.compareTo(b.bounds.top);
      if (yCompare != 0) return yCompare;
      return a.bounds.left.compareTo(b.bounds.left);
    });
    return List<_ColoringPart>.unmodifiable(parts);
  }

  LevelRegionModel? _bestRegionForBounds(
    Rect componentBounds,
    List<LevelRegionModel> regions,
  ) {
    LevelRegionModel? bestRegion;
    var bestScore = 0.0;

    for (final region in regions) {
      final regionBounds = Rect.fromLTRB(
        (region.bx1 ?? 0).clamp(0.0, 1.0),
        (region.by1 ?? 0).clamp(0.0, 1.0),
        (region.bx2 ?? 1).clamp(0.0, 1.0),
        (region.by2 ?? 1).clamp(0.0, 1.0),
      );
      final overlap = componentBounds.intersect(regionBounds);
      if (overlap.isEmpty) continue;
      final overlapArea = overlap.width * overlap.height;
      final componentArea = componentBounds.width * componentBounds.height;
      final score = componentArea == 0 ? 0.0 : overlapArea / componentArea;
      if (score > bestScore) {
        bestScore = score;
        bestRegion = region;
      }
    }

    return bestScore <= 0 ? null : bestRegion;
  }

  String _labelForComponent(
    Rect bounds,
    double areaFraction,
    LevelRegionModel? matchedRegion,
  ) {
    final cx = bounds.center.dx;
    final cy = bounds.center.dy;
    final label = matchedRegion?.label;

    if (areaFraction < 0.012 && cy < 0.46) return 'Eyes';
    if (areaFraction < 0.012 && cy < 0.62 && cx > 0.28 && cx < 0.72) {
      return 'Nose';
    }
    if (areaFraction < 0.006) return 'Details';
    return label ?? 'Part';
  }

  int _sequenceForComponent(
    String label,
    LevelRegionModel? matchedRegion,
    int minY,
    int minX,
  ) {
    final lower = label.toLowerCase();
    if (lower.contains('eye')) return -30 + minX;
    if (lower.contains('face') || lower.contains('head')) return -20 + minY;
    if (lower.contains('nose') || lower.contains('snout')) return -10 + minY;
    return (matchedRegion?.sequenceIndex ?? 50) * 1000 + minY + minX;
  }

  double _coverageForActiveRegion() {
    final mask = _activeRegionMask;
    final painted = _paintedPixels;
    final px = _pixels;
    final region = _activePart;
    if (mask == null || painted == null || px == null || region == null || imgWidth == 0 || imgHeight == 0) {
      return 0.0;
    }

    int? expectedRgba;
    if (region.targetColorId != null && _currentLevel != null) {
      for (final p in _currentLevel!.palette) {
        if (p.id == region.targetColorId) {
          expectedRgba = _colorToRgba(p.color, 220);
          break;
        }
      }
    }

    var coverable = 0;
    var correctCount = 0;
    for (int idx = 0; idx < mask.length; idx++) {
      if (mask[idx] != 1) continue;
      coverable += 1;
      if (painted[idx] == 1) {
        if (expectedRgba != null) {
          if (px[idx] == expectedRgba) {
            correctCount += 1;
          }
        } else {
          correctCount += 1;
        }
      }
    }

    if (coverable == 0) return 1.0;
    return (correctCount / coverable).clamp(0.0, 1.0);
  }

  Future<void> _refreshActiveRegionMask() async {
    _activeRegionMask = _buildActiveRegionMask();
    activeRegionHighlightImage = await _buildHighlightImage(_activeRegionMask);
  }

  Uint8List? _buildActiveRegionMask() {
    final part = _activePart;
    if (part == null || imgWidth == 0 || imgHeight == 0) {
      return null;
    }

    final mask = Uint8List(imgWidth * imgHeight);
    for (final idx in part.pixels) {
      mask[idx] = 1;
    }
    return mask;
  }

  Future<ui.Image?> _buildHighlightImage(Uint8List? mask) async {
    if (mask == null || imgWidth == 0 || imgHeight == 0) return null;

    final pixels = Uint32List(imgWidth * imgHeight);

    // Modern Guide Rule: Crisp, precise neon outline
    // We use a beautiful, modern neon primary purple
    const outlineColor = Color(0xFF7B3FE4);
    final thickness = math.max(2, (imgWidth / 640.0 * 3.5).round());

    for (int y = 0; y < imgHeight; y++) {
      for (int x = 0; x < imgWidth; x++) {
        final idx = y * imgWidth + x;
        if (mask[idx] != 1) continue;

        // Check if this pixel is close to an edge
        bool isEdge = false;
        for (int dy = -thickness; dy <= thickness; dy++) {
          for (int dx = -thickness; dx <= thickness; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= imgWidth || ny >= imgHeight) {
              isEdge = true;
              break;
            }
            if (mask[ny * imgWidth + nx] != 1) {
              isEdge = true;
              break;
            }
          }
          if (isEdge) break;
        }

        if (isEdge) {
          pixels[idx] = _colorToRgba(outlineColor, 255);
        }
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels.buffer.asUint8List(),
      imgWidth,
      imgHeight,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  bool _isTransitioningPart = false;

  void _fillRemainingActiveRegion() {
    final px = _pixels;
    final inside = _isInside;
    final painted = _paintedPixels;
    final region = _activePart;
    if (px == null || inside == null || painted == null || region == null) {
      return;
    }

    final fill = _colorToRgba(_activeColor, 220);

    for (final idx in region.pixels) {
      if (painted[idx] != 1 || px[idx] != fill) {
        px[idx] = fill;
        painted[idx] = 1;
      }
    }

    _scheduleRebuild();
  }

  void _advancePartIfReady() {
    if (_isTransitioningPart) return;

    final region = _activePart;
    if (region == null) return;

    // Modern kid's UX rule: When 95% coverage is reached, auto-fill the rest of only that part!
    if (_coverageForActiveRegion() < 0.98) return;

    _fillRemainingActiveRegion();

    _completedRegionIds.add(region.id);
    _activeRegionIndex += 1;
    _isTransitioningPart = true;

    Future.microtask(() async {
      await _refreshActiveRegionMask();
      notifyListeners();
    });

    Future.delayed(const Duration(seconds: 1), () {
      _isTransitioningPart = false;
      notifyListeners();
    });
  }

  _ColoringUndoSnapshot _createUndoSnapshot() {
    return _ColoringUndoSnapshot(
      pixels: Uint32List.fromList(_pixels!),
      paintedPixels: Uint8List.fromList(_paintedPixels!),
      activeRegionIndex: _activeRegionIndex,
      completedRegionIds: Set<String>.from(_completedRegionIds),
    );
  }

  void _restoreUndoSnapshot(_ColoringUndoSnapshot snapshot) {
    _pixels = Uint32List.fromList(snapshot.pixels);
    _paintedPixels = Uint8List.fromList(snapshot.paintedPixels);
    _activeRegionIndex = snapshot.activeRegionIndex;
    _completedRegionIds
      ..clear()
      ..addAll(snapshot.completedRegionIds);
    Future.microtask(() async {
      await _refreshActiveRegionMask();
      notifyListeners();
    });
  }

  // ── Coordinate mapping ────────────────────────────────────────────────────

  /// Converts a local-canvas point (in widget space) to image-pixel space
  /// using the [imageDisplayRect] reported by [ColoringPainter].
  Offset? _toImageCoords(Offset local) {
    if (imageDisplayRect.isEmpty || imgWidth == 0) return null;
    final x =
        (local.dx - imageDisplayRect.left) * imgWidth / imageDisplayRect.width;
    final y =
        (local.dy - imageDisplayRect.top) * imgHeight / imageDisplayRect.height;
    if (x < 0 || y < 0 || x >= imgWidth || y >= imgHeight) return null;
    return Offset(x, y);
  }

  // ── Brush painting ────────────────────────────────────────────────────────

  /// Radius in image-pixel space — scales with canvas resolution.
  int get _brushRadius =>
      math.max(5, (imgWidth / 640.0 * 18 * _brushScale).round());

  /// Paint a filled-circle dab at [cx],[cy].  Only `_isInside` pixels are
  /// ever coloured, so paint cannot cross an outline wall.
  void _paintDab(int cx, int cy) {
    final px = _pixels;
    final inside = _isInside;
    final painted = _paintedPixels;
    final region = _activePart;
    if (px == null || inside == null || painted == null || region == null) {
      return;
    }

    final fill = _colorToRgba(_activeColor, 220);
    final r = _brushRadius;
    final rSq = r * r;

    for (int dy = -r; dy <= r; dy++) {
      for (int dx = -r; dx <= r; dx++) {
        if (dx * dx + dy * dy > rSq) continue;
        final nx = cx + dx;
        final ny = cy + dy;
        if (nx < 0 || ny < 0 || nx >= imgWidth || ny >= imgHeight) continue;
        final idx = ny * imgWidth + nx;
        if (inside[idx] != 1 || !_isPixelInActiveRegion(nx, ny)) continue;
        px[idx] = fill;
        painted[idx] = 1;
      }
    }
  }

  /// Interpolate dabs between [from] and [to] so fast strokes have no gaps.
  void _paintLine(Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final steps = (dist / (_brushRadius * 0.4)).ceil().clamp(1, 512);
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      _paintDab((from.dx + dx * t).round(), (from.dy + dy * t).round());
    }
  }

  // ── Gesture handlers (called from CanvasWidget) ───────────────────────────

  void handlePanStart(Offset localPos) {
    if (_isTransitioningPart) return;
    final region = _activePart;
    if (_pixels == null ||
        _isInside == null ||
        _paintedPixels == null ||
        region == null) {
      return;
    }
    final p = _toImageCoords(localPos);
    if (p == null) return;
    final px = p.dx.round();
    final py = p.dy.round();
    final snapPoint = _nearestActiveRegionPoint(px, py);
    if (snapPoint == null) return;
    final paintPoint = snapPoint;
    _strokeSnapshot = _createUndoSnapshot();
    _lastImagePoint = paintPoint;
    _isDragging = true;
    _paintDab(paintPoint.dx.round(), paintPoint.dy.round());
    _scheduleRebuild();
  }

  void handlePanUpdate(Offset localPos) {
    if (_isTransitioningPart || !_isDragging || _pixels == null) return;
    final p = _toImageCoords(localPos);
    if (p == null) return;
    final paintPoint =
        _nearestActiveRegionPoint(p.dx.round(), p.dy.round()) ?? p;
    if (_lastImagePoint != null) {
      _paintLine(_lastImagePoint!, paintPoint);
    } else {
      _paintDab(paintPoint.dx.round(), paintPoint.dy.round());
    }
    _lastImagePoint = paintPoint;
    _scheduleRebuild();
    // Check coverage in real-time: auto-advance the moment 85% is reached
    // while the user is still painting — no need to lift the finger.
    _advancePartIfReady();
  }

  void handlePanEnd() {
    _isDragging = false;
    _lastImagePoint = null;
    if (_strokeSnapshot != null) {
      _undoStack.add(_strokeSnapshot!);
      if (_undoStack.length > 25) _undoStack.removeAt(0);
      _strokeSnapshot = null;
    }
    _advancePartIfReady();
    _flushRebuild();
    notifyListeners();
  }

  // ── Undo / Clear ──────────────────────────────────────────────────────────

  void undo() {
    if (_undoStack.isEmpty || _isRebuilding) return;
    _restoreUndoSnapshot(_undoStack.removeLast());
    _flushRebuild();
    notifyListeners();
  }

  void retry() {
    _stars = 0;
    _scorePercentage = 0;
    _undoStack.clear();
    _strokeSnapshot = null;
    _activeRegionIndex = 0;
    _completedRegionIds.clear();

    _stopwatch
      ..reset()
      ..start();
    _loadImage();
  }

  // ── Color ─────────────────────────────────────────────────────────────────

  void changeColor(Color color) {
    _activeColor = color;
    notifyListeners();
  }

  void changeBrushScale(double value) {
    _brushScale = value.clamp(0.45, 2.0);
    notifyListeners();
  }

  void setAutoZoomEnabled(bool enabled) {
    if (_autoZoomEnabled == enabled) return;
    _autoZoomEnabled = enabled;
    notifyListeners();
  }

  // ── Score ─────────────────────────────────────────────────────────────────

  void calculateScore() {
    _stopwatch.stop();
    final secs = _stopwatch.elapsed.inSeconds;
    if (secs >= 30) {
      _stars = 3;
      _scorePercentage = 100;
    } else if (secs >= 15) {
      _stars = 2;
      _scorePercentage = 80;
    } else {
      _stars = 1;
      _scorePercentage = 60;
    }
    notifyListeners();
  }

  // ── Masterpiece capture ───────────────────────────────────────────────────

  /// Composites the painted pixel canvas with the crisp outline on top and
  /// returns the final high-quality image for the completion screen.
  Future<ui.Image> captureMasterpiece(Size size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFFFFEFB),
    );

    if (coloredImage != null) {
      final imgSize = Size(
        coloredImage!.width.toDouble(),
        coloredImage!.height.toDouble(),
      );
      final fitted = applyBoxFit(BoxFit.contain, imgSize, size);
      final imageRect = Alignment.center.inscribe(
        fitted.destination,
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: coloredImage!,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      );

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

    final picture = recorder.endRecording();
    return picture.toImage(size.width.toInt(), size.height.toInt());
  }

  // ── Rebuild throttle ──────────────────────────────────────────────────────

  void _scheduleRebuild() {
    if (_isRebuilding) {
      _rebuildPending = true;
      return;
    }

    final now = DateTime.now();
    if (!_rebuildPending &&
        now.difference(_lastRebuild) >= _rebuildInterval &&
        !_isRebuilding) {
      _lastRebuild = now;
      _rebuildPending = true;
      Future.microtask(() async {
        _rebuildPending = false;
        if (_pixels != null) await _rebuildColoredImage(_pixels!);
      });
    }
  }

  void _flushRebuild() {
    if (_isRebuilding) {
      _rebuildPending = true;
      return;
    }
    if (_pixels != null) _rebuildColoredImage(_pixels!);
  }

  Future<void> _rebuildColoredImage(Uint32List pixels) async {
    if (_isRebuilding || imgWidth == 0) {
      _rebuildPending = true;
      return;
    }
    _isRebuilding = true;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      Uint32List.fromList(pixels).buffer.asUint8List(),
      imgWidth,
      imgHeight,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    coloredImage = await completer.future;
    _isRebuilding = false;
    notifyListeners();

    if (_rebuildPending && _pixels != null) {
      _rebuildPending = false;
      await _rebuildColoredImage(_pixels!);
    }
  }
}

class _ColoringUndoSnapshot {
  const _ColoringUndoSnapshot({
    required this.pixels,
    required this.paintedPixels,
    required this.activeRegionIndex,
    required this.completedRegionIds,
  });

  final Uint32List pixels;
  final Uint8List paintedPixels;
  final int activeRegionIndex;
  final Set<String> completedRegionIds;
}

class _ColoringPart {
  const _ColoringPart({
    required this.id,
    required this.label,
    required this.targetColorId,
    required this.sequenceIndex,
    required this.bounds,
    required this.pixels,
  });

  final String id;
  final String label;
  final String? targetColorId;
  final int sequenceIndex;
  final Rect bounds;
  final Uint32List pixels;
}
