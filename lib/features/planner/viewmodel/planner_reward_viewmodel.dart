import 'package:flutter/foundation.dart';

import '../../../core/base/base_viewmodel.dart';
import '../model/planner_progress_model.dart';
import '../repository/planner_progress_repository.dart';
import '../services/planner_download_service.dart';

class PlannerRewardViewModel extends BaseViewModel {
  PlannerRewardViewModel({
    required PlannerProgressRepository repository,
    required PlannerDownloadService downloadService,
  })  : _repository = repository,
        _downloadService = downloadService {
    ensureLoaded();
  }

  final PlannerProgressRepository _repository;
  final PlannerDownloadService _downloadService;

  PlannerProgressModel _prefs = const PlannerProgressModel();
  int _completedLevels = 0;
  bool _loaded = false;
  bool _isDownloading = false;
  PlannerPdfFormat? _downloadingFormat;
  String? _downloadError;

  bool get isLoaded => _loaded;
  bool get isDownloading => _isDownloading;
  PlannerPdfFormat? get downloadingFormat => _downloadingFormat;
  String? get downloadError => _downloadError;

  int get completedLevels => _completedLevels;
  int get unlockThreshold => PlannerProgressModel.unlockThreshold;
  int get remainingLevels =>
      (unlockThreshold - _completedLevels).clamp(0, unlockThreshold);
  double get progressFraction =>
      (_completedLevels / unlockThreshold).clamp(0.0, 1.0);
  bool get isUnlocked => _completedLevels >= unlockThreshold;
  bool get introSeen => _prefs.introSeen;
  bool get unlockCelebrationSeen => _prefs.unlockCelebrationSeen;

  /// Show intro popup once (new feature) until dismissed.
  bool get shouldShowIntroPopup => _loaded && !introSeen;

  /// Show unlock celebration the first time they hit 5 completed levels.
  bool get shouldShowUnlockCelebration =>
      _loaded && isUnlocked && !unlockCelebrationSeen;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _prefs = await _repository.load();
    _loaded = true;
    notifyListeners();
  }

  /// Syncs with [HomeViewModel.completedLevelsCount]. Call after load/refresh.
  Future<void> syncCompletedLevels(int count) async {
    await ensureLoaded();
    final safeCount = count < 0 ? 0 : count;
    if (_completedLevels == safeCount &&
        _prefs.lastKnownCompletedCount == safeCount) {
      return;
    }

    _completedLevels = safeCount;
    _prefs = _prefs.copyWith(lastKnownCompletedCount: safeCount);
    await _repository.save(_prefs);
    notifyListeners();
  }

  Future<void> markIntroSeen() async {
    if (_prefs.introSeen) return;
    _prefs = _prefs.copyWith(introSeen: true);
    await _repository.save(_prefs);
    notifyListeners();
  }

  Future<void> markUnlockCelebrationSeen() async {
    if (_prefs.unlockCelebrationSeen) return;
    _prefs = _prefs.copyWith(unlockCelebrationSeen: true);
    await _repository.save(_prefs);
    notifyListeners();
  }

  Future<bool> shareFormat(PlannerPdfFormat format) async {
    if (!isUnlocked || _isDownloading) return false;
    _isDownloading = true;
    _downloadingFormat = format;
    _downloadError = null;
    notifyListeners();

    try {
      await _downloadService.sharePdf(format);
      return true;
    } catch (e, st) {
      debugPrint('Planner share failed: $e\n$st');
      _downloadError = 'Could not share the planner. Please try again.';
      return false;
    } finally {
      _isDownloading = false;
      _downloadingFormat = null;
      notifyListeners();
    }
  }

  Future<bool> printFormat(PlannerPdfFormat format) async {
    if (!isUnlocked || _isDownloading) return false;
    _isDownloading = true;
    _downloadingFormat = format;
    _downloadError = null;
    notifyListeners();

    try {
      await _downloadService.printPdf(format);
      return true;
    } catch (e, st) {
      debugPrint('Planner print failed: $e\n$st');
      _downloadError = 'Could not open print preview. Please try again.';
      return false;
    } finally {
      _isDownloading = false;
      _downloadingFormat = null;
      notifyListeners();
    }
  }

  void clearDownloadError() {
    if (_downloadError == null) return;
    _downloadError = null;
    notifyListeners();
  }
}
