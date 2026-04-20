import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../core/base/base_viewmodel.dart';
import '../../../core/constants/app_strings.dart';
import '../../levels/model/level_model.dart';
import '../../sound/services/sound_service.dart';
import '../model/color_model.dart';
import '../model/drawing_action.dart';
import '../repository/drawing_repository.dart';

class DrawingViewModel extends BaseViewModel {
  DrawingViewModel({
    required DrawingRepository repository,
    required SoundService soundService,
  })  : _repository = repository,
        _soundService = soundService;

  final DrawingRepository _repository;
  final SoundService _soundService;

  LevelModel? _level;
  DrawingColorModel? _selectedColor;
  Map<String, Color> _filledRegions = <String, Color>{};
  final List<DrawingAction> _undoStack = <DrawingAction>[];
  final List<DrawingAction> _redoStack = <DrawingAction>[];
  String? _loadedLevelId;
  String? _launchLevelId;
  String? _nextLevelId;
  int? _levelNumber;
  int _undoCount = 0;
  int? _rewardCoins;
  int? _rewardStars;

  LevelModel? get level => _level;
  DrawingColorModel? get selectedColor => _selectedColor;
  String? get launchLevelId => _launchLevelId;
  int? get levelNumber => _levelNumber;
  String? get nextLevelId => _nextLevelId;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int? get rewardCoins => _rewardCoins;
  int? get rewardStars => _rewardStars;
  bool get isCompleted {
    if (_level == null) return false;
    if (_level!.isCompleted) return true;
    return _filledRegions.length >= _level!.regions.length && _level!.regions.isNotEmpty;
  }
  UnmodifiableMapView<String, Color> get filledRegions =>
      UnmodifiableMapView<String, Color>(_filledRegions);

  double get completionProgress {
    final total = _level?.regions.length ?? 0;
    if (total == 0) return 0;
    return _filledRegions.length / total;
  }

  Future<void> loadLevel(String levelId) async {
    if (_loadedLevelId == levelId && _level != null) return;

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
      _levelNumber = await _repository.getLevelNumber(levelId);
      _level = loadedLevel;
      _selectedColor =
          loadedLevel.palette.isNotEmpty ? loadedLevel.palette.first : null;
      _filledRegions = <String, Color>{};
      _undoStack.clear();
      _redoStack.clear();
      _rewardCoins = null;
      _rewardStars = null;
      _undoCount = 0;
      await _repository.saveLastPlayedLevel(levelId);
    } catch (_) {
      setError(AppStrings.loadError);
    }

    setLoading(false);
  }

  void selectColor(DrawingColorModel color) {
    _selectedColor = color;
    notifyListeners();
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
    if (_level == null || isCompleted) return;

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
}
