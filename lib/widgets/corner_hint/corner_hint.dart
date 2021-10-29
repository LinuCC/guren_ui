import 'package:flutter/widgets.dart';

import '../../colors.dart';

typedef GenerateHintWidget = Widget Function({required bool highlighted});

GenerateHintWidget generateTextHintWidget(String text) =>
    ({required bool highlighted}) => Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 5.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: highlighted ? GurenColors.black : GurenColors.white,
            ),
          ),
        );
