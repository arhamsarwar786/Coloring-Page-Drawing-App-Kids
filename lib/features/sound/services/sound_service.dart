import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class SoundService with WidgetsBindingObserver {
  SoundService() {
    WidgetsBinding.instance.addObserver(this);
  }

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
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
    if (!_musicEnabled) return;
    try {
      if (_backgroundStarted) {
        await _player.resume();
      } else {
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.setVolume(0.55);
        await _player.play(AssetSource('audio/piano_bg.mp3'));
        _backgroundStarted = true;
      }
    } catch (_) {
      // ignore errors if audio cannot be played
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startBackgroundMusic();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      stopBackgroundMusic();
    }
  }

  Future<void> playBrushFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.selectionClick();
  }

  Future<void> playFillFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.lightImpact();
    if (_soundEnabled) {
      try {
        await _sfxPlayer.play(AssetSource('audio/piano_tap.mp3'));
      } catch (_) {}
    }
  }

  Future<void> playCompletionFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.mediumImpact();
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await stopBackgroundMusic();
    await _player.dispose();
    await _sfxPlayer.dispose();
  }
}
