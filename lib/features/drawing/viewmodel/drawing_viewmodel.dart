import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/base/base_viewmodel.dart';
import '../../../core/constants/app_strings.dart';
import '../../history/model/drawing_history_entry.dart';
import '../../history/repository/history_repository.dart';
import '../../levels/model/level_model.dart';
import '../../sound/services/sound_service.dart';
import '../model/drawing_brush_size.dart';
import '../model/color_model.dart';
import '../model/drawing_action.dart';
import '../model/drawing_session_snapshot.dart';
import '../repository/drawing_repository.dart';

class DrawingViewModel extends BaseViewModel {
  DrawingViewModel({
    required DrawingRepository repository,
    required HistoryRepository historyRepository,
    required SoundService soundService,
  })  : _repository = repository,
        _historyRepository = historyRepository,
        _soundService = soundService;

  final DrawingRepository _repository;
  final HistoryRepository _historyRepository;
  final SoundService _soundService;
  final ValueNotifier<DrawingBrushSize> _brushSizeNotifier =
      ValueNotifier<DrawingBrushSize>(DrawingBrushSize.standard);

  LevelModel? _level;
  DrawingColorModel? _selectedColor;
  Map<String, Color> _filledRegions = <String, Color>{};
  final List<DrawingAction> _undoStack = <DrawingAction>[];
  final List<DrawingAction> _redoStack = <DrawingAction>[];
  bool _isActive = false;
  String? _loadedLevelId;
  String? _launchLevelId;
  String? _nextLevelId;
  String? _previousLevelId;
  int? _levelNumber;
  int _undoCount = 0;
  int? _rewardCoins;
  int? _rewardStars;
  String? _activeDrawingSessionId;
  DrawingSessionSnapshot? _initialSessionSnapshot;
  String? _thumbnailBase64;

  LevelModel? get level => _level;
  DrawingColorModel? get selectedColor => _selectedColor;
  DrawingBrushSize get selectedBrushSize => _brushSizeNotifier.value;
  ValueListenable<DrawingBrushSize> get brushSizeListenable =>
      _brushSizeNotifier;
  bool get isActive => _isActive;
  String? get activeDrawingSessionId => _activeDrawingSessionId;
  DrawingSessionSnapshot? get initialSessionSnapshot => _initialSessionSnapshot;
  String? get launchLevelId => _launchLevelId;
  int? get levelNumber => _levelNumber;
  String? get nextLevelId => _nextLevelId;
  String? get previousLevelId => _previousLevelId;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int? get rewardCoins => _rewardCoins;
  int? get rewardStars => _rewardStars;
  bool get isCompleted {
    if (_level == null) return false;
    if (_level!.isCompleted) return true;
    return _filledRegions.length >= _level!.regions.length &&
        _level!.regions.isNotEmpty;
  }

  UnmodifiableMapView<String, Color> get filledRegions =>
      UnmodifiableMapView<String, Color>(_filledRegions);

  double get completionProgress {
    final total = _level?.regions.length ?? 0;
    if (total == 0) return 0;
    return _filledRegions.length / total;
  }

  Future<void> loadLevel(String levelId, {String? drawingSessionId}) async {
    if (_loadedLevelId == levelId && _level != null && drawingSessionId == null) {
      _startFreshSessionForCurrentLevel();
      notifyListeners();
      return;
    }

    setLoading(true);
    setError(null);

    try {
      final loadedLevel = await _repository.getLevelById(levelId);
      if (loadedLevel == null) {
        setError(AppStrings.loadError);
        setLoading(false);
        return;
      }

      _loadedLevelId = levelId;
      _launchLevelId = await _repository.getLaunchLevelId();
      _nextLevelId = await _repository.getNextLevelId(levelId);
      _previousLevelId = await _repository.getPreviousLevelId(levelId);
      _levelNumber = await _repository.getLevelNumber(levelId);
      _level = loadedLevel.copyWith(isCompleted: false);
      _selectedColor =
          loadedLevel.palette.isNotEmpty ? loadedLevel.palette.first : null;
      _brushSizeNotifier.value = DrawingBrushSize.standard;
      _activeDrawingSessionId = null;
      _initialSessionSnapshot = null;
      _thumbnailBase64 = null;
      _filledRegions = <String, Color>{};
      _undoStack.clear();
      _redoStack.clear();
      _rewardCoins = null;
      _rewardStars = null;
      _undoCount = 0;

      // Always try to restore session if it exists for this level
      await _restoreHistorySession(levelId, drawingSessionId ?? levelId);

      await _repository.saveLastPlayedLevel(levelId);
    } catch (_) {
      setError(AppStrings.loadError);
    }

    setLoading(false);
  }

