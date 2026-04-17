import '../../../shared/services/local_content_service.dart';
import '../model/level_model.dart';

abstract class LevelRepository {
  Future<List<LevelModel>> getAllLevels();
  Future<LevelModel?> getLevelById(String levelId);
}

class LevelRepositoryImpl implements LevelRepository {
  LevelRepositoryImpl({
    required LocalContentService contentService,
  }) : _contentService = contentService;

  final LocalContentService _contentService;

  @override
  Future<List<LevelModel>> getAllLevels() {
    return _contentService.getAllLevels();
  }

  @override
  Future<LevelModel?> getLevelById(String levelId) {
    return _contentService.getLevelById(levelId);
  }
}
