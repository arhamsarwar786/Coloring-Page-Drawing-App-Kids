import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SaveService {
  const SaveService();

  Future<Uint8List?> capture(GlobalKey repaintKey) async {
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
    final capturePixelRatio = pixelRatio.clamp(1.0, 1.25);

    final image = await boundary.toImage(pixelRatio: capturePixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }
}
