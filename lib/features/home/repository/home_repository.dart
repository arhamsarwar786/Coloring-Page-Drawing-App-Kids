import '../../../shared/services/local_content_service.dart';
import '../model/category_model.dart';

abstract class HomeRepository {
  Future<HomeContentModel> loadHomeContent();
  Future<String?> getLaunchLevelId();
  Future<void> saveLastPlayedLevel(String levelId);
  Future<String?> getLastPlayedLevelId();
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required LocalContentService contentService,
  }) : _contentService = contentService;

  final LocalContentService _contentService;

  @override
  Future<HomeContentModel> loadHomeContent() {
    return _contentService.loadHomeContent();
  }

  @override
  Future<String?> getLaunchLevelId() {
    return _contentService.getLaunchLevelId();
  }

  @override
  Future<void> saveLastPlayedLevel(String levelId) {
    return _contentService.saveLastPlayedLevel(levelId);
  }

  @override
  Future<String?> getLastPlayedLevelId() {
    return _contentService.getLastPlayedLevelId();
  }
}
