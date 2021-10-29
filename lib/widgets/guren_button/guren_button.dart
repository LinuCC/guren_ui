import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:guren_ui/widgets/corner_hint/corner_hint.dart';

import '../../colors.dart';
import 'guren_button_corners.dart';

class GurenButton extends HookWidget {
  const GurenButton({
    required this.child,
    this.hint,
    this.highlighted,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final GenerateHintWidget? hint;
  final bool? highlighted;

  @override
  Widget build(BuildContext context) {
    GurenButtonCorner topLeftCorner;
    if (hint != null && highlighted != null) {
      topLeftCorner = GurenButtonCorner.hintAndHighlight(hint!, highlighted!);
    } else if (highlighted != null) {
      topLeftCorner = GurenButtonCorner.highlight(highlighted!);
    } else {
      topLeftCorner = GurenButtonCorner.none();
    }
    return GurenButtonBase(
      child: child,
      corners: GurenButtonCorners(
        topLeft: topLeftCorner,
        topRight: GurenButtonCorner.empty(),
        bottomRight: GurenButtonCorner.none(),
        bottomLeft: GurenButtonCorner.empty(),
      ),
    );
  }
}

class GurenButtonBase extends HookWidget {
  GurenButtonBase({
    required this.child,
    this.corners = const GurenButtonCorners(),
    this.cornerSize = 30,
    EdgeInsets? innerPadding,
    Key? key,
  }) : super(key: key) {
    this.innerPadding =
        innerPadding ?? EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  }

  final Widget child;
  final GurenButtonCorners corners;
  final double cornerSize;
  late final EdgeInsets innerPadding;

  @override
  Widget build(BuildContext context) {
    final animationController =
        useAnimationController(duration: const Duration(milliseconds: 3000))
          ..drive(CurveTween(curve: Curves.easeInQuad));
    final highlightAnimationController =
        useAnimationController(duration: const Duration(milliseconds: 150))
          ..drive(CurveTween(curve: Curves.easeOutQuad));

    useEffect(() {
      animationController.forward();
    }, []);

    return GestureDetector(
      onTapDown: (_) {
        highlightAnimationController.forward();
      },
      onTapUp: (_) {
        if (highlightAnimationController.isAnimating) {
          listen(status) async {
            if (status == AnimationStatus.completed) {
              await Future.delayed(Duration(milliseconds: 300));
              highlightAnimationController.reverse();
              highlightAnimationController.removeStatusListener(listen);
            }
          }

          highlightAnimationController.addStatusListener(listen);
        } else {
          highlightAnimationController.reverse();
        }
      },
      onTapCancel: () {
        highlightAnimationController.reverse();
      },
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [animationController, highlightAnimationController]),
          builder: (context, animatedChild) {
            return CustomPaint(
              painter: GurenButtonPainter(
                progress: animationController.value,
                highlightProgress: highlightAnimationController.value,
                corners: corners,
                maxCornerSize: cornerSize,
              ),
              child: Stack(
                children: [
                  if (corners.topLeft?.hint != null)
                    SizedBox.fromSize(
                      size: Size(cornerSize - 4, cornerSize - 4),
                      child: corners.topLeft!.hint!.call(
                        highlighted: corners.topLeft?.highlighted ?? false,
                      ),
                    ),
                  animatedChild!,
                ],
              ),
            );
          },
          child: FadeTransition(
            opacity: animationController,
            child: Padding(
              padding: innerPadding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GurenButtonPainter extends CustomPainter {
  const GurenButtonPainter({
    required this.progress,
    required this.highlightProgress,
    required this.corners,
    this.maxCornerSize = 30,
  });

  /// How "full" the border is being drawn
  final double progress;

  /// Highlights the button
  final double highlightProgress;
  final GurenButtonCorners corners;
  final double maxCornerSize;

  static const double fadeInAtProgress = 0.5;
  static const double borderThickness = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < double.minPositive &&
        highlightProgress < double.minPositive) {
      return;
    }

    final cornerSize = min(maxCornerSize, min(size.width / 2, size.height / 2));
    final fillProgress =
        ((progress - fadeInAtProgress) / (1 - fadeInAtProgress));

    final infillPaint = Paint()
      ..color = GurenColors.crimsonLight.withAlpha((128 * fillProgress).round())
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.butt;
    final borderPaint = Paint()
      ..color = GurenColors.crimson
      ..strokeWidth = borderThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final borderActivePaint = Paint()
      ..color = GurenColors.crimsonLight
      ..strokeWidth = borderThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = borderPath(cornerSize: cornerSize, size: size);

    // TODO Optimizations for PathMetrics generated from the same path for these animations
    if (progress < fadeInAtProgress) {
      final borderProgress = min<double>(progress / fadeInAtProgress, 1.0);
      animatePathDualBorderEmptyToComplete(
        canvas: canvas,
        path: path,
        progress: borderProgress,
        paint: borderPaint,
      );
    } else {
      // Animate fill
      canvas.drawPath(path, infillPaint);
      // TODO Re-add highlight & note corners
      /* paintHighlightedCorners( */
      /*   corners: corners, */
      /*   canvas: canvas, */
      /*   canvasSize: size, */
      /*   progress: progress, */
      /*   cornerSize: cornerSize, */
      /* ); */
      canvas.drawPath(path, borderPaint);
      /* paintNoteCorners( */
      /*   corners: corners, */
      /*   canvas: canvas, */
      /*   progress: progress, */
      /*   cornerSize: cornerSize, */
      /* ); */
    }

    animatePathDualBorderEmptyToComplete(
      canvas: canvas,
      path: path,
      progress: highlightProgress,
      paint: borderActivePaint,
    );
  }

  void animatePathDualBorderEmptyToComplete({
    required Canvas canvas,
    required Path path,
    required double progress,
    required Paint paint,
  }) {
    if (progress > double.minPositive) {
      final pathMetrics = path.computeMetrics();
      for (final pathMetric in pathMetrics) {
        final extractPath = pathMetric.extractPath(
          0.0,
          (pathMetric.length / 2) * progress,
        );
        final extractPath2 = pathMetric.extractPath(
          (pathMetric.length / 2),
          (pathMetric.length / 2) * progress + (pathMetric.length / 2),
        );
        canvas.drawPath(extractPath, paint);
        canvas.drawPath(extractPath2, paint);
      }
    }
  }

  /* void paintHighlightedCorners({ */
  /*   required GurenButtonCorners corners, */
  /*   required Canvas canvas, */
  /*   required Size canvasSize, */
  /*   required double progress, */
  /*   required double cornerSize, */
  /* }) { */
  /*   if (corners.topLeft?.highlighted ?? false) { */
  /*     final highlightPaint = Paint() */
  /*       ..color = GurenColors.yellow */
  /*       ..strokeWidth = borderThickness */
  /*       ..style = PaintingStyle.fill */
  /*       ..strokeCap = StrokeCap.square; */
  /*     final highlightCornerSize = cornerSize * 0.5; */
  /*     const inset = 0.0; */
  /*     final path = Path(); */
  /*     path.moveTo(inset, cornerSize - inset); */
  /*     path.lineTo(cornerSize - inset, inset); */
  /*     path.lineTo(highlightCornerSize, inset); */
  /*     path.lineTo(inset, highlightCornerSize); */
  /*     path.close(); */
  /*     canvas.drawPath(path, highlightPaint); */
  /*   } */
  /* } */

  /* void paintNoteCorners({ */
  /*   required GurenButtonCorners corners, */
  /*   required Canvas canvas, */
  /*   required double progress, */
  /*   required double cornerSize, */
  /* }) { */
  /*   if (corners.topLeft?.hint != null) { */
  /*     final hintBackdrop = Paint() */
  /*       ..color = GurenColors.yellow */
  /*       ..style = PaintingStyle.fill */
  /*       ..strokeCap = StrokeCap.square; */
  /*     const inset = borderThickness / 2; */
  /*     final path = Path(); */
  /*     path.moveTo(inset, cornerSize - inset); */
  /*     path.lineTo(cornerSize - inset, inset); */
  /*     path.lineTo(inset, inset); */
  /*     path.close(); */
  /*     final rect = Rect.fromCenter( */
  /*         center: Offset((cornerSize - inset) / 2, (cornerSize - inset) / 2), */
  /*         width: (cornerSize - inset) * 0.4, */
  /*         height: (cornerSize - inset) * 0.4); */
  /*  */
  /*     canvas.drawPath(path, hintBackdrop); */
  /*     /* canvas.drawRect(rect, hintBackdrop); */ */
  /*   } */
  /* } */

  // TODO Path can be cached as long as dimensions dont change
  Path borderPath({required double cornerSize, required Size size}) {
    final path = Path();

    const borderOffset = borderThickness / 2;
    const minHeightForBorder = 0 + borderOffset;
    const minWidthForBorder = 0 + borderOffset;
    final maxHeightForBorder = size.height - borderOffset;
    final maxWidthForBorder = size.width - borderOffset;

    if (corners.topLeft == null || !corners.topLeft!.isCornerCut()) {
    } else {
      path.moveTo(minWidthForBorder, cornerSize);
      path.lineTo(cornerSize, minHeightForBorder);
    }

    if (corners.topRight == null || !corners.topRight!.isCornerCut()) {
      path.lineTo(maxWidthForBorder, minHeightForBorder);
    } else {
      path.lineTo(maxWidthForBorder - cornerSize, minHeightForBorder);
      path.lineTo(maxWidthForBorder, cornerSize);
    }

    if (corners.bottomRight == null || !corners.bottomRight!.isCornerCut()) {
      path.lineTo(maxWidthForBorder, maxHeightForBorder);
    } else {
      path.lineTo(maxWidthForBorder, size.height - cornerSize);
      path.lineTo(size.width - cornerSize, maxHeightForBorder);
    }

    if (corners.bottomLeft == null || !corners.bottomLeft!.isCornerCut()) {
      path.lineTo(minWidthForBorder, maxHeightForBorder);
    } else {
      path.lineTo(cornerSize, maxHeightForBorder);
      path.lineTo(minWidthForBorder, size.height - cornerSize);
    }

    path.close();

    return path;
  }

  @override
  bool shouldRepaint(GurenButtonPainter oldDelegate) {
    return (oldDelegate.progress + 0.0001 < progress ||
            oldDelegate.progress - 0.0001 > progress) ||
        (oldDelegate.highlightProgress + 0.0001 < highlightProgress ||
            oldDelegate.highlightProgress - 0.0001 > highlightProgress) ||
        oldDelegate.maxCornerSize != maxCornerSize ||
        oldDelegate.corners != corners;
  }
}
