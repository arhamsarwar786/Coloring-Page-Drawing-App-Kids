import 'package:flutter/material.dart';

abstract final class ColorParser {
  static Color fromHex(String value) {
    final cleaned = value.replaceFirst('#', '');
    final normalized = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
    return Color(int.parse(normalized, radix: 16));
  }
}
