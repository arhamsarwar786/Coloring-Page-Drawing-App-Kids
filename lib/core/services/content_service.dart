import 'dart:convert';
import 'package:flutter/services.dart';

class ContentService {
  Map<String, dynamic>? _cachedContent;
  
  Future<Map<String, dynamic>> loadContent() async {
    if (_cachedContent != null) return _cachedContent!;
    
    try {
      final jsonString = await rootBundle.loadString('assets/data/app_content.json');
      _cachedContent = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      _cachedContent = {
        'categories': [],
      };
    }
    return _cachedContent!;
  }
  
  Future<List<dynamic>> getCategories() async {
    final content = await loadContent();
    return content['categories'] as List<dynamic>? ?? [];
  }
  
  Future<Map<String, dynamic>?> getLevelById(String levelId) async {
    final categories = await getCategories();
    for (final category in categories) {
      final levels = category['levels'] as List<dynamic>;
      for (final level in levels) {
        if (level['id'] == levelId) {
          return level as Map<String, dynamic>;
        }
      }
    }
    return null;
  }
  
  Future<List<Map<String, dynamic>>> getAllLevels() async {
    final categories = await getCategories();
    final List<Map<String, dynamic>> allLevels = [];
    for (final category in categories) {
      final levels = category['levels'] as List<dynamic>;
      for (final level in levels) {
        allLevels.add(level as Map<String, dynamic>);
      }
    }
    return allLevels;
  }

  Future<int> getLevelIndex(String levelId) async {
    final allLevels = await getAllLevels();
    return allLevels.indexWhere((level) => level['id'] == levelId);
  }
  
  Future<Map<String, dynamic>?> getNextLevel(String currentLevelId) async {
    final allLevels = await getAllLevels();
    final index = allLevels.indexWhere((level) => level['id'] == currentLevelId);
    if (index != -1 && index + 1 < allLevels.length) {
      return allLevels[index + 1];
    }
    return null;
  }
}
