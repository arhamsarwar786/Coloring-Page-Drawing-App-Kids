import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/home/components/coins_history.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/base/base_viewmodel.dart';
import '../../../core/constants/app_strings.dart';
import '../../history/repository/history_repository.dart';
import '../../levels/model/level_model.dart';
import '../model/category_model.dart';
import '../repository/home_repository.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({
    required HomeRepository repository,
    required HistoryRepository historyRepository,
  })  : _repository = repository,
        _historyRepository = historyRepository {
    load();
  }

  final HomeRepository _repository;
  final HistoryRepository _historyRepository;
  static const double unlockProgressThreshold = 0.8;

  // ── Points ──────────────────────────────────────────────────────────────
  static const int _completionPointsValue = 20;
  static const int _colorMatchPointsValue = 10;
  static const int _dailyBonusPointsValue = 50;

  HomeContentModel? _content;
  String? _selectedCategoryId;
  String? _lastPlayedLevelId;
  Map<String, double> _levelProgress = const <String, double>{};
  int _totalPoints = 0;

  HomeContentModel? get content => _content;

  /// Total accumulated points.
  int get totalPoints => _totalPoints;

  List<CategoryModel> get categories =>
      _content?.categories ?? const <CategoryModel>[];

  CategoryModel? get selectedCategory {
    if (categories.isEmpty) return null;
    return categories.firstWhere(
      (category) => category.id == _selectedCategoryId,
      orElse: () => categories.first,
    );
  }

  bool _isLoading = false;

  int _databaseCoins = 0;
  int get databaseCoins => _databaseCoins;
  bool get isLoading => _isLoading;
