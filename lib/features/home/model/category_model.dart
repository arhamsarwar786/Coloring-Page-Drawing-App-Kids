import 'package:flutter/material.dart';

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