  void _startFreshSessionForCurrentLevel() {
    if (_level == null) return;
    _level = _level!.copyWith(isCompleted: false);
    _selectedColor = _level!.palette.isNotEmpty ? _level!.palette.first : null;
    _brushSizeNotifier.value = DrawingBrushSize.standard;
    _activeDrawingSessionId = null;
    _initialSessionSnapshot = null;
    _thumbnailBase64 = null;
    _filledRegions = <String, Color>{};
    _undoStack.clear();
    _redoStack.clear();
    _rewardCoins = null;
    _rewardStars = null;
    _undoCount = 0;
  }

  void selectColor(DrawingColorModel color) {
    _selectedColor = color;
    notifyListeners();
  }

  void markActive(bool value) {
    if (_isActive == value) return;
    _isActive = value;
    // We don't necessarily need to notify here unless UI depends on it,
    // but it's safer to keep it internal or notify if needed.
  }

  void selectBrushSize(DrawingBrushSize size) {
    if (_brushSizeNotifier.value == size) return;
    _brushSizeNotifier.value = size;
  }

  Future<void> saveHistorySnapshot({
    required DrawingSessionSnapshot snapshot,
    Uint8List? thumbnailBytes,
  }) async {
    final currentLevel = _level;
    if (currentLevel == null || !snapshot.hasVisibleProgress) return;

    _activeDrawingSessionId ??= _buildDrawingSessionId(currentLevel.id);
    if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
      _thumbnailBase64 = base64Encode(thumbnailBytes);
    }

    final rawProgress =
        snapshot.progressForRegionCount(currentLevel.regions.length);
    final isCompleted = _filledRegions.length >= currentLevel.regions.length &&
        currentLevel.regions.isNotEmpty;
    final progress = isCompleted ? 1.0 : rawProgress;

    final entry = DrawingHistoryEntry(
      id: _activeDrawingSessionId!,
      levelId: currentLevel.id,
      levelTitle: currentLevel.title,
      levelNumber: _levelNumber,
      progress: progress,
      status: isCompleted
          ? DrawingHistoryStatus.completed
          : DrawingHistoryStatus.inProgress,
      lastEditedAt: DateTime.now(),
      thumbnailBase64: _thumbnailBase64,
      snapshot: snapshot,
    );

