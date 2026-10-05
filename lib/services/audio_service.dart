import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';

abstract class AudioService {
  Future<void> startGameMusic();
  Future<void> stopMusic();
  Future<void> setGamePace(double normalizedSpeed);
  Future<void> playHit();
  Future<void> playLose();
  Future<void> dispose();
}

class GameAudioService implements AudioService {
  GameAudioService();

  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'music');
  final AudioPlayer _sfxPlayer = AudioPlayer(playerId: 'sfx');

  bool _configured = false;
  bool _isMusicPlaying = false;
  double _currentMusicRate = 1.0;
  int _currentPaceTier = 0;
  static const List<double> _paceRates = <double>[1.00, 1.07, 1.14, 1.21, 1.28];

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    _configured = true;

    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _musicPlayer.setVolume(0.45);

    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  @override
  Future<void> startGameMusic() async {
    await _ensureConfigured();
    if (_isMusicPlaying) return;

    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource('audio/bgm_loop.wav'));
      await _musicPlayer.setPlaybackRate(_currentMusicRate);
      _isMusicPlaying = true;
    } catch (error) {
      log('[Audio] Failed to start game music: $error');
    }
  }

  @override
  Future<void> stopMusic() async {
    await _ensureConfigured();
    try {
      await _musicPlayer.stop();
      _isMusicPlaying = false;
    } catch (error) {
      log('[Audio] Failed to stop music: $error');
    }
  }

  @override
  Future<void> setGamePace(double normalizedSpeed) async {
    await _ensureConfigured();
    final clamped = normalizedSpeed.clamp(0.0, 1.0);
    final tier = (clamped * (_paceRates.length - 1)).round();
    if (tier == _currentPaceTier) return;

    _currentPaceTier = tier;
    final nextRate = _paceRates[tier];
    _currentMusicRate = nextRate;
    if (!_isMusicPlaying) return;

    try {
      await _musicPlayer.setPlaybackRate(_currentMusicRate);
    } catch (error) {
      log('[Audio] Failed to set music playback rate: $error');
    }
  }

  @override
  Future<void> playHit() async {
    await _ensureConfigured();
    try {
      await _sfxPlayer.play(AssetSource('audio/hit.wav'), volume: 0.9);
    } catch (error) {
      log('[Audio] Failed to play hit SFX: $error');
    }
  }

  @override
  Future<void> playLose() async {
    await _ensureConfigured();
    try {
      await _sfxPlayer.play(AssetSource('audio/lose.wav'), volume: 1.0);
    } catch (error) {
      log('[Audio] Failed to play lose SFX: $error');
    }
  }

  @override
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

class NoopAudioService implements AudioService {
  const NoopAudioService();

  @override
  Future<void> startGameMusic() async {}

  @override
  Future<void> stopMusic() async {}

  @override
  Future<void> setGamePace(double normalizedSpeed) async {}

  @override
  Future<void> playHit() async {}

  @override
  Future<void> playLose() async {}

  @override
  Future<void> dispose() async {}
}
