import 'package:flutter/material.dart';

class kTextTheme{
  kTextTheme._();

  static TextTheme lightTextTheme=TextTheme(
    headlineLarge: const TextStyle().copyWith(fontSize: 38.0,fontWeight: FontWeight.w800,color:Colors.black,fontFamily: 'assets/fonts/Poppins/Poppins-Regular'),
    // kColorConstants.klPrimaryColor),
    headlineMedium: const TextStyle().copyWith(fontSize: 25.0,fontWeight: FontWeight.w600,color:Colors.black,fontFamily: 'assets/fonts/Poppins/Poppins-Medium'),
    // klPrimaryColor),
    headlineSmall: const TextStyle().copyWith(fontSize: 20.0,fontWeight: FontWeight.w400,color:Colors.black),
    // klPrimaryColor),
    bodyLarge: const TextStyle().copyWith(fontSize: 25.0,fontWeight: FontWeight.w500,color: Colors.black,fontFamily: 'assets/fonts/Poppins-Black'),
    bodyMedium: const TextStyle().copyWith(fontSize: 20.0,fontWeight: FontWeight.w400,color: Colors.black,fontFamily: 'assets/fonts/Poppins-Medium'),
    bodySmall: const TextStyle().copyWith(fontSize: 15.0,fontWeight: FontWeight.w400,color: Colors.black,fontFamily: 'assets/fonts/Poppins-Regular'),
    displayMedium: const TextStyle().copyWith(fontSize: 20.0,fontWeight: FontWeight.w300,color: Colors.white,fontFamily: 'assets/fonts/Poppins-Medium'),
    displayLarge: const TextStyle().copyWith(fontSize: 33.0,fontWeight: FontWeight.w800,color: Colors.black,fontFamily: 'assets/fonts/Poppins-Medium'),
    displaySmall: const TextStyle().copyWith(fontSize: 15.0,fontWeight: FontWeight.w300,color: Colors.white,fontFamily: 'assets/fonts/Poppins-Regular'),
  );
  static TextTheme darkTextTheme=const TextTheme();
}