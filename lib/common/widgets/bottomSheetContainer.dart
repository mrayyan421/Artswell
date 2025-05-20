import 'package:flutter/material.dart';

class BottomSheetContainer extends StatelessWidget {
  const BottomSheetContainer({
    super.key,
    required this.height,
    required this.child,
  });
  final double height;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color.fromRGBO(211, 211, 211, 0.5),spreadRadius: 5,blurRadius: 7,offset: Offset(0, 3)),]),
      height: height,
      // kDeviceComponents.containerHeight(context),
      child: child
    );
  }}