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

// 3. Ye function add karein jo Supabase se sum uthaye
  // Future<void> fetchDatabaseCoins() async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   final response = await Supabase.instance.client
  //       .from('user_coins')
  //       .select('coins')
  //       .eq('user_id', userId);

  //   final List<dynamic> data = response as List<dynamic>;
  //   int total = 0;
  //   for (var item in data) {
  //     total += (item['coins'] as int);
  //   }
  //   _databaseCoins = total;
  //   notifyListeners();
  // }

  Future<void> fetchDatabaseCoins() async {
    setLoading(true); // Data fetch shuru hone se pehle true karein

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final List<dynamic> data = await Supabase.instance.client
            .from('user_coins')
            .select('coins')
            .eq('user_id', userId);

        int total = 0;
        for (var item in data) {
          total += (item['coins'] as int? ?? 0);
        }
        _databaseCoins = total;
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setLoading(
          false); // Data fetch ho jaye ya error aaye, loading band kar dein
    }
  }

  // Future<void> fetchDatabaseCoins() async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   try {
  //     // 1. Supabase se response lein
  //     final List<dynamic> data = await Supabase.instance.client
  //         .from('user_coins')
  //         .select('coins')
  //         .eq('user_id', userId);

  //     // 2. Total calculate karein (Safety ke sath)
  //     int total = 0;
  //     for (var item in data) {
  //       // 'coins' ko int mein convert karein, agar null ho toh 0 lein
  //       total += (item['coins'] as int? ?? 0);
  //     }

  //     _databaseCoins = total;
  //     print("Database total coins updated: $_databaseCoins");

  //     // 3. UI refresh karein
  //     notifyListeners();
  //   } catch (e) {
  //     print("Error fetching coins: $e");
  //   }
  // }

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

  /// Adds points when a level is fully completed.
  // Future<void> addCompletionPoints(int points) async {
  //   _totalPoints += points;
  //   await _repository.savePoints(_totalPoints);
  //   notifyListeners();
  // }

  // Future<void> addCompletionPoints(int points) async {
  //   _totalPoints += points;
  //   // Yahan 3 arguments pass karein
  //   await _repository.savePoints(_totalPoints, "Level Completion", "level");
  //   notifyListeners();
  // }

  Future<void> addCompletionPoints(int points) async {
    // 1. Pehle current balance mein naye points add karein
    int newTotal = _databaseCoins + points;

    // 2. Repository ko bolen ke DB update kare aur history mein add kare
    await _repository.savePoints(newTotal, "Level Completion", "level");

    // 3. Local state update karein
    _databaseCoins = newTotal;

    // 4. UI refresh karein
    notifyListeners();
  }
  // Future<void> addCompletionPoints(int points) async {
  //   _databaseCoins += points; // Local variable update
  //   await _repository.savePoints(
  //       _databaseCoins, "Level Completion", "level"); // DB save
  //   notifyListeners(); // UI Refresh
  // }

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
        // Table name change
        'user_id': userId,
        'amount': 50, // Column name is 'amount' in your table
        'description': 'Welcome Bonus',
        'created_at': DateTime.now().toIso8601String(),
      });
      print("Welcome bonus added to coin_history!");
    } catch (e) {
      print("Error: $e");
    }
  }
  // Future<void> addWelcomeBonus(String userId) async {
  //   try {
  //     await Supabase.instance.client.from('user_coins').insert({
  //       'user_id': userId,
  //       'coins': 50,
  //       'description': 'Welcome Bonus',
  //       'created_at': DateTime.now().toIso8601String(),
  //     });
  //     print("Welcome bonus added!");
  //   } catch (e) {
  //     print("Bonus add karne mein error: $e");
  //   }
  // }

  // /// Adds 10 points when the child picks the correct colour for a region.
  // Future<void> addColorMatchPoints() async {
  //   _totalPoints += _colorMatchPointsValue;
  //   await _repository.savePoints(_totalPoints);
  //   notifyListeners();
  // }

  // /// Adds daily and streak bonus points.
  // /// Returns the amount of bonus points awarded (0 if already claimed).
  // Future<int> addDailyBonusPoints() async {
  //   final today = DateTime.now();
  //   final todayStr =
  //       '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  //   final lastBonusStr = await _repository.getLastDailyBonusDate();

  //   if (lastBonusStr == todayStr) return 0; // already claimed today

  //   int streak = await _repository.getCurrentStreak();

  //   if (lastBonusStr != null) {
  //     try {
  //       final lastBonusDate = DateTime.parse(lastBonusStr);
  //       final diff = today.difference(lastBonusDate).inDays;
  //       if (diff == 1) {
  //         streak += 1;
  //       } else if (diff > 1) {
  //         streak = 1; // Streak broken
  //       }
  //     } catch (_) {
  //       streak = 1;
  //     }
  //   } else {
  //     streak = 1;
  //   }

  //   int pointsToAdd = 0;
  //   if (streak == 1)
  //     pointsToAdd += 10;
  //   else if (streak == 2)
  //     pointsToAdd += 15;
  //   else
  //     pointsToAdd += 20; // Day 3+

  //   if (streak == 7) pointsToAdd += 50; // 7 days streak
  //   if (streak == 30) pointsToAdd += 200; // 30 days streak

  //   _totalPoints += pointsToAdd;
  //   await _repository.savePoints(_totalPoints);
  //   await _repository.saveLastDailyBonusDate(todayStr);
  //   await _repository.saveCurrentStreak(streak);
  //   notifyListeners();
  //   return pointsToAdd;
  // }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ── Level-unlock refresh ──────────

  // Future<void> fetchCoinHistory() async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   final response = await Supabase.instance.client
  //       .from('coin_history')
  //       .select()
  //       .eq('user_id', userId)
  //       .order('created_at', ascending: false);

  //   // Yahan conversion zaroori hai
  //   final List<dynamic> data = response as List<dynamic>;

  //   // Map se CoinHistory object banayein
  //   final List<CoinHistory> historyObjects = data.map((json) {
  //     return CoinHistory.fromJson(json as Map<String, dynamic>);
  //   }).toList();

  //   setHistory(historyObjects);
  // }

  Future<void> fetchCoinHistory() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await Supabase.instance.client
          .from('coin_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      // 1. History items convert karein
      final List<CoinHistory> historyObjects = data.map((json) {
        return CoinHistory.fromJson(json as Map<String, dynamic>);
      }).toList();

      // --- YE NAYA KAAM HAI ---
      // 2. Total balance calculate karein
      int total = 0;
      for (var item in historyObjects) {
        total += item.amount; // Har item ka amount total mein add karein
      }

      _databaseCoins = total; // Total balance ko update karein
      // ------------------------

      setHistory(historyObjects); // Aapka purana function
      notifyListeners(); // UI ko batayein ke ab coins update ho gaye hain

      print(
          "History fetch successful: ${historyObjects.length} items, Total: $total");
    } catch (e) {
      print("History fetch error: $e");
    }
  }
  // Future<void> fetchCoinHistory() async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   try {
  //     final response = await Supabase.instance.client
  //         .from('coin_history')
  //         .select()
  //         .eq('user_id', userId)
  //         .order('created_at', ascending: false);

  //     // Supabase v2 mein response directly list hota hai
  //     final List<dynamic> data = response as List<dynamic>;

  //     final List<CoinHistory> historyObjects = data.map((json) {
  //       return CoinHistory.fromJson(json as Map<String, dynamic>);
  //     }).toList();

  //     setHistory(historyObjects);
  //     print("History fetch successful: ${historyObjects.length} items");
  //   } catch (e) {
  //     print("History fetch error: $e");
  //   }
  // }

  // Future<void> fetchCoinHistory() async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   final response = await Supabase.instance.client
  //       .from('coin_history')
  //       .select()
  //       .eq('user_id', userId)
  //       .order('created_at', ascending: false);

  //   // Yahan conversion karein:
  //   final List<dynamic> data = response as List<dynamic>;
  //   final historyObjects =
  //       data.map((item) => CoinHistory.fromJson(item)).toList();

  //   setHistory(historyObjects); // Ab ye List<CoinHistory> hai
  // }

  // Future<void> fetchCoinHistory() async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   final response = await Supabase.instance.client
  //       .from('coin_history')
  //       .select()
  //       .eq('user_id', userId)
  //       .order('created_at', ascending: false);
  //   print("Supabase se aya data: $response");

  //   setHistory(response as List<dynamic>);
  // }

  // ViewModel mein ye list variable hona chahiye
  // List<CoinHistory> _historyList = [];
  // List<CoinHistory> get historyList => _historyList;

  // void setHistory(List<CoinHistory> newList) {
  //   _historyList = newList;
  //   notifyListeners();
  // }

  // ViewModel mein ye change karein
  List<CoinHistory> _historyList = [];

