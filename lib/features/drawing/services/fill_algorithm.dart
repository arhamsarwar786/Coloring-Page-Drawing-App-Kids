import 'package:flutter/material.dart';

import '../../levels/model/level_model.dart';

class FillAlgorithm {
  const FillAlgorithm();

  LevelRegionModel? locateRegion({
    required Offset point,
    required Size canvasSize,
    required List<LevelRegionModel> regions,
  }) {
    for (final region in regions.reversed) {
      if (region.contains(point, canvasSize)) {
        return region;
      }
    }
    return null;
  }
}
