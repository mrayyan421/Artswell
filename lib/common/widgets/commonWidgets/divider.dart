import 'package:flutter/material.dart';

import '../../../utils/constants/colorConstants.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.clr=kColorConstants.klDividerColor,
    required this.thickness,
    required this.indent,
    required this.endIndent,
  });
  final Color clr;
  final double thickness;
  final double indent;
  final double endIndent;
  @override
  Widget build(BuildContext context) {
    return Divider(color: clr,thickness: thickness,indent: indent,endIndent: endIndent,);
  }
}