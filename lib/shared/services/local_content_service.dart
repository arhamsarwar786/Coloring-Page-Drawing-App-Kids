import 'dart:convert';

import 'package:flutter/services.dart';

import '../../app/config/app_config.dart';
import '../../features/home/model/category_model.dart';
import '../../features/levels/model/level_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_storage_base.dart';

class LocalContentService {
  LocalContentService({required LocalStorageService storage})
      : _storage = storage;

  static const String _fileName = 'asmr_drawing_progress.json';
  final LocalStorageService _storage;
  final supabase = Supabase.instance.client;
  HomeContentModel? _rawContent;
  final Map<String, _LevelProgress> _progress = <String, _LevelProgress>{};
  String? _lastPlayedLevelId;
  int _totalPoints = 0;
  String? _lastDailyBonusDate;
  int _currentStreak = 0;
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
        .where((level) => level.id != 'custom_svg')
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
    final currentIndex = levels.indexWhere((level) => level.id == levelId);
    if (currentIndex == -1 || currentIndex + 1 >= levels.length) {
      return null;
    }
    return levels[currentIndex + 1].id;
  }

  Future<String?> getPreviousLevelId(String levelId) async {
    final levels = await getAllLevels();
    final currentIndex = levels.indexWhere((level) => level.id == levelId);
    if (currentIndex <= 0) {
      return null;
    }
    return levels[currentIndex - 1].id;
  }

  Future<int?> getLevelNumber(String levelId) async {
    final levels = await getAllLevels();
    final currentIndex = levels.indexWhere((level) => level.id == levelId);
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

  // ── Points ──────────────────────────────────────────────────────────────

  Future<int> getPoints() async {
    await _ensureStateLoaded();
    return _totalPoints;
  }

  // Future<void> savePoints(int points) async {
  //   await _ensureStateLoaded();
  //   _totalPoints = points;
  //   await _persistState();
  // }

// // 1. Updated savePoints method

// 1. Updated savePoints method (Clean)

  Future<void> savePoints(int points, String description, String type) async {
    // Yahan 2 parameters extra add kiye
    print("--- STEP 2: LocalContentService.savePoints REACHED! ---");
    await _ensureStateLoaded();
    _totalPoints = points;
    await _persistState();

    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      print("--- DEBUG: User ID is: ${user.id} ---");
      try {
        // Yahan ab description aur type bhej rahe hain
        await Supabase.instance.client.from('user_coins').upsert({
          'user_id': user.id,
          'coins': points,
          'description': description, // Naya column
          'type': type, // Naya column
          'updated_at': DateTime.now().toIso8601String(),
        });
        print("--- DEBUG: Saved successfully with $description! ---");
      } catch (e) {
        print("--- DEBUG: ERROR! $e ---");
      }
    }
  }

  // Future<void> savePoints(int points) async {
  //   print("--- STEP 2: LocalContentService.savePoints REACHED! ---");
  //   await _ensureStateLoaded();
  //   _totalPoints = points;
  //   await _persistState();

  //   final user = Supabase.instance.client.auth.currentUser;

  //   if (user != null) {
  //     print("--- DEBUG: User ID is: ${user.id} ---");
  //     try {
  //       // UPDATE ki jagah UPSERT use karein
  //       await Supabase.instance.client.from('user_coins').upsert({
  //         'user_id': user.id,
  //         'coins': points,
  //         'updated_at': DateTime.now().toIso8601String(), // Optional
  //       });
  //       print("--- DEBUG: Saved successfully! ---");
  //     } catch (e) {
  //       print("--- DEBUG: ERROR! $e ---");
  //     }
  //   }
  // }

  // Future<void> savePoints(int points) async {
  //   print("--- STEP 2: LocalContentService.savePoints REACHED! ---");
  //   await _ensureStateLoaded();
  //   _totalPoints = points;

  //   // Local file save
  //   await _persistState();

  //   // Cloud sync
  //   final user = supabase.auth.currentUser;

  //   // Debug line add karein
  //   print("--- DEBUG: User ID is: ${user?.id} ---");
  //   if (user != null) {
  //     print("--- DEBUG: User is logged in, saving to Supabase... ---");
  //     try {
  //       await supabase
  //           .from('user_coins')
  //           .update({'coins': points}).eq('user_id', user.id);
  //       print("--- DEBUG: Saved successfully! ---");
  //       // Unlock check function call
  //       await _checkAndUnlockContent(points, user.id);
  //     } catch (e) {
  //       print("Error saving points: $e");
  //     }
  //   } else {
  //     print("--- ERROR: No user logged in! Cannot save to Supabase. ---");
  //   }
  // }

  // 2. Helper method (Sirf EK baar hona chahiye)
  Future<void> _checkAndUnlockContent(int points, String userId) async {
    Map<String, dynamic> updates = {};

    if (points >= 500) {
      updates['is_premium_unlocked'] = true;
    }
    if (points >= 200) {
      updates['is_stage_unlocked'] = true;
    }
    if (points >= 100) {
      updates['is_item_unlocked'] = true;
    }

    if (updates.isNotEmpty) {
      try {
        await supabase.from('user_coins').update(updates).eq('user_id', userId);
      } catch (e) {
        print("Error updating unlocks: $e");
      }
    }
  }
