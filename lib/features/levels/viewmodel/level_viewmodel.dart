import '../../../core/base/base_viewmodel.dart';
import '../model/level_model.dart';
import '../repository/level_repository.dart';

class LevelViewModel extends BaseViewModel {
  LevelViewModel({
    required LevelRepository repository,
  }) : _repository = repository {
    load();
  }

  final LevelRepository _repository;
  List<LevelModel> _levels = const <LevelModel>[];

  List<LevelModel> get levels => _levels;

  Future<void> load() async {
    setLoading(true);
    _levels = await _repository.getAllLevels();
    setLoading(false);
  }
}