    _initialSessionSnapshot = snapshot;
    await _historyRepository.saveHistoryEntry(entry);
  }

  Future<void> fillRegionAt(String regionId) async {
    if (_selectedColor == null || _level == null) return;

    final previousColor = _filledRegions[regionId];
    final nextColor = _selectedColor!.color;
    if (previousColor == nextColor) return;

    _filledRegions = <String, Color>{
      ..._filledRegions,
      regionId: nextColor,
    };
    _undoStack.add(
      DrawingAction.fill(
        regionId: regionId,
        previousColor: previousColor,
        nextColor: nextColor,
      ),
    );
    _redoStack.clear();
    notifyListeners();
    await _soundService.playFillFeedback();
    await _evaluateCompletion();
  }

  void undo() {
    if (_undoStack.isEmpty) return;

    final action = _undoStack.removeLast();
    if (action.type == DrawingActionType.fill) {
      final updated = Map<String, Color>.from(_filledRegions);
      final regionId = action.regionId;
      if (regionId != null) {
        if (action.previousColor == null) {
          updated.remove(regionId);
        } else {
          updated[regionId] = action.previousColor!;
        }
      }
      _filledRegions = updated;
    }

    _redoStack.add(action);
    _undoCount++;
    _rewardCoins = null;
    _rewardStars = null;
    notifyListeners();
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;

    final action = _redoStack.removeLast();
    if (action.type == DrawingActionType.fill) {
      final updated = Map<String, Color>.from(_filledRegions);
      final regionId = action.regionId;
      if (regionId != null && action.nextColor != null) {
        updated[regionId] = action.nextColor!;
      }
      _filledRegions = updated;
    }

    _undoStack.add(action);
    notifyListeners();
    await _evaluateCompletion();
  }

  void resetCanvas() {
    _filledRegions = <String, Color>{};
    _undoStack.clear();
    _redoStack.clear();
    _rewardCoins = null;
    _rewardStars = null;
    _undoCount = 0;
    notifyListeners();
  }

  void toggleFavorite() {
    if (_level == null) return;
    _level = _level!.copyWith(isFavorite: !_level!.isFavorite);
    notifyListeners();
    // In a real app, we would also save this to the repository
  }

  Future<void> _evaluateCompletion() async {
    if (_level == null || _level!.isCompleted) return;

    final filledCount = _filledRegions.length;
    final requiredCount = _level!.regions.length;

    if (requiredCount == 0 || filledCount < requiredCount) {
      return;
    }

    final stars = _undoCount == 0
        ? 3
        : _undoCount <= 2
            ? 2
            : 1;

    _rewardCoins = _level!.rewardCoins;
    _rewardStars = stars;
    _level = _level!.copyWith(isCompleted: true, stars: stars);

    // Explicitly set this to ensure UI sees it
    notifyListeners();

    await _repository.markLevelCompleted(
      levelId: _level!.id,
      stars: stars,
      rewardCoins: _level!.rewardCoins,
    );
    await _soundService.playCompletionFeedback();
  }

  Future<void> _restoreHistorySession(
    String levelId,
    String drawingSessionId,
  ) async {
    final entry = await _historyRepository.getHistoryEntry(drawingSessionId);
    if (entry == null || entry.levelId != levelId) {
      return;
    }

    _activeDrawingSessionId = entry.id;

    // Restart fresh if the previous session was completed
    if (entry.status == DrawingHistoryStatus.completed) {
      _activeDrawingSessionId = null; // Ensure new session starts
      return;
    }

    _initialSessionSnapshot = entry.snapshot;
    _thumbnailBase64 = entry.thumbnailBase64;
    _filledRegions = entry.snapshot.filledRegions.map(
      (key, value) => MapEntry<String, Color>(key, Color(value)),
    );
    _selectedColor = _resolveSelectedColor(entry.snapshot.selectedColorId);
    _brushSizeNotifier.value = _brushSizeFromKey(entry.snapshot.brushSizeKey);
    _undoStack.clear();
    _redoStack.clear();
    _undoCount = 0;
    _rewardCoins = null;
    _rewardStars = null;
  }

  DrawingColorModel? _resolveSelectedColor(String? colorId) {
    final currentLevel = _level;
    if (currentLevel == null || currentLevel.palette.isEmpty) {
      return null;
    }

    if (colorId == null || colorId.trim().isEmpty) {
      return currentLevel.palette.first;
    }

    for (final color in currentLevel.palette) {
      if (color.id == colorId) {
        return color;
      }
    }

    return currentLevel.palette.first;
  }

  DrawingBrushSize _brushSizeFromKey(String key) {
    for (final size in DrawingBrushSize.values) {
      if (size.name == key) {
        return size;
      }
    }
    return DrawingBrushSize.standard;
  }

  String _buildDrawingSessionId(String levelId) {
    return levelId;
  }

  @override
  void dispose() {
    _brushSizeNotifier.dispose();
    super.dispose();
  }
}
