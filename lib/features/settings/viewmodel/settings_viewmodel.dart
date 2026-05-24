import 'dart:async';

import '../../../shared/services/app_preferences_service.dart';
import '../../../core/base/base_viewmodel.dart';
import '../../sound/services/sound_service.dart';

class SettingsViewModel extends BaseViewModel {
  SettingsViewModel({
    required AppPreferencesService preferencesService,
    required SoundService soundService,
  })  : _preferencesService = preferencesService,
        _soundService = soundService;

  final AppPreferencesService _preferencesService;
  final SoundService _soundService;

  bool _musicEnabled = true;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  Future<void>? _loadingFuture;

  bool get musicEnabled => _musicEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  Future<void> ensureLoaded() {
    return _loadingFuture ??= _load();
  }

  Future<void> _load() async {
    final preferences = await _preferencesService.load();
    _musicEnabled = preferences.musicEnabled;
    _soundEnabled = preferences.soundEnabled;
    _hapticsEnabled = preferences.hapticsEnabled;
    await _soundService.setMusicEnabled(_musicEnabled);
    _soundService.setSoundEnabled(_soundEnabled);
    _soundService.setHapticsEnabled(_hapticsEnabled);
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    notifyListeners();
    await _soundService.setMusicEnabled(_musicEnabled);
    await _persist();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    _soundService.setSoundEnabled(_soundEnabled);
    notifyListeners();
    if (_soundEnabled) {
      await _soundService.playTapFeedback();
    }
    await _persist();
  }

  Future<void> toggleHaptics() async {
    _hapticsEnabled = !_hapticsEnabled;
    _soundService.setHapticsEnabled(_hapticsEnabled);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() {
    return _preferencesService.save(
      AppPreferencesModel(
        musicEnabled: _musicEnabled,
        soundEnabled: _soundEnabled,
        hapticsEnabled: _hapticsEnabled,
      ),
    );
  }
}
