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
  bool _disposed = false;
  bool _appInForeground = true;

  bool get musicEnabled => _musicEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  Future<void> setMusicEnabled(bool value) async {
    if (_disposed) return;
    _musicEnabled = value;
    if (value && _appInForeground) {
      await startBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  void setSoundEnabled(bool value) {
    if (_disposed) return;
    _soundEnabled = value;
  }

  void setHapticsEnabled(bool value) {
    if (_disposed) return;
    _hapticsEnabled = value;
  }

  Future<void> startBackgroundMusic() async {
    if (_disposed || !_musicEnabled || !_appInForeground) return;
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
    if (_disposed) return;
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> stopAllAudio() async {
    if (_disposed) return;
    await stopBackgroundMusic();
    try {
      await _sfxPlayer.stop();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _appInForeground = true;
      startBackgroundMusic();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _appInForeground = false;
      stopAllAudio();
    } else if (state == AppLifecycleState.detached) {
      _appInForeground = false;
      dispose();
    }
  }

  Future<void> playTapFeedback() async {
    if (_hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }

    await _playTapSound();
  }

  Future<void> playBrushFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.selectionClick();
  }

  Future<void> playFillFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.lightImpact();
    await _playTapSound();
  }

  Future<void> playCompletionFeedback() async {
    if (_hapticsEnabled) await HapticFeedback.mediumImpact();
  }

  Future<void> _playTapSound() async {
    if (_disposed || !_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/click.mp3'));
    } catch (_) {}
  }

  Future<void> dispose() async {
    if (_disposed) return;
    WidgetsBinding.instance.removeObserver(this);
    await stopAllAudio();
    _disposed = true;
    await _player.dispose();
    await _sfxPlayer.dispose();
  }
}