// Isay 'coinHistoryList' kar dein
  List<CoinHistory> get coinHistoryList => _historyList;

  void setHistory(List<CoinHistory> newList) {
    _historyList = newList;
    notifyListeners();
  }

  // List<CoinHistory> _coinHistoryList = [];

  // List<CoinHistory> get coinHistoryList => _coinHistoryList;

  // Jab database se data aaye:

  // void setHistory(List<dynamic> data) {
  //   _coinHistoryList = data.map((item) => CoinHistory.fromJson(item)).toList();

  //   notifyListeners();
  // }

  /// Lightweight refresh: reloads level-progress data and notifies the UI
  /// to redraw lock states. Much cheaper than a full [load()] since it does
  /// not re-parse content assets.
  Future<void> refreshProgress() async {
    try {
      _content = await _repository.loadHomeContent();
    } catch (_) {}
    _levelProgress = await _loadLevelProgress();
    notifyListeners();
  }

// ── Automatic Daily Bonus (Single Function) ──────────────────────────────

  Future<void> checkAndApplyDailyBonus() async {
    // Aaj ki date (Format: 2026-06-12)
    final String today = DateTime.now().toIso8601String().split('T')[0];

    // Database se last date layein
    final lastClaimed = await _repository.getLastClaimedDate();

    print("Aaj ki date: $today");
    print("DB ki last date: $lastClaimed");

    // LOGIC: Agar aaj ki date aur DB ki date barabar hai, to kuch na karein
    if (lastClaimed == today) {
      print("Bonus pehle hi claim ho chuka hai.");
      return; // Yahan se ruk jayega, aage nahi badhega
    }

    // Agar date alag hai, to bonus dein
    int streak = await _repository.getCurrentStreak();
    int bonus = 10; // Apna logic yahan rakhein

    _databaseCoins += bonus;

    // 1. Coins save karein
    await _repository.savePoints(
        _databaseCoins, "Automatic Daily Bonus", "bonus");

    // 2. Date update karein taake dobara na mile
    await _repository.saveDailyBonus(today, streak + 1);

    notifyListeners();
    print("Bonus successfully diya gaya!");
  }

