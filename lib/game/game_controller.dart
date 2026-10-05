import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../services/app_state.dart';
import 'models/boost.dart';
import 'models/collision.dart';
import 'models/obstacle.dart';
import 'models/player.dart';
import 'models/spawner.dart';

class GameController extends ChangeNotifier {
  GameController({required this.appState}) {
    _startFreshRun();
  }

  final AppState appState;
  final PlayerModel player = PlayerModel();
  final ObstacleSpawner _spawner = ObstacleSpawner();
  final List<ObstacleModel> obstacles = <ObstacleModel>[];

  Size worldSize = Size.zero;

  double timeSurvived = 0;
  double score = 0;

  bool isGameOver = false;
  bool reviveUsed = false;
  bool runFinalized = false;

  int finalScore = 0;
  int coinsEarned = 0;
  int coinsSpentThisRun = 0;

  bool shieldArmed = false;
  double slowMoRemaining = 0;
  double _invulnerabilityRemaining = 0;
  int shieldBreakCount = 0;
  int deathCount = 0;

  static const double _spawnOffset = 96;
  double _spawnCooldown = 0;

  static const int laneCount = 3;

  int get displayScore => score.floor();
  int get runCoinsEarned => (score / 5).floor();
  bool get canRevive => isGameOver && !reviveUsed;
  bool get isInvulnerable => _invulnerabilityRemaining > 0;
  int get netCoinsDelta => coinsEarned - coinsSpentThisRun;

  double get laneWidth => worldSize.width / laneCount;
  double get playerY => worldSize.height * 0.35;
  double get playerWidth => max(40.0, laneWidth * 0.58);
  double get playerHeight => max(48.0, worldSize.height * 0.085);

  double get effectiveSpeed {
    final speed = _spawner.speedForTime(timeSurvived);
    if (slowMoRemaining > 0) {
      return speed * 0.55;
    }
    return speed;
  }

  double get speedProgress {
    final speedSpan = ObstacleSpawner.maxSpeed - ObstacleSpawner.baseSpeed;
    return ((effectiveSpeed - ObstacleSpawner.baseSpeed) / speedSpan).clamp(
      0.0,
      1.0,
    );
  }

  void setWorldSize(Size size) {
    if (size == worldSize) return;
    worldSize = size;
    notifyListeners();
  }

  void moveLeft() {
    if (isGameOver) return;
    final next = (player.lane.index - 1).clamp(0, laneCount - 1);
    player.lane = LaneX.fromIndex(next);
  }

  void moveRight() {
    if (isGameOver) return;
    final next = (player.lane.index + 1).clamp(0, laneCount - 1);
    player.lane = LaneX.fromIndex(next);
  }

  void tick(double dtSeconds) {
    if (worldSize.isEmpty || isGameOver) {
      return;
    }

    final dt = dtSeconds.clamp(0.0, 0.05);
    timeSurvived += dt;
    score += dt * 11;

    _animateLaneSnap(dt);
    _updateBoostTimers(dt);
    _updateObstacles(dt);
    _handleSpawning(dt);
    _checkCollisions();

    notifyListeners();
  }

  Future<bool> activateShield() async {
    if (isGameOver || shieldArmed) return false;
    final consumed = await appState.consumeBoost(BoostType.shield);
    if (!consumed) return false;
    shieldArmed = true;
    notifyListeners();
    return true;
  }

  Future<bool> activateSlowMo() async {
    if (isGameOver || slowMoRemaining > 0.05) return false;
    final consumed = await appState.consumeBoost(BoostType.slowMo);
    if (!consumed) return false;
    slowMoRemaining = 3;
    notifyListeners();
    return true;
  }

  Future<bool> reviveWithCoins() async {
    if (!canRevive) return false;
    final spent = await appState.spendCoins(EconomyConfig.revivePrice);
    if (!spent) return false;
    coinsSpentThisRun += EconomyConfig.revivePrice;
    _applyRevive();
    return true;
  }

  Future<bool> reviveWithAd() async {
    if (!canRevive) return false;
    final rewarded = await appState.adsService.showRewardedReviveAd();
    if (!rewarded) return false;
    _applyRevive();
    return true;
  }

  Future<void> finalizeRunIfNeeded() async {
    if (runFinalized) return;

    if (finalScore == 0) {
      finalScore = displayScore;
      coinsEarned = runCoinsEarned;
    }

    runFinalized = true;
    await appState.addCoins(coinsEarned);
    await appState.updateBestScore(finalScore);
    notifyListeners();
  }

