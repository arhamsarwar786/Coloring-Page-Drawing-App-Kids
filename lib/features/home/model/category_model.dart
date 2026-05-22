import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/home/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/color_parser.dart';
import '../../levels/model/level_model.dart';

class HomeContentModel {
  const HomeContentModel({
    required this.appTitle,
    required this.headline,
    required this.dailyGoalText,
    required this.categories,
  });

  final String appTitle;
  final String headline;
  final String dailyGoalText;
  final List<CategoryModel> categories;

  factory HomeContentModel.fromJson(Map<String, dynamic> json) {
    return HomeContentModel(
      appTitle: json['appTitle'] as String,
      headline: json['headline'] as String,
      dailyGoalText: json['dailyGoalText'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((item) =>
              CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  HomeContentModel copyWith({
    List<CategoryModel>? categories,
  }) {
    return HomeContentModel(
      appTitle: appTitle,
      headline: headline,
      dailyGoalText: dailyGoalText,
      categories: categories ?? this.categories,
    );
  }
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.levels,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<LevelModel> levels;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      accentColor: ColorParser.fromHex(json['accentColor'] as String),
      levels: (json['levels'] as List<dynamic>)
          .map((item) =>
              LevelModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  CategoryModel copyWith({
    List<LevelModel>? levels,
  }) {
    return CategoryModel(
      id: id,
      title: title,
      subtitle: subtitle,
      accentColor: accentColor,
      levels: levels ?? this.levels,
    );
  }
}





class CategorySelectionBar extends StatelessWidget {
  const CategorySelectionBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Aapke screen par chalne wale HomeViewModel se state read ho rahi hai
    final viewModel = context.watch<HomeViewModel>();

    final List<CategoryModel> categories = viewModel.categories;
    final String? selectedId = viewModel.selectedCategory?.id;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffE2E5F8), // Outer capsule bluish background
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((CategoryModel category) {
          final isSelected = selectedId == category.id;

          return GestureDetector(
            // HomeViewModel ka native function triggers click logic
            onTap: () => viewModel.selectCategory(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xffFFF3DC)
                    : Colors.transparent, // Active yellow capsule pill
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
                    // Active state par aapke CategoryModel ka exact accentColor bypass ho raha hai
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

  // Model ke dynamic text 'title' ke string evaluation par native design icons matching helper
  IconData _getCategoryIcon(String title) {
    switch (title.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'animals':
        return Icons.pets;
      case 'vehicles':
        return Icons.directions_car;
      case 'shapes':
        return Icons.category;
      default:
        return Icons.grid_view_rounded;
    }
  }
}
