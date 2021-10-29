import 'package:flutter/widgets.dart';
import 'package:guren_ui/widgets/corner_hint/corner_hint.dart';

enum GurenCardCornerType { none, empty, highlight, hint, hintAndHighlight, mainAction }

@immutable
class GurenCardCorner {
  const GurenCardCorner._({required this.type, this.highlighted, this.hint});

  factory GurenCardCorner.none() =>
      const GurenCardCorner._(type: GurenCardCornerType.none);
  factory GurenCardCorner.empty() =>
      const GurenCardCorner._(type: GurenCardCornerType.empty);
  factory GurenCardCorner.highlight(bool highlighted) => GurenCardCorner._(
        type: GurenCardCornerType.highlight,
        highlighted: highlighted,
        );
  factory GurenCardCorner.hintAndHighlight(
          GenerateHintWidget hint, bool highlighted) =>
      GurenCardCorner._(
        type: GurenCardCornerType.hintAndHighlight,
        highlighted: highlighted,
        hint: hint,
      );

  final GurenCardCornerType type;
  final bool? highlighted;
  final GenerateHintWidget? hint;
}
