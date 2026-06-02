import 'package:flutter/material.dart';
import '../model/color_model.dart';
import '../model/level_model.dart';

/// Each animal has beautiful distinct regions defined by candidate fractional bounding boxes.
class ColoringLevelsData {
  static LevelModel getLevel(String id, int categoryId) {
    if (categoryId == 2) {
      // ── Colors Module (Always a Circle) ───────────────────────────────────
      return LevelModel(
        id: 'circle',
        title: id.substring(0, 1).toUpperCase() + id.substring(1),
        subtitle: 'Color the circle ${id.toLowerCase()}!',
        difficulty: 'Very Easy',
        rewardCoins: 50,
        recommendedBrushSize: 35.0,
        palette: [
          DrawingColorModel(
            id: id.toLowerCase(),
            label: id.substring(0, 1).toUpperCase() + id.substring(1),
            color: _getColorForId(id),
          ),
        ],
        regions: const [
          LevelRegionModel(
            id: 'circle_main',
            label: 'Circle',
            shapeType: RegionShapeType.circle,
            cx: 0.5,
            cy: 0.5,
            radius: 0.4,
            sequenceIndex: 0,
          ),
        ],
      );
    }

    // ── Handle non-animal categories (3-10) ───────────────────────────────────
    if (categoryId >= 3 && categoryId <= 10) {
      return _getLevelForNonAnimalCategory(id, categoryId);
    }

    // Default regions for other items if not specifically defined
    final List<LevelRegionModel> defaultRegions = const [
      LevelRegionModel(
        id: 'main_body',
        label: 'Body',
        shapeType: RegionShapeType.path,
        bx1: 0.05,
        by1: 0.05,
        bx2: 0.95,
        by2: 0.95,
        sequenceIndex: 0,
      ),
    ];

    // ── Handle animals (category 1) ───────────────────────────────────────────
    switch (id.toUpperCase()) {
      // ── Alligator ──────────────────────────────────────────────────────────
      case 'A':
        return LevelModel(
          id: 'alligator',
          title: 'Alligator',
          subtitle: 'Color each part of the alligator green!',
          difficulty: 'Easy',
          rewardCoins: 100,
          recommendedBrushSize: 28.0,
          palette: const [
            DrawingColorModel(
              id: 'body_green',
              label: 'Alligator Green',
              color: Color(0xFF4CAF50),
            ),
            DrawingColorModel(
              id: 'light_green',
              label: 'Light Green',
              color: Color(0xFF8BC34A),
            ),
            DrawingColorModel(
              id: 'dark_green',
              label: 'Dark Green',
              color: Color(0xFF2E7D32),
            ),
            DrawingColorModel(
              id: 'yellow',
              label: 'Belly Yellow',
              color: Color(0xFFFFEB3B),
            ),
          ],
          regions: const [
            LevelRegionModel(
              id: 'alligator_spikes',
              label: 'Back Spikes',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'dark_green',
              bx1: 0.20,
              by1: 0.15,
              bx2: 0.85,
              by2: 0.45,
              sequenceIndex: 4,
            ),
            LevelRegionModel(
              id: 'alligator_tail',
              label: 'Tail',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'light_green',
              bx1: 0.70,
              by1: 0.30,
              bx2: 0.98,
              by2: 0.80,
              sequenceIndex: 2,
            ),
            LevelRegionModel(
              id: 'alligator_legs',
              label: 'Legs',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'dark_green',
              bx1: 0.25,
              by1: 0.65,
              bx2: 0.75,
              by2: 0.98,
              sequenceIndex: 3,
            ),
            LevelRegionModel(
              id: 'alligator_head',
              label: 'Head',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'body_green',
              bx1: 0.02,
              by1: 0.20,
              bx2: 0.35,
              by2: 0.60,
              sequenceIndex: 0,
            ),
            LevelRegionModel(
              id: 'alligator_body',
              label: 'Body',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'yellow',
              bx1: 0.25,
              by1: 0.35,
              bx2: 0.75,
              by2: 0.75,
              sequenceIndex: 1,
            ),
          ],
        );

      // ── Bear ───────────────────────────────────────────────────────────────
      case 'B':
        return LevelModel(
          id: 'bear',
          title: 'Bear',
          subtitle: 'Color each part of the bear brown!',
          difficulty: 'Easy',
          rewardCoins: 80,
          recommendedBrushSize: 28.0,
          palette: const [
            DrawingColorModel(
              id: 'bear_brown',
              label: 'Bear Brown',
              color: Color(0xFF8D6E63),
            ),
            DrawingColorModel(
              id: 'light_brown',
              label: 'Light Brown',
              color: Color(0xFFBCAAA4),
            ),
            DrawingColorModel(
              id: 'dark_brown',
              label: 'Dark Brown',
              color: Color(0xFF5D4037),
            ),
            DrawingColorModel(
              id: 'cream',
              label: 'Cream',
              color: Color(0xFFFFF9C4),
            ),
          ],
          regions: const [
            LevelRegionModel(
              id: 'bear_ears',
              label: 'Ears',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'cream',
              bx1: 0.25,
              by1: 0.02,
              bx2: 0.75,
              by2: 0.22,
              sequenceIndex: 0,
            ),
            LevelRegionModel(
              id: 'bear_snout',
              label: 'Snout',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'light_brown',
              bx1: 0.38,
              by1: 0.25,
              bx2: 0.62,
              by2: 0.45,
              sequenceIndex: 2,
            ),
            LevelRegionModel(
              id: 'bear_head',
              label: 'Head',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'bear_brown',
              bx1: 0.30,
              by1: 0.10,
              bx2: 0.70,
              by2: 0.45,
              sequenceIndex: 1,
            ),
            LevelRegionModel(
              id: 'bear_legs',
              label: 'Legs',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'dark_brown',
              bx1: 0.15,
              by1: 0.65,
              bx2: 0.85,
              by2: 0.98,
              sequenceIndex: 4,
            ),
            LevelRegionModel(
              id: 'bear_body',
              label: 'Body',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'bear_brown',
              bx1: 0.20,
              by1: 0.35,
              bx2: 0.80,
              by2: 0.85,
              sequenceIndex: 3,
            ),
          ],
        );

      // ── Cat ────────────────────────────────────────────────────────────────
      case 'C':
        return LevelModel(
          id: 'cat',
          title: 'Cat',
          subtitle: 'Color each part of the cat orange!',
          difficulty: 'Easy',
          rewardCoins: 90,
          recommendedBrushSize: 28.0,
          palette: const [
            DrawingColorModel(
              id: 'orange',
              label: 'Cat Orange',
              color: Color(0xFFFF9800),
            ),
            DrawingColorModel(
              id: 'ginger',
              label: 'Ginger',
              color: Color(0xFFE65100),
            ),
            DrawingColorModel(
              id: 'peach',
              label: 'Peach',
              color: Color(0xFFFFCCBC),
            ),
            DrawingColorModel(
              id: 'white',
              label: 'White',
              color: Color(0xFFFFFFFF),
            ),
          ],
          regions: const [
            LevelRegionModel(
              id: 'cat_ears',
              label: 'Ears',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'peach',
              bx1: 0.20,
              by1: 0.02,
              bx2: 0.80,
              by2: 0.25,
              sequenceIndex: 0,
            ),
            LevelRegionModel(
              id: 'cat_tail',
              label: 'Tail',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'ginger',
              bx1: 0.68,
              by1: 0.25,
              bx2: 0.98,
              by2: 0.88,
              sequenceIndex: 3,
            ),
            LevelRegionModel(
              id: 'cat_face',
              label: 'Face',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'orange',
              bx1: 0.35,
              by1: 0.20,
              bx2: 0.65,
              by2: 0.48,
              sequenceIndex: 1,
            ),
            LevelRegionModel(
              id: 'cat_legs',
              label: 'Legs',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'white',
              bx1: 0.20,
              by1: 0.70,
              bx2: 0.80,
              by2: 0.98,
              sequenceIndex: 4,
            ),
            LevelRegionModel(
              id: 'cat_body',
              label: 'Body',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'orange',
              bx1: 0.20,
              by1: 0.15,
              bx2: 0.80,
              by2: 0.85,
              sequenceIndex: 2,
            ),
          ],
        );

      // ── Dog ────────────────────────────────────────────────────────────────
      case 'D':
        return LevelModel(
          id: 'dog',
          title: 'Dog',
          subtitle: 'Color each part of the dog golden!',
          difficulty: 'Easy',
          rewardCoins: 120,
          recommendedBrushSize: 28.0,
          palette: const [
            DrawingColorModel(
              id: 'golden',
              label: 'Golden',
              color: Color(0xFFFFB300),
            ),
            DrawingColorModel(
              id: 'fur_ginger',
              label: 'Ginger',
              color: Color(0xFFD8873A),
            ),
            DrawingColorModel(
              id: 'cream',
              label: 'Cream',
              color: Color(0xFFF7F1E6),
            ),
            DrawingColorModel(
              id: 'brown',
              label: 'Brown',
              color: Color(0xFF795548),
            ),
          ],
          regions: const [
            LevelRegionModel(
              id: 'dog_ears',
              label: 'Ears',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'brown',
              bx1: 0.15,
              by1: 0.05,
              bx2: 0.85,
              by2: 0.38,
              sequenceIndex: 0,
            ),
            LevelRegionModel(
              id: 'dog_snout',
              label: 'Snout',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'cream',
              bx1: 0.35,
              by1: 0.28,
              bx2: 0.65,
              by2: 0.52,
              sequenceIndex: 1,
            ),
            LevelRegionModel(
              id: 'dog_tail',
              label: 'Tail',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'fur_ginger',
              bx1: 0.70,
              by1: 0.25,
              bx2: 0.98,
              by2: 0.75,
              sequenceIndex: 3,
            ),
            LevelRegionModel(
              id: 'dog_legs',
              label: 'Legs',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'cream',
              bx1: 0.20,
              by1: 0.68,
              bx2: 0.80,
              by2: 0.98,
              sequenceIndex: 4,
            ),
            LevelRegionModel(
              id: 'dog_body',
              label: 'Body',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'golden',
              bx1: 0.20,
              by1: 0.15,
              bx2: 0.80,
              by2: 0.80,
              sequenceIndex: 2,
            ),
          ],
        );

      // ── Elephant ───────────────────────────────────────────────────────────
      case 'E':
        return LevelModel(
          id: 'elephant',
          title: 'Elephant',
          subtitle: 'Color each part of the elephant gray!',
          difficulty: 'Easy',
          rewardCoins: 110,
          recommendedBrushSize: 28.0,
          palette: const [
            DrawingColorModel(
              id: 'elephant_gray',
              label: 'Elephant Gray',
              color: Color(0xFF90A4AE),
            ),
            DrawingColorModel(
              id: 'light_gray',
              label: 'Light Gray',
              color: Color(0xFFCFD8DC),
            ),
            DrawingColorModel(
              id: 'dark_gray',
              label: 'Dark Gray',
              color: Color(0xFF546E7A),
            ),
            DrawingColorModel(
              id: 'pink',
              label: 'Pink',
              color: Color(0xFFF8BBD0),
            ),
          ],
          regions: const [
            LevelRegionModel(
              id: 'elephant_trunk',
              label: 'Trunk',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'light_gray',
              bx1: 0.10,
              by1: 0.04,
              bx2: 0.305,
              by2: 0.67,
              sequenceIndex: 3,
            ),
            LevelRegionModel(
              id: 'elephant_ear',
              label: 'Ear',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'pink',
              bx1: 0.10,
              by1: 0.36,
              bx2: 0.345,
              by2: 0.63,
              sequenceIndex: 1,
            ),
            LevelRegionModel(
              id: 'elephant_head',
              label: 'Head',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'elephant_gray',
              bx1: 0.31,
              by1: 0.04,
              bx2: 0.555,
              by2: 0.48,
              sequenceIndex: 0,
            ),
            LevelRegionModel(
              id: 'elephant_tail',
              label: 'Tail',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'dark_gray',
              bx1: 0.76,
              by1: 0.33,
              bx2: 0.895,
              by2: 0.63,
              sequenceIndex: 5,
            ),
            LevelRegionModel(
              id: 'elephant_legs',
              label: 'Legs',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'light_gray',
              bx1: 0.33,
              by1: 0.66,
              bx2: 0.84,
              by2: 0.95,
              sequenceIndex: 4,
            ),
            LevelRegionModel(
              id: 'elephant_body',
              label: 'Body',
              shapeType: RegionShapeType.path,
              viewBoxSize: 1000,
              svgPath: 'M 200,200 L 800,200 L 800,800 L 200,800 Z',
              targetColorId: 'elephant_gray',
              bx1: 0.29,
              by1: 0.26,
              bx2: 0.895,
              by2: 0.76,
              sequenceIndex: 2,
            ),
          ],
        );

      // ── Lion ───────────────────────────────────────────────────────────────
      case 'L':
      default:
        // Try to handle other IDs generically
        return LevelModel(
          id: id.toLowerCase(),
          title: id.length == 1
              ? id.toUpperCase()
              : id.substring(0, 1).toUpperCase() + id.substring(1),
          subtitle: 'Color the ${id.toLowerCase()}!',
          difficulty: 'Easy',
          rewardCoins: 100,
          recommendedBrushSize: 28.0,
          palette: [
            DrawingColorModel(
              id: 'main_color',
              label: 'Color',
              color: _getColorForId(id),
            ),
          ],
          regions: defaultRegions,
        );
    }
  }