//   Future<void> savePoints(int points) async {
//     await _ensureStateLoaded();
//     _totalPoints = points;

//     // Local file save
//     await _persistState();

//     // Cloud sync
//     final user = supabase.auth.currentUser;
//     if (user != null) {
//       try {
//         await supabase
//             .from('user_coins')
//             .update({'coins': points})
//             .eq('user_id', user.id);

//         // Unlock check function call
//         await _checkAndUnlockContent(points, user.id);
//       } catch (e) {
//         print("Error saving points: $e");
//       }
//     }
//   }

//   // 2. Helper method (Ye isi class ke end mein add karein)
//   Future<void> _checkAndUnlockContent(int points, String userId) async {
//     Map<String, dynamic> updates = {};

//     if (points >= 500) {
//       updates['is_premium_unlocked'] = true;
//     }
//     if (points >= 200) {
//       updates['is_stage_unlocked'] = true;
//     }
//     if (points >= 100) {
//       updates['is_item_unlocked'] = true;
//     }

//     if (updates.isNotEmpty) {
//       try {
//         await supabase
//             .from('user_coins')
//             .update(updates)
//             .eq('user_id', userId);
//       } catch (e) {
//         print("Error updating unlocks: $e");
//       }
//     }
//   }
//   // Future<void> savePoints(int points) async {
//   //   await _ensureStateLoaded();
//   //   _totalPoints = points;

//   //   // 1. Local file mein save karein
//   //   await _persistState();

//   //   // 2. Supabase (Cloud) mein update karein
//   //   final user = supabase.auth.currentUser;
//   //   if (user != null) {
//   //     try {
//   //       await supabase
//   //           .from('user_coins')
//   //           .update({'coins': points}).eq('user_id', user.id);

//   //       // 3. Unlock logic check karein
//   //       await _checkAndUnlockContent(points, user.id);
//   //     } catch (e) {
//   //       print("Error saving to Supabase: $e");
//   //     }
//   //   }
//   // }

//   // Ye naya function add karein isi class ke andar
//   Future<void> _checkAndUnlockContent(int points, String userId) async {
//     Map<String, dynamic> updates = {};

//     if (points >= 500) {
//       updates['is_premium_unlocked'] = true;
//     }
//     if (points >= 200) {
//       updates['is_stage_unlocked'] = true;
//     }
//     if (points >= 100) {
//       updates['is_item_unlocked'] = true;
//     }

