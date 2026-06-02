import 'package:flutter/material.dart';
import 'coloring_levels_data.dart';

class AnimalPathData {
  static Path getAnimalPath(String letter, Size size, {int categoryId = 1}) {
    final path = Path();
    try {
      final level = ColoringLevelsData.getLevel(letter, categoryId);
      for (final region in level.regions) {
        path.addPath(region.toPath(size), Offset.zero);
      }
    } catch (_) {
      // Return an empty path fallback if lookups fail
    }
    return path;
  }
}
