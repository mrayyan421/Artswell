import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';

class kNavigationMenuTheme {
  kNavigationMenuTheme._();

  static const NavigationRailThemeData lightNavigationMenuTheme = NavigationRailThemeData(
    backgroundColor: kColorConstants.klPrimaryColor,
    selectedIconTheme: IconThemeData(
      color: Colors.white,
      size: 30,
    ),
    unselectedIconTheme: IconThemeData(
      color: kColorConstants.klAntiqueWhiteColor,
      size: 24,
    ),
    selectedLabelTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 17,
    ),
    unselectedLabelTextStyle: TextStyle(
      color: kColorConstants.klAntiqueWhiteColor,
      fontWeight: FontWeight.normal,
      fontSize: 13,
    ),
  );

  // Dark theme for the navigation menu
/*  static final NavigationRailThemeData darkNavigationMenuTheme = NavigationRailThemeData(
    backgroundColor: Colors.black,
    selectedIconTheme: IconThemeData(
      color: Colors.amber,
      size: 30,
    ),
    unselectedIconTheme: IconThemeData(
      color: Colors.white70,
      size: 24,
    ),
    selectedLabelTextStyle: TextStyle(
      color: Colors.amber,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    unselectedLabelTextStyle: TextStyle(
      color: Colors.white70,
      fontSize: 14,
    ),
  );*/
}
