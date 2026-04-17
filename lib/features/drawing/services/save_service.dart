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

    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }
}
