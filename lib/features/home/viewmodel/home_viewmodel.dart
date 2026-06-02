import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  HomeContentModel? _content;
  String? _selectedCategoryId;
  String? _lastPlayedLevelId;
  Map<String, double> _levelProgress = const <String, double>{};

  HomeContentModel? get content => _content;
  List<CategoryModel> get categories =>
      _content?.categories ?? const <CategoryModel>[];

  CategoryModel? get selectedCategory {
    if (categories.isEmpty) return null;
    return categories.firstWhere(
      (category) => category.id == _selectedCategoryId,
      orElse: () => categories.first,
    );
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

  Future<void> load() async {
    setLoading(true);
    setError(null);
    try {
      _content = await _repository.loadHomeContent();
      _lastPlayedLevelId = await _repository.getLastPlayedLevelId();
      _levelProgress = await _loadLevelProgress();
      if (_content!.categories.isNotEmpty) {
        final hasCurrentSelection = _content!.categories
            .any((category) => category.id == _selectedCategoryId);
        _selectedCategoryId = hasCurrentSelection
            ? _selectedCategoryId
            : _content!.categories.first.id;
      }
    } catch (_) {
      setError(AppStrings.loadError);
    }
    setLoading(false);
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

    for (var index = 0; index < levelIndex; index++) {
      if (levelProgressFor(levels[index].id) < unlockProgressThreshold) {
        return true;
      }
    }

    return false;
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
