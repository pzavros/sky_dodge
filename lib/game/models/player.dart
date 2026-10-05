enum Lane { left, center, right }

extension LaneX on Lane {
  int get index {
    switch (this) {
      case Lane.left:
        return 0;
      case Lane.center:
        return 1;
      case Lane.right:
        return 2;
    }
  }

  static Lane fromIndex(int index) {
    if (index <= 0) return Lane.left;
    if (index >= 2) return Lane.right;
    return Lane.center;
  }
}

class PlayerModel {
  PlayerModel({Lane startLane = Lane.center})
    : lane = startLane,
      visualLane = startLane.index.toDouble();

  Lane lane;
  double visualLane;
}
