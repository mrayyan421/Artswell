import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:flutter/material.dart';
import 'textTheme.dart';
import 'mouseCursorTheme.dart';

class kElevatedbuttonTheme{
  kElevatedbuttonTheme._();
  
  static final ElevatedButtonThemeData lightElevatedButtonTheme= ElevatedButtonThemeData(style:ButtonStyle(
    backgroundColor: const WidgetStatePropertyAll<Color>(kColorConstants.klSecondaryColor),
    foregroundColor: const WidgetStatePropertyAll<Color>(Colors.black),
    elevation: const WidgetStatePropertyAll<double>(20.0),
    textStyle: WidgetStatePropertyAll<TextStyle?>(kTextTheme.lightTextTheme.bodyMedium),
    shadowColor:const WidgetStatePropertyAll<Color>(kColorConstants.kdSelectedDayColor1),
    shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0),),),
    mouseCursor:WidgetStatePropertyAll<MouseCursor>(kMouseCursorTheme.lightMouseCursor(),),
    minimumSize: const WidgetStatePropertyAll(Size(kSizes.elevatedButtonWidth,kSizes.elevatedButtonHeight),)
  ),);
}