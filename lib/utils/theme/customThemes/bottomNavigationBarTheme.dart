import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';

class kBottomNavigationBarTheme {
  kBottomNavigationBarTheme._();

  static const BottomNavigationBarThemeData lightBottomNavBarThemeData = BottomNavigationBarThemeData(
    backgroundColor: kColorConstants.klPrimaryColor,
    elevation: 15.0,
    selectedIconTheme: IconThemeData(
      size: 22.0,
      color: kColorConstants.klOrangeColor,
    ),
    unselectedIconTheme: IconThemeData(
      size: 8.0,
      color: Colors.white,
    ),
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white,
    selectedLabelStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
  );


//Dark mode
  static BottomNavigationBarThemeData darkBottomNavBarThemeData = const BottomNavigationBarThemeData(
    backgroundColor: Colors.black, // Dark background for better contrast
    elevation: 15.0,
    selectedIconTheme: IconThemeData(
      size: 24.0,
      color: kColorConstants.klPrimaryColor, // Maroon for selected icons in dark mode
    ),
    unselectedIconTheme: IconThemeData(
      size: 20.0,
      color: Colors.grey, // Gray for unselected icons in dark mode
    ),
    selectedItemColor: kColorConstants.klPrimaryColor, // Maroon for selected items
    unselectedItemColor: Colors.grey, // Gray for unselected items
    selectedLabelStyle: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      color: kColorConstants.klPrimaryColor, // Maroon for selected labels
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: Colors.grey, // Gray for unselected labels
    ),
  );
}
