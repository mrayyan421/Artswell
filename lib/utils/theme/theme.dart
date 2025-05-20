import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'customThemes/textTheme.dart';
import 'customThemes/appBarTheme.dart';
import 'customThemes/iconButtonTheme.dart';
import 'customThemes/inputDecorationTheme.dart';
import 'customThemes/elevationButtonTheme.dart';
import 'customThemes/dateTimePickerTheme.dart';
import 'customThemes/dataTableTheme.dart';
import 'customThemes/sliderTheme.dart';
import 'customThemes/bottomNavigationBarTheme.dart';
import 'customThemes/bottomSheetTheme.dart';
import 'customThemes/navigationMenuTheme.dart';

class kAppTheme{
  kAppTheme._();

  static ThemeData lightTheme=ThemeData(
    checkboxTheme: const CheckboxThemeData(
      fillColor: WidgetStatePropertyAll<Color>(Colors.white),
      checkColor: WidgetStatePropertyAll<Color>(Colors.black),
      overlayColor: WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: kColorConstants.klPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    textTheme: kTextTheme.lightTextTheme,
    appBarTheme: kAppBarTheme.lightAppBarTheme,
    bottomNavigationBarTheme: kBottomNavigationBarTheme.lightBottomNavBarThemeData,
    bottomSheetTheme: kBottomSheetTheme.lightBottomSheetThemeData,
    iconButtonTheme: kIconButtonTheme.lightIconButton,
    elevatedButtonTheme: kElevatedbuttonTheme.lightElevatedButtonTheme,
    colorScheme: const ColorScheme(brightness: Brightness.light, primary: kColorConstants.klPrimaryColor, onPrimary: Colors.white, secondary: kColorConstants.klSecondaryColor, onSecondary: Colors.black, error: kColorConstants.klErrorColor, onError: Colors.white, surface: kColorConstants.klOrangeColor, onSurface: Colors.black,),
    datePickerTheme: kDateTimePickerTheme.lightDateTimePickerTheme,
    applyElevationOverlayColor: true,
    inputDecorationTheme: kInputDecorationTheme.lightInputDecoration,
    dataTableTheme: kDataTableTheme.lightDataTableThemeData,
    sliderTheme: klSliderTheme.lightSliderTheme,
    navigationRailTheme: kNavigationMenuTheme.lightNavigationMenuTheme, dialogTheme: const DialogThemeData(backgroundColor: kColorConstants.klDialogueBoxColor),
    // navigationBarTheme: kBottomNavigationBarThemeD
  );
  static ThemeData darkTheme=ThemeData(
    inputDecorationTheme: kInputDecorationTheme.darkInputDecoration,
    datePickerTheme: kDateTimePickerTheme.darkDateTimePickerTheme,
    sliderTheme: klSliderTheme.darkSliderTheme,

  );
}