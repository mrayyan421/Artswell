import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:flutter/material.dart';

class kCircularContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double? width;
  final double? height;
  bool showBorder=true;
  EdgeInsets? margin;
  EdgeInsets? padding;

  kCircularContainer({
    super.key,
    required this.child,
    required this.backgroundColor, required this.width, required this.showBorder,this.margin,this.padding,required this.height
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: showBorder? BorderRadius.circular(kSizes.largeBorderRadius):null,
        border: Border.all(color: kColorConstants.klNonFocusedBorderColor)
      ),
      padding: padding,
      child: child,
    );
  }
}