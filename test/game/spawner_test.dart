import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sky_dodge/game/models/spawner.dart';

void main() {
  test('speed ramps strongly over time and is clamped', () {
    final spawner = ObstacleSpawner(random: Random(1));

    final s0 = spawner.speedForTime(0);
    final s20 = spawner.speedForTime(20);
    final s50 = spawner.speedForTime(50);
    final s120 = spawner.speedForTime(120);
    final s999 = spawner.speedForTime(999);

    expect(s0, ObstacleSpawner.baseSpeed);
    expect(s20, greaterThan(s0));
    expect(s50, greaterThan(s20));
    expect(s120, greaterThan(s50));
    expect(s999, ObstacleSpawner.maxSpeed);
  });

  test('spawn interval changes only slightly over time', () {
    final spawner = ObstacleSpawner(random: Random(1));

    final i0 = spawner.spawnIntervalForTime(0);
    final i60 = spawner.spawnIntervalForTime(60);
    final i200 = spawner.spawnIntervalForTime(200);

    expect(i0, ObstacleSpawner.baseInterval);
    expect(i60, lessThan(i0));
    expect(i200, ObstacleSpawner.minInterval);
  });

  test('spawner never creates all-three-lanes blocked', () {
    final spawner = ObstacleSpawner(random: Random(4));

    for (var i = 0; i < 300; i++) {
      final row = spawner.spawnRow(0);
      expect(row.length <= 2, isTrue);
    }
  });

  test('row after double-block preserves previous safe lane opening', () {
    final spawner = ObstacleSpawner(random: Random(22));

    List<int>? previousBlocked;

    for (var i = 0; i < 500; i++) {
      final row = spawner.spawnRow(0);
      final blocked = row.map((obstacle) => obstacle.lane).toList();

      if (previousBlocked != null && previousBlocked.length == 2) {
        expect(blocked.length, 1);

        final safeLane = _safeLaneFromDouble(previousBlocked);
        expect(blocked.single == safeLane, isFalse);
      }

      previousBlocked = blocked;
    }
  });
}

int _safeLaneFromDouble(List<int> blockedLanes) {
  for (var lane = 0; lane < 3; lane++) {
    if (!blockedLanes.contains(lane)) return lane;
  }
  return 1;
}
