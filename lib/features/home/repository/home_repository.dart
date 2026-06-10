import '../../../shared/services/local_content_service.dart';
import '../model/category_model.dart';

abstract class HomeRepository {
  Future<HomeContentModel> loadHomeContent();
  Future<String?> getLaunchLevelId();
  Future<void> saveLastPlayedLevel(String levelId);
  Future<String?> getLastPlayedLevelId();

  /// Points persistence
  Future<int> getPoints();
  Future<void> savePoints(int points);

  /// Daily bonus & streak
  Future<String?> getLastDailyBonusDate();
  Future<void> saveLastDailyBonusDate(String date);
  Future<int> getCurrentStreak();
  Future<void> saveCurrentStreak(int streak);
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

  @override
  Future<int> getPoints() {
    return _contentService.getPoints();
  }

  @override
  Future<void> savePoints(int points) {
    print("--- STEP 1: Repository.savePoints called with: $points ---");
    return _contentService.savePoints(points);
  }

  @override
  Future<String?> getLastDailyBonusDate() {
    return _contentService.getLastDailyBonusDate();
  }

  @override
  Future<void> saveLastDailyBonusDate(String date) {
    return _contentService.saveLastDailyBonusDate(date);
  }

  @override
  Future<int> getCurrentStreak() {
    return _contentService.getCurrentStreak();
  }

  @override
  Future<void> saveCurrentStreak(int streak) {
    return _contentService.saveCurrentStreak(streak);
  }
}
