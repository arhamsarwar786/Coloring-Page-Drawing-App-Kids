import '../../../core/base/base_viewmodel.dart';
import '../../levels/repository/level_repository.dart';

class RewardViewModel extends BaseViewModel {
  RewardViewModel({
    required LevelRepository repository,
  }) : _repository = repository {
    load();
  }

  final LevelRepository _repository;
  int _coins = 0;
  int _completedLevels = 0;

  int get coins => _coins;
  int get completedLevels => _completedLevels;

  Future<void> load() async {
    setLoading(true);
    final levels = await _repository.getAllLevels();
    _coins = levels
        .where((level) => level.isCompleted)
        .fold<int>(0, (sum, level) => sum + level.rewardCoins);
    _completedLevels =
        levels.where((level) => level.isCompleted).length;
    setLoading(false);
  }
}