//   Future<void> checkAndApplyDailyBonus() async {
//     final String today =
//         DateTime.now().toIso8601String().split('T')[0]; // Format: 2026-06-12

//     // 1. Pehle database se check karein ke kya aaj bonus mila hai
//     final lastClaimed = await _repository.getLastClaimedDate();

//     // Agar lastClaimed aaj ki date hai, to kuch mat karein
//     if (lastClaimed == today) {
//       print("Aaj bonus mil chuka hai, dubara nahi denge.");
//       return;
//     }

//     // 2. Agar nahi mila, to bonus dein
//     int streak = await _repository.getCurrentStreak();
//     int bonus = 10;

//     await _repository.savePoints(
//         _databaseCoins + bonus, "Automatic Daily Bonus", "bonus");
//     await _repository.saveDailyBonus(today, streak + 1);

//     print("Bonus successfully applied!");
//   }

//   Future<int> claimDailyBonus() async {
//   final String today = DateTime.now().toIso8601String().split('T')[0];
//   final lastClaimed = await _repository.getLastClaimedDate();

//   if (lastClaimed == today) {
//     return 0; // No bonus if already claimed
//   }

//   int streak = await _repository.getCurrentStreak();
//   int bonus = (streak >= 7) ? 50 : 10;

//   // Update total coins
//   _databaseCoins += bonus;

//   // Save to database (using the CORRECT function name from repository)
//   await _repository.savePoints(_databaseCoins, "Automatic Daily Bonus", "bonus");