// ViewModel mein ye line add karein
  int get userCoins => _databaseCoins;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<LevelModel> get levelsForSelectedCategory {
    return selectedCategory?.levels ?? const <LevelModel>[];
  }

  LevelModel? get continueLevel {
    if (_lastPlayedLevelId == null) return dailyLevel;
    for (final category in categories) {
      for (final level in category.levels) {
        if (level.id == _lastPlayedLevelId) return level;
      }
    }
    return dailyLevel;
  }

  LevelModel? get dailyLevel {
    for (final category in categories) {
      for (final level in category.levels) {
        if (!level.isCompleted) return level;
      }
    }
    return categories.isNotEmpty && categories.first.levels.isNotEmpty
        ? categories.first.levels.first
        : null;
  }

  int get completedLevelsCount {
    return categories
        .expand((category) => category.levels)
        .where((level) => level.isCompleted)
        .length;
  }

  int get totalLevelsCount {
    return categories.expand((category) => category.levels).length;
  }

  int get earnedCoins {
    return categories
        .expand((category) => category.levels)
        .where((level) => level.isCompleted)
        .fold<int>(0, (sum, level) => sum + level.rewardCoins);
  }

  get error => null;

  // Future<void> load() async {
  //   setLoading(true);
  //   setError(null);
  //   try {
  //     _content = await _repository.loadHomeContent();
  //     _lastPlayedLevelId = await _repository.getLastPlayedLevelId();
  //     _levelProgress = await _loadLevelProgress();
  //     _totalPoints = await _repository.getPoints();
  //     if (_content!.categories.isNotEmpty) {
  //       final hasCurrentSelection = _content!.categories
  //           .any((category) => category.id == _selectedCategoryId);
  //       _selectedCategoryId = hasCurrentSelection
  //           ? _selectedCategoryId
  //           : _content!.categories.first.id;
  //     }
  //   } catch (_) {
  //     setError(AppStrings.loadError);
  //   }
  //   setLoading(false);
  // }

  Future<void> load() async {
    setLoading(true);
    try {
      _content = await _repository.loadHomeContent();
      _lastPlayedLevelId = await _repository.getLastPlayedLevelId();
      _levelProgress = await _loadLevelProgress();

      // Yahan database se real coins fetch karein
      await fetchDatabaseCoins();

      // ... baki ka code waisa hi rahe

      await checkAndApplyDailyBonus();

      // setLoading(false);
    } catch (_) {
      setError(AppStrings.loadError);
    }
    setLoading(false);
  }

  Future<void> fetchDatabaseCoins() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _databaseCoins = 0;
        notifyListeners();
        return;
      }

      // user_coins table se current balance fetch karo (single row per user)
      final data = await Supabase.instance.client
          .from('user_coins')
          .select('coins')
          .eq('user_id', userId)
          .maybeSingle();

      _databaseCoins = (data?['coins'] as int?) ?? 0;
      print("Fetched balance from user_coins: $_databaseCoins");
      notifyListeners();
    } catch (e) {
      print("fetchDatabaseCoins error: $e");
    }
  }

  void selectCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  bool isLevelLocked(LevelModel level) {
    final category = _categoryForLevel(level.id) ?? selectedCategory;
    if (category == null || category.levels.isEmpty) return false;

    final levelIndex = category.levels.indexWhere(
      (item) => item.id == level.id,
    );
    return isLevelLockedAt(levelIndex, category.levels);
  }

  bool isLevelLockedAt(int levelIndex, List<LevelModel> levels) {
    if (levelIndex <= 0) return false;
    if (levelIndex >= levels.length) return true;

    // Only check the immediately previous level, not all of them.
    final previousLevel = levels[levelIndex - 1];
    if (previousLevel.isCompleted) {
      return false;
    }

    if (levelProgressFor(previousLevel.id) >= unlockProgressThreshold) {
      return false;
    }

    return true;
  }

  Future<bool> prepareLevel(String levelId) async {
    final level = _findLevel(levelId);
    if (level == null) return false;
    if (isLevelLocked(level)) return false;
    await _repository.saveLastPlayedLevel(levelId);
    _lastPlayedLevelId = levelId;
    notifyListeners();
    return true;
  }

  LevelModel? _findLevel(String levelId) {
    for (final category in categories) {
      for (final level in category.levels) {
        if (level.id == levelId) return level;
      }
    }
    return null;
  }

  CategoryModel? _categoryForLevel(String levelId) {
    for (final category in categories) {
      for (final level in category.levels) {
        if (level.id == levelId) return category;
      }
    }
    return null;
  }

  double levelProgressFor(String levelId) {
    final level = _findLevel(levelId);
    if (level != null && level.isCompleted) {
      return 1.0;
    }
    return _levelProgress[levelId] ?? 0.0;
  }

  // Loads progress per level from history
  Future<Map<String, double>> _loadLevelProgress() async {
    final progressByLevel = <String, double>{};
    try {
      final entries = await _historyRepository.getHistoryEntries();
      for (final entry in entries) {
        final current = progressByLevel[entry.levelId] ?? 0.0;
        final entryProgress = entry.isCompleted ? 1.0 : entry.progress;
        if (entryProgress > current) {
          progressByLevel[entry.levelId] =
              entryProgress.clamp(0.0, 1.0).toDouble();
        }
      }
    } catch (_) {
      return const <String, double>{};
    }
    return progressByLevel;
  }

  int? levelNumberFor(String levelId) {
    final allLevels = categories.expand((category) => category.levels).toList();
    final index = allLevels.indexWhere((level) => level.id == levelId);
    if (index == -1) {
      return null;
    }
    return index + 1;
  }

  // ── Points system ─────────────────────────────────────────────────────────

  Future<void> addCompletionPoints(int points) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. coin_history mein sirf EARNED coins (20) insert karo
      await Supabase.instance.client.from('coin_history').insert({
        'user_id': userId,
        'amount': points, // Sirf earned amount (20 coins)
        'description': 'Level Completion',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. user_coins balance update (sum karke)
      _databaseCoins += points;
      await Supabase.instance.client.from('user_coins').upsert({
        'user_id': userId,
        'coins': _databaseCoins,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      notifyListeners();
      print("Level completion: +$points coins. New total: $_databaseCoins");
    } catch (e) {
      print("addCompletionPoints error: $e");
    }
  }

  Future<void> addColorMatchPoints() async {
    _totalPoints += _colorMatchPointsValue;
    // Yahan 3 arguments pass karein
    await _repository.savePoints(_totalPoints, "Color Match Reward", "game");
    notifyListeners();
  }

  Future<int> addDailyBonusPoints() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastBonusStr = await _repository.getLastDailyBonusDate();

    if (lastBonusStr == todayStr) return 0; // Already claimed today

    int streak = await _repository.getCurrentStreak();

    // Streak Calculation Logic
    if (lastBonusStr != null) {
      try {
        final lastBonusDate = DateTime.parse(lastBonusStr);
        final diff = today.difference(lastBonusDate).inDays;
        if (diff == 1) {
          streak += 1;
        } else if (diff > 1) {
          streak = 1; // Streak broken
        }
      } catch (_) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    // Points calculation
    int pointsToAdd = 0;
    if (streak == 1) {
      pointsToAdd = 10;
    } else if (streak == 2) {
      pointsToAdd = 15;
    } else {
      pointsToAdd = 20; // Day 3+
    }

    if (streak == 7) pointsToAdd += 50; // 7 days streak
    if (streak == 30) pointsToAdd += 200; // 30 days streak

    _totalPoints += pointsToAdd;

    // Save points to Supabase with description and type
    await _repository.savePoints(_totalPoints, "Daily Bonus Reward", "bonus");

    await _repository.saveLastDailyBonusDate(todayStr);
    await _repository.saveCurrentStreak(streak);

    notifyListeners();
    return pointsToAdd;
  }

  Future<void> addWelcomeBonus(String userId) async {
    try {
      await Supabase.instance.client.from('coin_history').insert({
        'user_id': userId,
        'amount': 50,
        'description': 'Welcome Bonus',
        'created_at': DateTime.now().toIso8601String(),
      });
      print("Welcome bonus added to coin_history!");

      // Update user_coins as well
      await Supabase.instance.client.from('user_coins').upsert({
        'user_id': userId,
        'coins': 50,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      _databaseCoins = 50;
      notifyListeners();
    } catch (e) {
      print("Welcome bonus error: $e");
    }
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ── Level-unlock refresh ──────────

  Future<void> fetchCoinHistory() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. coin_history se transactions list fetch karo
      final response = await Supabase.instance.client
          .from('coin_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      // 1. History items convert karein (Amounts automatically sanitize ho jayengi fromJson mein)
      final List<CoinHistory> historyObjects = data.map((json) {
        return CoinHistory.fromJson(json as Map<String, dynamic>);
      }).toList();

      setHistory(historyObjects);

      // 2. Galat purane balances fix karne ke liye sum calculate karein
      int calculatedTotal = 0;
      for (var item in historyObjects) {
        calculatedTotal += item.amount;
      }

      // 3. Local aur DB balance ko theek karein
      _databaseCoins = calculatedTotal;
      await Supabase.instance.client.from('user_coins').upsert({
        'user_id': userId,
        'coins': calculatedTotal,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      notifyListeners();

      print(
          "History fetch: ${historyObjects.length} transactions. Corrected Total: $calculatedTotal");
    } catch (e) {
      print("fetchCoinHistory error: $e");
    }
  }

  List<CoinHistory> _historyList = [];

// Isay 'coinHistoryList' kar dein
  List<CoinHistory> get coinHistoryList => _historyList;

  void setHistory(List<CoinHistory> newList) {
    _historyList = newList;
    notifyListeners();
  }

  Future<void> refreshProgress() async {
    try {
      _content = await _repository.loadHomeContent();
    } catch (_) {}
    _levelProgress = await _loadLevelProgress();
    notifyListeners();
  }

// ── Automatic Daily Bonus (Single Function) ──────────────────────────────

  Future<void> checkAndApplyDailyBonus() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return; // Logged out hoga to bonus nahi

    // Aaj ki date (Format: 2026-06-12)
    final String today = DateTime.now().toIso8601String().split('T')[0];

    // Database se last date layein
    final lastClaimed = await _repository.getLastClaimedDate();

    print("Aaj ki date: $today");
    print("DB ki last date: $lastClaimed");

    // LOGIC: Agar aaj ki date aur DB ki date barabar hai, to kuch na karein
    if (lastClaimed == today) {
      print("Daily bonus pehle hi claim ho chuka hai.");
      return;
    }

    // Agar date alag hai, to bonus dein
    int streak = await _repository.getCurrentStreak();
    const int bonus = 10; // Daily bonus hamesha 10 coins

    try {
      // 1. coin_history mein sirf EARNED bonus (10) insert karo
      await Supabase.instance.client.from('coin_history').insert({
        'user_id': userId,
        'amount': bonus, // Sirf 10 coins
        'description': 'Daily Bonus',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. user_coins balance update
      _databaseCoins += bonus;
      await Supabase.instance.client.from('user_coins').upsert({
        'user_id': userId,
        'coins': _databaseCoins,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      // 3. Daily bonus log update karein
      await _repository.saveDailyBonus(today, streak + 1);

      notifyListeners();
      print("Daily bonus successfully diya gaya! +$bonus coins");
    } catch (e) {
      print("Daily bonus error: $e");
    }
  }
}
