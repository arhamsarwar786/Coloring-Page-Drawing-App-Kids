import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SaveService {
  const SaveService();

  Future<Uint8List?> capture(
    GlobalKey repaintKey, {
    double? pixelRatioOverride,
  }) async {
    final context = repaintKey.currentContext;
    if (context == null) {
      return null;
    }

    final boundary = context.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      return null;
    }

    final renderView = View.maybeOf(context);
    final pixelRatio = renderView?.devicePixelRatio ?? 1.0;
    // Keep captures crisp enough for the reward/share flow without generating
    // a very large bitmap that delays navigation.
    final capturePixelRatio = pixelRatioOverride ?? pixelRatio.clamp(1.0, 1.25);
    
    ui.Image? image;
    try {
      image = await boundary.toImage(pixelRatio: capturePixelRatio);
    } catch (_) {
      // If the boundary is dirty or detached, wait a bit and retry once
      await Future<void>.delayed(const Duration(milliseconds: 50));
      try {
        final newContext = repaintKey.currentContext;
        if (newContext == null) return null;
        final newBoundary = newContext.findRenderObject() as RenderRepaintBoundary?;
        if (newBoundary == null) return null;
        image = await newBoundary.toImage(pixelRatio: capturePixelRatio);
      } catch (innerError) {
        debugPrint('SaveService: Final capture retry failed: $innerError');
        return null;
      }
    }

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }
}
