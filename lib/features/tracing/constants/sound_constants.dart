import 'package:play_craft_kids/features/tracing/constants/app_sounds.dart';

/// Sound category enum for organizing learning content
enum SoundCategory { animals, seaAnimals, vehicles, birds }

/// Extension for user-friendly category names
extension SoundCategoryExt on SoundCategory {
  String get displayName {
    return switch (this) {
      SoundCategory.animals => 'Animals',
      SoundCategory.seaAnimals => 'Sea Animals',
      SoundCategory.vehicles => 'Vehicles',
      SoundCategory.birds => 'Birds',
    };
  }

  String get icon {
    return switch (this) {
      SoundCategory.animals => '🦁',
      SoundCategory.seaAnimals => '🐠',
      SoundCategory.vehicles => '🚗',
      SoundCategory.birds => '🦅',
    };
  }
}

/// Map activity category IDs into sound learning categories.
/// These IDs come from the activity item selection flow and
/// allow sound learning to use compatible category data.
SoundCategory soundCategoryFromActivityId(int categoryId) {
  return switch (categoryId) {
    1 => SoundCategory.animals,
    8 => SoundCategory.vehicles,
    9 => SoundCategory.birds,
    10 => SoundCategory.seaAnimals,
    _ => SoundCategory.animals,
  };
}

/// Sound item data class for organizing individual sounds
class SoundItemData {
  final String id;
  final String name;
  final String soundPath;
  final String imageAsset;

  const SoundItemData({
    required this.id,
    required this.name,
    required this.soundPath,
    required this.imageAsset,
  });
}

/// Central repository for all categorized sound learning items
class SoundLearningData {
  SoundLearningData._();

  /// Get all sounds for a specific category
  static List<SoundItemData> getSoundsByCategory(SoundCategory category) {
    return switch (category) {
      SoundCategory.animals => _animalSounds,
      SoundCategory.seaAnimals => _seaAnimalSounds,
      SoundCategory.vehicles => _vehicleSounds,
      SoundCategory.birds => _birdSounds,
    };
  }

  /// Get all available categories
  static List<SoundCategory> getAllCategories() {
    return SoundCategory.values;
  }

  /// Get sound item by ID and category
  static SoundItemData? getSoundItemById(SoundCategory category, String id) {
    final sounds = getSoundsByCategory(category);
    try {
      return sounds.firstWhere((sound) => sound.id == id);
    } catch (e) {
      return null;
    }
  }

  // ===================== Animals Sounds =====================
  static const List<SoundItemData> _animalSounds = [
    SoundItemData(
      id: 'alligator',
      name: 'Alligator',
      soundPath: AppSounds.alligatorSound,
      imageAsset: 'assets/images/animals/alligator.png',
    ),
    SoundItemData(
      id: 'bear',
      name: 'Bear',
      soundPath: AppSounds.bearSound,
      imageAsset: 'assets/images/animals/bear.png',
    ),
    SoundItemData(
      id: 'cat',
      name: 'Cat',
      soundPath: AppSounds.catSound,
      imageAsset: 'assets/images/animals/cat.png',
    ),
    SoundItemData(
      id: 'dog',
      name: 'Dog',
      soundPath: AppSounds.dogSound,
      imageAsset: 'assets/images/animals/dog.png',
    ),
    SoundItemData(
      id: 'elephant',
      name: 'Elephant',
      soundPath: AppSounds.elephantSound,
      imageAsset: 'assets/images/animals/elephant.png',
    ),
    SoundItemData(
      id: 'lion',
      name: 'Lion',
      soundPath: AppSounds.lionSound,
      imageAsset: 'assets/images/animals/lion.png',
    ),
    SoundItemData(
      id: 'monkey',
      name: 'Monkey',
      soundPath: AppSounds.misMonkey,
      imageAsset: 'assets/images/animals/monkey.png',
    ),
    SoundItemData(
      id: 'zebra',
      name: 'Zebra',
      soundPath: AppSounds.zisZebra,
      imageAsset: 'assets/images/animals/zebra.png',
    ),
  ];

