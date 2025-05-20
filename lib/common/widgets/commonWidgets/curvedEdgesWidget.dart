import 'package:flutter/material.dart';

import 'curvedEdges.dart';

class kCurvedEdgesWidget extends StatelessWidget {
  const kCurvedEdgesWidget({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: kCustomCurvedEdges(), child: child,
    ); // ClipPath
  }
}
