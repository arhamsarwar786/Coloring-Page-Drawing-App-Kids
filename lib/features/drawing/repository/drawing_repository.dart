import '../../../shared/services/local_content_service.dart';
import '../../levels/model/level_model.dart';

abstract class DrawingRepository {
  Future<String?> getLaunchLevelId();
  Future<LevelModel?> getLevelById(String levelId);
  Future<int?> getLevelNumber(String levelId);
  Future<String?> getNextLevelId(String levelId);
  Future<void> saveLastPlayedLevel(String levelId);
  Future<void> markLevelCompleted({
    required String levelId,
    required int stars,
    required int rewardCoins,
  });
}

class DrawingRepositoryImpl implements DrawingRepository {
  DrawingRepositoryImpl({
    required LocalContentService contentService,
  }) : _contentService = contentService;

  final LocalContentService _contentService;

  @override
  Future<String?> getLaunchLevelId() {
    return _contentService.getLaunchLevelId();
  }

  @override
  Future<LevelModel?> getLevelById(String levelId) {
    return _contentService.getLevelById(levelId);
  }

  @override
  Future<int?> getLevelNumber(String levelId) {
    return _contentService.getLevelNumber(levelId);
  }

  @override
  Future<String?> getNextLevelId(String levelId) {
    return _contentService.getNextLevelId(levelId);
  }

  @override
  Future<void> saveLastPlayedLevel(String levelId) {
    return _contentService.saveLastPlayedLevel(levelId);
  }

  @override
  Future<void> markLevelCompleted({
    required String levelId,
    required int stars,
    required int rewardCoins,
  }) {
    return _contentService.markLevelCompleted(
      levelId: levelId,
      stars: stars,
      rewardCoins: rewardCoins,
    );
  }
}
