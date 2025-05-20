import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/size.dart';

class kSpacingStyle{
  static const EdgeInsetsGeometry paddingWithAppBarHeight=EdgeInsets.fromLTRB(kSizes.largePadding, kSizes.AppBarSize, kSizes.largePadding, kSizes.largePadding);
  static const EdgeInsetsGeometry paddingWithAppBarHeightRegistrationScreen=EdgeInsets.fromLTRB(kSizes.largePadding, kSizes.smallPadding, kSizes.largePadding, kSizes.largePadding);
  static ButtonStyle? registrationScreenElevatedButton=kAppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(minimumSize: const WidgetStatePropertyAll(Size(120,48),),foregroundColor: const WidgetStatePropertyAll(kColorConstants.klSecondaryColor),);
}
