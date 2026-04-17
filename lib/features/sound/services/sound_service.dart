import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  SoundService();

  final AudioPlayer _player = AudioPlayer();
  bool _musicEnabled = true;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  bool _backgroundStarted = false;

  bool get musicEnabled => _musicEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    if (value) {
      await startBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
  }

  void setHapticsEnabled(bool value) {
    _hapticsEnabled = value;
  }

  Future<void> startBackgroundMusic() async {
    if (!_musicEnabled || _backgroundStarted) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.55);
      
      // Try wav first, then mp3
      try {
        await _player.play(AssetSource('sounds/background.wav'));
        _backgroundStarted = true;
      } catch (_) {
        await _player.play(AssetSource('sounds/background.mp3'));
        _backgroundStarted = true;
      }
    } catch (_) {
      // ignore errors if audio cannot be played
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (!_backgroundStarted) return;
    try {
      await _player.stop();
    } catch (_) {}
    _backgroundStarted = false;
  }

  Future<void> playBrushFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.selectionClick();
    if (_soundEnabled) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playFillFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.lightImpact();
    if (_soundEnabled) await SystemSound.play(SystemSoundType.click);
  }

  Future<void> playCompletionFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.mediumImpact();
    if (_soundEnabled) await SystemSound.play(SystemSoundType.alert);
  }
}
