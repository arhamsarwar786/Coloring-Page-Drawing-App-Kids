import 'dart:convert';

import 'package:flutter/services.dart';

import '../../app/config/app_config.dart';
import '../../features/home/model/category_model.dart';
import '../../features/levels/model/level_model.dart';
import 'local_storage_base.dart';

class LocalContentService {
  LocalContentService({required LocalStorageService storage})
      : _storage = storage;

  static const String _fileName = 'asmr_drawing_progress.json';
  final LocalStorageService _storage;
  HomeContentModel? _rawContent;
  final Map<String, _LevelProgress> _progress =
      <String, _LevelProgress>{};
  String? _lastPlayedLevelId;
  bool _stateLoaded = false;

  Future<HomeContentModel> loadHomeContent() async {
    await _ensureStateLoaded();
    final raw = await _ensureLoaded();
    return _applyProgress(raw);
  }

  Future<List<LevelModel>> getAllLevels() async {
    final content = await loadHomeContent();
    return content.categories
        .expand((category) => category.levels)
        .toList();
  }

  Future<LevelModel?> getLevelById(String levelId) async {
    final levels = await getAllLevels();
    for (final level in levels) {
      if (level.id == levelId) return level;
    }
    return null;
  }

  Future<String?> getLaunchLevelId() async {
    final levels = await getAllLevels();
    if (levels.isEmpty) return null;
    for (final level in levels) {
      if (!level.isCompleted) return level.id;
    }
    return levels.first.id;
  }

  Future<String?> getNextLevelId(String levelId) async {
    final levels = await getAllLevels();
    final currentIndex =
        levels.indexWhere((level) => level.id == levelId);
    if (currentIndex == -1 || currentIndex + 1 >= levels.length) {
      return null;
    }
    return levels[currentIndex + 1].id;
  }

  Future<int?> getLevelNumber(String levelId) async {
    final levels = await getAllLevels();
    final currentIndex =
        levels.indexWhere((level) => level.id == levelId);
    if (currentIndex == -1) return null;
    return currentIndex + 1;
  }

  Future<void> saveLastPlayedLevel(String levelId) async {
    await _ensureStateLoaded();
    _lastPlayedLevelId = levelId;
    await _persistState();
  }

  Future<String?> getLastPlayedLevelId() async {
    await _ensureStateLoaded();
    return _lastPlayedLevelId;
  }

  Future<void> markLevelCompleted({
    required String levelId,
    required int stars,
    required int rewardCoins,
  }) async {
    await _ensureStateLoaded();
    final current = _progress[levelId];
    _progress[levelId] = _LevelProgress(
      isCompleted: true,
      stars: stars > (current?.stars ?? 0) ? stars : current?.stars ?? stars,
      rewardCoins: rewardCoins,
    );
    await _persistState();
  }

  Future<HomeContentModel> _ensureLoaded() async {
    if (_rawContent != null) return _rawContent!;
    final jsonString =
        await rootBundle.loadString(AppConfig.contentAssetPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    _rawContent = HomeContentModel.fromJson(jsonMap);
    return _rawContent!;
  }

  Future<void> _ensureStateLoaded() async {
    if (_stateLoaded) return;
    _stateLoaded = true;
    final raw = await _storage.read(_fileName);
    if (raw == null || raw.isEmpty) return;
    try {
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      _lastPlayedLevelId = jsonMap['lastPlayedLevelId'] as String?;
      final progressMap = jsonMap['progress'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      for (final entry in progressMap.entries) {
        _progress[entry.key] = _LevelProgress.fromJson(
            entry.value as Map<String, dynamic>);
      }
    } catch (_) {
      _progress.clear();
      _lastPlayedLevelId = null;
    }
  }

  Future<void> _persistState() {
    final payload = <String, dynamic>{
      'lastPlayedLevelId': _lastPlayedLevelId,
      'progress': _progress.map(
        (key, value) =>
            MapEntry<String, dynamic>(key, value.toJson()),
      ),
    };
    return _storage.write(_fileName, jsonEncode(payload));
  }

  HomeContentModel _applyProgress(HomeContentModel content) {
    final categories = content.categories.map((category) {
      final levels = category.levels.map((level) {
        final progress = _progress[level.id];
        return level.copyWith(
          isCompleted: progress?.isCompleted ?? false,
          stars: progress?.stars ?? 0,
        );
      }).toList();
      return category.copyWith(levels: levels);
    }).toList();
    return content.copyWith(categories: categories);
  }
}

class _LevelProgress {
  const _LevelProgress({
    required this.isCompleted,
    required this.stars,
    required this.rewardCoins,
  });

  final bool isCompleted;
  final int stars;
  final int rewardCoins;

  factory _LevelProgress.fromJson(Map<String, dynamic> json) {
    return _LevelProgress(
      isCompleted: json['isCompleted'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
      rewardCoins: json['rewardCoins'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isCompleted': isCompleted,
      'stars': stars,
      'rewardCoins': rewardCoins,
    };
  }
}
