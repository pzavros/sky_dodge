import 'dart:math';

import 'obstacle.dart';

class ObstacleSpawner {
  ObstacleSpawner({Random? random}) : _random = random ?? Random();

  static const double baseSpeed = 285;
  static const double maxSpeed = 760;
  static const double baseInterval = 1.05;
  static const double minInterval = 0.68;

  final Random _random;
  int? _protectedLaneForNextRow;

  double speedForTime(double timeSurvived) {
    // Difficulty ramps mostly through speed, with a clear late-game push.
    final t = timeSurvived;
    final earlyRamp = 1 - exp(-t / 22);
    final lateBoost = t > 28 ? (t - 28) * 3.4 : 0.0;
    final speed = baseSpeed + (earlyRamp * 235) + lateBoost;
    return speed.clamp(baseSpeed, maxSpeed);
  }

  double spawnIntervalForTime(double timeSurvived) {
    // Keep frequency secondary, but still tighten as speed rises.
    final interval = baseInterval - (timeSurvived * 0.0035);
    return interval.clamp(minInterval, baseInterval);
  }

  List<ObstacleModel> spawnRow(double spawnY) {
    final blockedLanes = _pickPattern();
    if (blockedLanes.length == 2) {
      _protectedLaneForNextRow = _safeLaneForDoubleBlock(blockedLanes);
    } else {
      _protectedLaneForNextRow = null;
    }

    return blockedLanes
        .map((lane) => ObstacleModel(lane: lane, y: spawnY))
        .toList();
  }

  void reset() {
    _protectedLaneForNextRow = null;
  }

  List<int> _pickPattern() {
    // Patterns intentionally avoid blocking all 3 lanes.
    const singleLanePatterns = <List<int>>[
      [0],
      [1],
      [2],
    ];
    const doubleLanePatterns = <List<int>>[
      [0, 1],
      [0, 2],
      [1, 2],
    ];

    final protectedLane = _protectedLaneForNextRow;
    if (protectedLane != null) {
      // Fairness guard: after a two-block row, guarantee a single blocker that
      // keeps the previous safe lane open.
      final candidates = singleLanePatterns
          .where((pattern) => pattern.first != protectedLane)
          .toList(growable: false);
      return candidates[_random.nextInt(candidates.length)];
    }

    final roll = _random.nextDouble();
    if (roll < 0.60) {
      // Slight bias toward single-lane blocks to keep the run fair.
      return singleLanePatterns[_random.nextInt(singleLanePatterns.length)];
    }
    return doubleLanePatterns[_random.nextInt(doubleLanePatterns.length)];
  }

  int _safeLaneForDoubleBlock(List<int> blockedLanes) {
    for (var lane = 0; lane < 3; lane++) {
      if (!blockedLanes.contains(lane)) {
        return lane;
      }
    }
    return 1;
  }
}