  static Color _getColorForId(String id) {
    switch (id.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'apple':
        return Colors.red;
      case 'banana':
        return Colors.yellow;
      case 'grapes':
        return Colors.purple;
      case 'strawberry':
        return Colors.red;
      case 'cherry':
        return Colors.red;
      case 'watermelon':
        return Colors.green;
      case 'carrot':
        return Colors.orange;
      case 'broccoli':
        return Colors.green;
      case 'tomato':
        return Colors.red;
      case 'potato':
        return Colors.brown;
      case 'corn':
        return Colors.yellow;
      case 'eggplant':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  // ── Handle non-animal categories (Fruits, Vegetables, Shapes, etc.) ───────
  static LevelModel _getLevelForNonAnimalCategory(String id, int categoryId) {
    final lowerIdId = id.toLowerCase();

    return LevelModel(
      id: lowerIdId,
      title: id.length == 1
          ? id.toUpperCase()
          : id.substring(0, 1).toUpperCase() + id.substring(1),
      subtitle: 'Color the $lowerIdId!',
      difficulty: 'Easy',
      rewardCoins: 100,
      recommendedBrushSize: 28.0,
      palette: [
        DrawingColorModel(
          id: 'main_color',
          label: 'Color',
          color: _getColorForId(id),
        ),
      ],
      regions: const [
        LevelRegionModel(
          id: 'main_body',
          label: 'Body',
          shapeType: RegionShapeType.path,
          bx1: 0.05,
          by1: 0.05,
          bx2: 0.95,
          by2: 0.95,
          sequenceIndex: 0,
        ),
      ],
    );
  }
}