  Future<void> startNewRun() async {
    _startFreshRun();
    notifyListeners();
  }

  Rect playerRect() {
    final laneCenterX = (player.visualLane + 0.5) * laneWidth;
    return Rect.fromCenter(
      center: Offset(laneCenterX, playerY),
      width: playerWidth,
      height: playerHeight,
    );
  }

  Rect obstacleRect(ObstacleModel obstacle) {
    final width = max(38.0, laneWidth * 0.68);
    final centerX = ((obstacle.lane + 0.5) * laneWidth);
    return Rect.fromCenter(
      center: Offset(centerX, obstacle.y),
      width: width,
      height: obstacle.height,
    );
  }

  void _startFreshRun() {
    score = 0;
    timeSurvived = 0;
    isGameOver = false;
    reviveUsed = false;
    runFinalized = false;
    finalScore = 0;
    coinsEarned = 0;
    coinsSpentThisRun = 0;

    shieldArmed = false;
    slowMoRemaining = 0;
    _invulnerabilityRemaining = 0;
    shieldBreakCount = 0;
    deathCount = 0;

    player.lane = Lane.center;
    player.visualLane = Lane.center.index.toDouble();

    obstacles.clear();
    _spawner.reset();
    _spawnCooldown = 0.45;
  }

  void _animateLaneSnap(double dt) {
    final target = player.lane.index.toDouble();
    final delta = target - player.visualLane;
    if (delta.abs() < 0.001) {
      player.visualLane = target;
      return;
    }

    final snapRate = 18 - (speedProgress * 4.2);
    final snapFactor = min(1.0, dt * snapRate);
    player.visualLane += delta * snapFactor;
  }

  void _updateBoostTimers(double dt) {
    if (slowMoRemaining > 0) {
      slowMoRemaining = max(0.0, slowMoRemaining - dt);
    }

    if (_invulnerabilityRemaining > 0) {
      _invulnerabilityRemaining = max(0.0, _invulnerabilityRemaining - dt);
    }
  }

  void _updateObstacles(double dt) {
    final speed = effectiveSpeed;
    for (final obstacle in obstacles) {
      obstacle.y -= speed * dt;
    }

    obstacles.removeWhere((obstacle) => obstacle.y + obstacle.height < -20);
  }

  void _handleSpawning(double dt) {
    _spawnCooldown -= dt;
    if (_spawnCooldown > 0) return;

    if (!_hasMinimumRowDistance()) return;

    final spawnY = worldSize.height + _spawnOffset;
    obstacles.addAll(_spawner.spawnRow(spawnY));
    _spawnCooldown = _spawner.spawnIntervalForTime(timeSurvived);
  }

  bool _hasMinimumRowDistance() {
    if (obstacles.isEmpty) return true;
    final lowestY = obstacles.map((o) => o.y).reduce(max);

    // Maintain fair reaction windows while still making higher speeds harder.
    final reactionSeconds = 0.72 - (0.20 * speedProgress);
    final minDistance = (effectiveSpeed * reactionSeconds).clamp(145.0, 230.0);
    return lowestY <= worldSize.height + _spawnOffset - minDistance;
  }

  void _checkCollisions() {
    if (isInvulnerable) return;

    final playerHitbox = playerRect();

    for (var i = obstacles.length - 1; i >= 0; i--) {
      final obstacle = obstacles[i];
      final hit = Collision.intersects(playerHitbox, obstacleRect(obstacle));
      if (!hit) continue;

      if (shieldArmed) {
        shieldArmed = false;
        shieldBreakCount += 1;
        obstacles.removeAt(i);
        _invulnerabilityRemaining = 0.3;
        return;
      }

      _triggerGameOver();
      return;
    }
  }

  void _triggerGameOver() {
    if (isGameOver) return;

    isGameOver = true;
    deathCount += 1;
    finalScore = displayScore;
    coinsEarned = runCoinsEarned;

    unawaited(appState.registerDeath());
    notifyListeners();
  }

  void _applyRevive() {
    reviveUsed = true;
    isGameOver = false;
    _invulnerabilityRemaining = 2;

    final y = playerY;
    obstacles.removeWhere((obstacle) => (obstacle.y - y).abs() < 140);
    _spawnCooldown = max(_spawnCooldown, 0.5);

    notifyListeners();
  }
}
