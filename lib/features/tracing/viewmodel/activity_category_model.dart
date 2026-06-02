import 'package:flutter/material.dart';

class ActivityCategoryModel {
  final String name;
  final String imagePath;
  final String description;
  final String backgroundImagePath;
  final Color buttonColor;

  ActivityCategoryModel({
    required this.name,
    required this.imagePath,
    required this.description,
    required this.backgroundImagePath,
    required this.buttonColor,
  });
}