//   // Update streak in database
//   await _repository.saveDailyBonus(today, streak + 1);

//   return bonus; // Return the amount of bonus given
// }
  // Future<void> checkAndApplyDailyBonus() async {
  //   final String today = _todayDateString();
  //   final lastClaimed = await _repository.getLastClaimedDate();

  //   if (lastClaimed == null || lastClaimed != today) {
  //     int streak = await _repository.getCurrentStreak();

  //     // Streak logic fix: Agar last claim kal thi, to streak barhao, warna reset karo
  //     // (Aapke repository ke logic ke hisaab se)
  //     int bonus = (streak >= 7) ? 50 : 10;

  //     _databaseCoins += bonus;

  //     // Save points (Ensure karein ke ye function repository mein moujood hai)
  //     await _repository.savePoints(
  //         _databaseCoins, "Automatic Daily Bonus", "bonus");

  //     // Streak ko bhi update karein
  //     await _repository.saveDailyBonus(today, streak + 1);

  //     notifyListeners();
  //   }
  // }

// Future<void> checkAndApplyDailyBonus() async {
//   final String today = _todayDateString(); // Aapka purana helper use kiya

//   // 1. Database se check karein
//   final lastClaimed = await _repository.getLastClaimedDate();

//   // 2. Agar bonus nahi mila (null hai ya aaj ki date nahi hai)
//   if (lastClaimed == null || lastClaimed != today) {
//     int streak = await _repository.getCurrentStreak();

//     // Streak logic update (agar kal bonus nahi liya to streak 1 ho jaye)
//     // Ye aapke purane logic se sync hai
//     int bonus = (streak >= 7) ? 50 : 10;

//     // Point update
//     _databaseCoins += bonus; // Aapne coins ke liye _databaseCoins use kiya hai

//     // Save to DB
//     await _repository.savePoints(_databaseCoins, "Automatic Daily Bonus", "bonus");
//     await _repository.saveDailyBonus(today, streak + 1);

//     notifyListeners();
//   }
// }
}

// class CategorySelectionBar extends StatelessWidget {
//   const CategorySelectionBar({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Aapke isi same class wale HomeViewModel ko listen kar raha hai
//     final viewModel = context.watch<HomeViewModel>();

//     final List<CategoryModel> categories = viewModel.categories;
//     final String? selectedId = viewModel.selectedCategory?.id;

//     if (categories.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xffE2E5F8), // Outer pill bar background
//         borderRadius: BorderRadius.circular(40),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: categories.map((CategoryModel category) {
//           final isSelected = selectedId == category.id;

//           return GestureDetector(
//             // Bina kisi change ke aapka native view model function call ho raha hai
//             onTap: () => viewModel.selectCategory(category.id),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               curve: Curves.easeInOut,
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? const Color(0xffFFF3DC)
//                     : Colors.transparent, // Active yellow capsule
//                 borderRadius: BorderRadius.circular(30),
//                 border: isSelected
//                     ? Border.all(color: const Color(0xffF9DFB7), width: 1.5)
//                     : null,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     _getCategoryIcon(category.title),
//                     size: 32,
//                     // Active state par CategoryModel ke andar ka exact accentColor select hoga
//                     color: isSelected
//                         ? category.accentColor
//                         : const Color(0xff6C728E),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     category.title.toUpperCase(),
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                       fontFamily: "Regular",
//                       letterSpacing: 0.5,
//                       color: isSelected
//                           ? const Color(0xff1A1C29)
//                           : const Color(0xff6C728E),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // Dynamic system icons mapper based on your Category title
//   IconData _getCategoryIcon(String title) {
//     switch (title.toLowerCase()) {
//       case 'fruits':
//         return Icons.apple;
//       case 'animals':
//         return Icons.pets;
//       case 'vegetables':
//         return Icons.grass;
//       case 'wild animals':
//       case 'wild_animals':
//         return Icons.pets;
//       case 'colors':
//         return Icons.color_lens;
//       case 'alphabets':
//         return Icons.abc;
//       case 'drawing':
//         return Icons.brush;
//       default:
//         return Icons.grid_view_rounded;
//     }
//   }
// }
