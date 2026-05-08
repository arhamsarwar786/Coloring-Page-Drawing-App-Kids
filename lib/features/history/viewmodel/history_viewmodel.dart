import '../../../core/base/base_viewmodel.dart';
import '../model/drawing_history_entry.dart';
import '../repository/history_repository.dart';

class HistoryViewModel extends BaseViewModel {
  HistoryViewModel({
    required HistoryRepository repository,
  }) : _repository = repository {
    load();
  }

  final HistoryRepository _repository;
  List<DrawingHistoryEntry> _entries = const <DrawingHistoryEntry>[];

  List<DrawingHistoryEntry> get entries => _entries;
  bool get isEmpty => _entries.isEmpty;

  Future<void> load() async {
    setLoading(true);
    clearError();
    try {
      _entries = await _repository.getHistoryEntries();
    } catch (_) {
      _entries = const <DrawingHistoryEntry>[];
      setError('Unable to load drawing history.');
    }
    setLoading(false);
  }
}
