import 'dart:convert';

import 'local_storage_base.dart';

class AppPreferencesService {
  AppPreferencesService({required LocalStorageService storage})
      : _storage = storage;

  static const String _fileName = 'asmr_drawing_preferences.json';
  final LocalStorageService _storage;

  Future<AppPreferencesModel> load() async {
    final raw = await _storage.read(_fileName);
    if (raw == null || raw.isEmpty) return const AppPreferencesModel();
    try {
      return AppPreferencesModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppPreferencesModel();
    }
  }

  Future<void> save(AppPreferencesModel preferences) {
    return _storage.write(
        _fileName, jsonEncode(preferences.toJson()));
  }
}

class AppPreferencesModel {
  const AppPreferencesModel({
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final bool musicEnabled;
  final bool soundEnabled;
  final bool hapticsEnabled;

  factory AppPreferencesModel.fromJson(Map<String, dynamic> json) {
    return AppPreferencesModel(
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }

  AppPreferencesModel copyWith({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return AppPreferencesModel(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'musicEnabled': musicEnabled,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
    };
  }
}
