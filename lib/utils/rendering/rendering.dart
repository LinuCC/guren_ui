import 'package:flutter/widgets.dart';

enum GurenPathCornerType { deg90, deg45 }

class GurenPathCorner {
  GurenPathCorner._(this.type);

  factory GurenPathCorner deg90() => GurenPathCorner._(GurenPathCornerType.deg90);

  GurenPathCornerType type;
}

class GurenBoxCorners<T> {
  const GurenBoxCorners({
    this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
  });

  factory GurenBoxCorners.all(T corner) =>
      GurenBoxCorners(
        topLeft: corner,
        topRight: corner,
        bottomRight: corner,
        bottomLeft: corner,
      );

  final T? topLeft;
  final T? topRight;
  final T? bottomRight;
  final T? bottomLeft;
}

Path createPathFillingRectWithCorneredBox({
  required double cornerSize,
  required Size size,
  required GurenBoxCorners<>
}) {

}
