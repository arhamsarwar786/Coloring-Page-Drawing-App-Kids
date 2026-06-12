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

  int _databaseCoins = 0;
  int get databaseCoins => _databaseCoins;

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
    } catch (_) {
      setError(AppStrings.loadError);
    }
    setLoading(false);
  }

// 3. Ye function add karein jo Supabase se sum uthaye
  Future<void> fetchDatabaseCoins() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('user_coins')
        .select('coins')
        .eq('user_id', userId);

    final List<dynamic> data = response as List<dynamic>;
    int total = 0;
    for (var item in data) {
      total += (item['coins'] as int);
    }
    _databaseCoins = total;
    notifyListeners();
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
    _databaseCoins += points; // Local variable update
    await _repository.savePoints(
        _databaseCoins, "Level Completion", "level"); // DB save
    notifyListeners(); // UI Refresh
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
  Future<void> fetchCoinHistory() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await Supabase.instance.client
        .from('user_coins')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    setHistory(response as List<dynamic>);
  }

  List<CoinHistory> _coinHistoryList = [];

  List<CoinHistory> get coinHistoryList => _coinHistoryList;

  // Jab database se data aaye:

  void setHistory(List<dynamic> data) {
    _coinHistoryList = data.map((item) => CoinHistory.fromJson(item)).toList();

    notifyListeners();
  }

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
}

class CategorySelectionBar extends StatelessWidget {
  const CategorySelectionBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aapke isi same class wale HomeViewModel ko listen kar raha hai
    final viewModel = context.watch<HomeViewModel>();

    final List<CategoryModel> categories = viewModel.categories;
    final String? selectedId = viewModel.selectedCategory?.id;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffE2E5F8), // Outer pill bar background
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((CategoryModel category) {
          final isSelected = selectedId == category.id;

          return GestureDetector(
            // Bina kisi change ke aapka native view model function call ho raha hai
            onTap: () => viewModel.selectCategory(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xffFFF3DC)
                    : Colors.transparent, // Active yellow capsule
                borderRadius: BorderRadius.circular(30),
                border: isSelected
                    ? Border.all(color: const Color(0xffF9DFB7), width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category.title),
                    size: 32,
                    // Active state par CategoryModel ke andar ka exact accentColor select hoga
                    color: isSelected
                        ? category.accentColor
                        : const Color(0xff6C728E),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.title.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: "Regular",
                      letterSpacing: 0.5,
                      color: isSelected
                          ? const Color(0xff1A1C29)
                          : const Color(0xff6C728E),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Dynamic system icons mapper based on your Category title
  IconData _getCategoryIcon(String title) {
    switch (title.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'animals':
        return Icons.pets;
      case 'vegetables':
        return Icons.grass;
      case 'wild animals':
      case 'wild_animals':
        return Icons.pets;
      case 'colors':
        return Icons.color_lens;
      case 'alphabets':
        return Icons.abc;
      case 'drawing':
        return Icons.brush;
      default:
        return Icons.grid_view_rounded;
    }
  }
}
