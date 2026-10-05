import 'dart:ui';

class Collision {
  static bool intersects(
    Rect a,
    Rect b, {
    double paddingA = 6,
    double paddingB = 4,
  }) {
    return a.deflate(paddingA).overlaps(b.deflate(paddingB));
  }
}
