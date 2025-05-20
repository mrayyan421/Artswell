import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'mouseCursorTheme.dart';

class kIconButtonTheme{
  kIconButtonTheme._();

  static IconButtonThemeData lightIconButton=IconButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll<Color>(kColorConstants.klOrangeColor,),
      foregroundColor: const WidgetStatePropertyAll<Color>(kColorConstants.klDateTextBottomNavBarSelectedIconColor,),
      iconColor: const WidgetStatePropertyAll<Color>(Color(0xffE8CEB0),),
      iconSize: const WidgetStatePropertyAll<double>(20.0),
      maximumSize: const WidgetStatePropertyAll<Size>(Size(50.0,50.0),),
      minimumSize: const WidgetStatePropertyAll<Size>(Size(40.0,40.0),),
      mouseCursor: WidgetStatePropertyAll<MouseCursor>(kMouseCursorTheme.lightMouseCursor(),),
      shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0),),),
      elevation: const WidgetStatePropertyAll<double>(5.0),
    )
  );
  static IconButtonThemeData darkIconButton=const IconButtonThemeData();
}