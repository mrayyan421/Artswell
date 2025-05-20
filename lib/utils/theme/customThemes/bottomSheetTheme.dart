import 'package:artswellfyp/utils/constants/size.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';

class kBottomSheetTheme {
  kBottomSheetTheme._();

  static BottomSheetThemeData lightBottomSheetThemeData = BottomSheetThemeData(
    backgroundColor: kColorConstants.klBottomSheetBgColor,
    surfaceTintColor: Colors.white,
    elevation: 30.0,
    modalBackgroundColor: kColorConstants.klSecondaryColor,
    modalBarrierColor: kColorConstants.klErrorColor.withOpacity(0.5),
    shadowColor: kColorConstants.klShadowColor,
    modalElevation: 12.0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(kSizes.largeBorderRadius)),
    ),
    showDragHandle: true,
    dragHandleColor: kColorConstants.klDateTextBottomNavBarSelectedIconColor,
    dragHandleSize: const Size(36, 4),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    constraints: BoxConstraints(
      maxHeight: 0.7 * MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size.height,
    ),
  );

  static BottomSheetThemeData darkBottomSheetThemeData = BottomSheetThemeData(
    backgroundColor: kColorConstants.klSecondaryColor,
    surfaceTintColor: kColorConstants.klPrimaryColor,
    elevation: 8.0,
    modalBackgroundColor: Colors.black,
    modalBarrierColor: Colors.black.withOpacity(0.5),
    shadowColor: Colors.black87,
    modalElevation: 12.0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    showDragHandle: true,
    dragHandleColor: kColorConstants.klGreyColor,
    dragHandleSize: const Size(36, 4),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    constraints: BoxConstraints(
      maxHeight: 0.7 * MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size.height,
    ),
  );
}
