import 'dart:convert';

import '../../../shared/services/local_storage_base.dart';
import '../model/planner_progress_model.dart';

class PlannerProgressRepository {
  PlannerProgressRepository({required LocalStorageService storage})
      : _storage = storage;

  static const String _fileName = 'playcraft_planner_progress.json';
  final LocalStorageService _storage;

  Future<PlannerProgressModel> load() async {
    final raw = await _storage.read(_fileName);
    if (raw == null || raw.isEmpty) return const PlannerProgressModel();
    try {
      return PlannerProgressModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const PlannerProgressModel();
    }
  }

  Future<void> save(PlannerProgressModel model) {
    return _storage.write(_fileName, jsonEncode(model.toJson()));
  }
}
