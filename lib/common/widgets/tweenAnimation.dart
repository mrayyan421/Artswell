/*import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/custom_transition.dart';

class TweenanimationRoute extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve animationCurve,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final rectAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(animation);

    return Stack(
      children: [
        PositionedTransition(
          rect: rectAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ],
    );
  }
}*/
