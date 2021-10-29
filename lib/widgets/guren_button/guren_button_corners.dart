import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:guren_ui/colors.dart';
import 'package:guren_ui/widgets/corner_hint/corner_hint.dart';

enum GurenButtonCornerType { none, empty, highlight, hint, hintAndHighlight }

@immutable
class GurenButtonCorner {
  const GurenButtonCorner._({required this.type, this.highlighted, this.hint});

  factory GurenButtonCorner.none() =>
      const GurenButtonCorner._(type: GurenButtonCornerType.none);
  factory GurenButtonCorner.empty() =>
      const GurenButtonCorner._(type: GurenButtonCornerType.empty);
  factory GurenButtonCorner.highlight(bool highlighted) => GurenButtonCorner._(
        type: GurenButtonCornerType.highlight,
        highlighted: highlighted,
      );
  factory GurenButtonCorner.hintAndHighlight(
          GenerateHintWidget hint, bool highlighted) =>
      GurenButtonCorner._(
        type: GurenButtonCornerType.hintAndHighlight,
        highlighted: highlighted,
        hint: hint,
      );

  bool isCornerCut() =>
      type == GurenButtonCornerType.empty ||
      type == GurenButtonCornerType.hint ||
      type == GurenButtonCornerType.highlight ||
      type == GurenButtonCornerType.hintAndHighlight;

  final GurenButtonCornerType type;
  final bool? highlighted;
  final GenerateHintWidget? hint;
}

@immutable
class GurenButtonCorners {
  const GurenButtonCorners({
    this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
  });

  factory GurenButtonCorners.all(GurenButtonCorner corner) =>
      GurenButtonCorners(
        topLeft: corner,
        topRight: corner,
        bottomRight: corner,
        bottomLeft: corner,
      );

  final GurenButtonCorner? topLeft;
  final GurenButtonCorner? topRight;
  final GurenButtonCorner? bottomRight;
  final GurenButtonCorner? bottomLeft;
}