  // ===================== Sea Animals Sounds =====================
  static const List<SoundItemData> _seaAnimalSounds = [
    SoundItemData(
      id: 'fish',
      name: 'Fish',
      soundPath: AppSounds.fishSound,
      imageAsset: 'assets/images/sea_animals/fish.png',
    ),
    SoundItemData(
      id: 'dolphin',
      name: 'Dolphin',
      soundPath: AppSounds.dolphinSound,
      imageAsset: 'assets/images/sea_animals/dolphin.png',
    ),
    SoundItemData(
      id: 'octopus',
      name: 'Octopus',
      soundPath: AppSounds.octopusSound,
      imageAsset: 'assets/images/sea_animals/octopus.png',
    ),
    SoundItemData(
      id: 'whale',
      name: 'Whale',
      soundPath: AppSounds.whaleSound,
      imageAsset: 'assets/images/sea_animals/whale.png',
    ),
    SoundItemData(
      id: 'shark',
      name: 'Shark',
      soundPath: AppSounds.sharkSound,
      imageAsset: 'assets/images/sea_animals/shark.png',
    ),
    SoundItemData(
      id: 'crab',
      name: 'Crab',
      soundPath: AppSounds.crabSound,
      imageAsset: 'assets/images/sea_animals/crab.png',
    ),
    SoundItemData(
      id: 'jellyfish',
      name: 'Jellyfish',
      soundPath: AppSounds.jisJellyfish,
      imageAsset: 'assets/images/sea_animals/jellyfish.png',
    ),
  ];

  // ===================== Vehicles Sounds =====================
  static const List<SoundItemData> _vehicleSounds = [
    SoundItemData(
      id: 'car',
      name: 'Car',
      soundPath: AppSounds.carSound,
      imageAsset: 'assets/images/vehicles/car.png',
    ),
    SoundItemData(
      id: 'bus',
      name: 'Bus',
      soundPath: AppSounds.busSound,
      imageAsset: 'assets/images/vehicles/bus.png',
    ),
    SoundItemData(
      id: 'train',
      name: 'Train',
      soundPath: AppSounds.trainSound,
      imageAsset: 'assets/images/vehicles/train.png',
    ),
    SoundItemData(
      id: 'plane',
      name: 'Plane',
      soundPath: AppSounds.planeSound,
      imageAsset: 'assets/images/vehicles/plane.png',
    ),
    SoundItemData(
      id: 'bicycle',
      name: 'Bicycle',
      soundPath: AppSounds.bicycleSound,
      imageAsset: 'assets/images/vehicles/bicycle.png',
    ),
    SoundItemData(
      id: 'truck',
      name: 'Truck',
      soundPath: AppSounds.truckSound,
      imageAsset: 'assets/images/vehicles/truck.png',
    ),
  ];

  // ===================== Birds Sounds =====================
  static const List<SoundItemData> _birdSounds = [
    SoundItemData(
      id: 'owl',
      name: 'Owl',
      soundPath: AppSounds.owlSound,
      imageAsset: 'assets/images/birds/owl.png',
    ),
    SoundItemData(
      id: 'duck',
      name: 'Duck',
      soundPath: AppSounds.duckSound,
      imageAsset: 'assets/images/birds/duck.png',
    ),
    SoundItemData(
      id: 'penguin',
      name: 'Penguin',
      soundPath: AppSounds.penguinSound,
      imageAsset: 'assets/images/birds/penguin.png',
    ),
    SoundItemData(
      id: 'eagle',
      name: 'Eagle',
      soundPath: AppSounds.eagleSound,
      imageAsset: 'assets/images/birds/eagle.png',
    ),
    SoundItemData(
      id: 'parrot',
      name: 'Parrot',
      soundPath: AppSounds.parrotSound,
      imageAsset: 'assets/images/birds/parrot.png',
    ),
    SoundItemData(
      id: 'peacock',
      name: 'Peacock',
      soundPath: AppSounds.peacockSound,
      imageAsset: 'assets/images/birds/peacock.png',
    ),
  ];
}