//     if (updates.isNotEmpty) {
//       await supabase.from('user_coins').update(updates).eq('user_id', userId);
//     }
//   }

  // ── Daily bonus ──────────────────────────────────────────────────────────

  Future<String?> getLastDailyBonusDate() async {
    await _ensureStateLoaded();
    return _lastDailyBonusDate;
  }

  Future<void> saveLastDailyBonusDate(String date) async {
    await _ensureStateLoaded();
    _lastDailyBonusDate = date;
    await _persistState();
  }

  Future<int> getCurrentStreak() async {
    await _ensureStateLoaded();
    return _currentStreak;
  }

  Future<void> saveCurrentStreak(int streak) async {
    await _ensureStateLoaded();
    _currentStreak = streak;
    await _persistState();
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
    final jsonString = await rootBundle.loadString(AppConfig.contentAssetPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final baseContent = HomeContentModel.fromJson(jsonMap);
    final realisticPack = await _loadRealisticLevelPack();
    _rawContent = _mergeRealisticPack(
      baseContent: baseContent,
      realisticPack: realisticPack,
    );
    return _rawContent!;
  }

  Future<Map<String, List<LevelModel>>> _loadRealisticLevelPack() async {
    try {
      final jsonString =
          await rootBundle.loadString(AppConfig.realisticPackAssetPath);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final categoryList =
          jsonMap['categories'] as List<dynamic>? ?? const <dynamic>[];
      final byCategory = <String, List<LevelModel>>{};

      for (final item in categoryList) {
        if (item is! Map) continue;
        final categoryMap = Map<String, dynamic>.from(item);
        final categoryId = categoryMap['id'] as String?;
        final levels =
            categoryMap['levels'] as List<dynamic>? ?? const <dynamic>[];
        if (categoryId == null || levels.isEmpty) continue;

        final parsedLevels = <LevelModel>[];
        for (final level in levels) {
          if (level is! Map) continue;
          parsedLevels
              .add(LevelModel.fromJson(Map<String, dynamic>.from(level)));
        }

        if (parsedLevels.isEmpty) continue;

        byCategory[categoryId] = List<LevelModel>.unmodifiable(parsedLevels);
      }

      return byCategory;
    } catch (_) {
      return const <String, List<LevelModel>>{};
    }
  }

  HomeContentModel _mergeRealisticPack({
    required HomeContentModel baseContent,
    required Map<String, List<LevelModel>> realisticPack,
  }) {
    if (realisticPack.isEmpty) {
      return baseContent;
    }

    final mergedCategories = baseContent.categories.map((category) {
      final additions = realisticPack[category.id] ?? const <LevelModel>[];
      if (additions.isEmpty) {
        return category;
      }

      final existingIds = category.levels.map((level) => level.id).toSet();
      final newLevels = additions
          .where((level) => !existingIds.contains(level.id))
          .toList(growable: false);
      if (newLevels.isEmpty) {
        return category;
      }

      return category.copyWith(
        levels: <LevelModel>[
          ...category.levels,
          ...newLevels,
        ],
      );
    }).toList(growable: false);

    return baseContent.copyWith(categories: mergedCategories);
  }

  Future<void> _ensureStateLoaded() async {
    if (_stateLoaded) return;
    _stateLoaded = true;
    final raw = await _storage.read(_fileName);
    if (raw == null || raw.isEmpty) return;
    try {
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      _lastPlayedLevelId = jsonMap['lastPlayedLevelId'] as String?;
      _totalPoints = (jsonMap['totalPoints'] as int?) ?? 0;
      _lastDailyBonusDate = jsonMap['lastDailyBonusDate'] as String?;
      _currentStreak = (jsonMap['currentStreak'] as int?) ?? 0;
      final progressMap = jsonMap['progress'] as Map<String, dynamic>? ??
          const <String, dynamic>{};
      for (final entry in progressMap.entries) {
        _progress[entry.key] =
            _LevelProgress.fromJson(entry.value as Map<String, dynamic>);
      }
    } catch (_) {
      _progress.clear();
      _lastPlayedLevelId = null;
      _totalPoints = 0;
      _lastDailyBonusDate = null;
      _currentStreak = 0;
    }
  }

  Future<void> _persistState() {
    final payload = <String, dynamic>{
      'lastPlayedLevelId': _lastPlayedLevelId,
      'totalPoints': _totalPoints,
      'lastDailyBonusDate': _lastDailyBonusDate,
      'currentStreak': _currentStreak,
      'progress': _progress.map(
        (key, value) => MapEntry<String, dynamic>(key, value.toJson()),
      ),
    };
    return _storage.write(_fileName, jsonEncode(payload));
  }

  HomeContentModel _applyProgress(HomeContentModel content) {
    final categories = content.categories.map((category) {
      final levels = category.levels
          .map((level) {
            final progress = _progress[level.id];
            return level.copyWith(
              isCompleted: progress?.isCompleted ?? false,
              stars: progress?.stars ?? 0,
            );
          })
          .where((level) => level.id != 'custom_svg')
          .toList();
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
