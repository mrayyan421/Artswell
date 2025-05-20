import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';


class kAppBarTheme{
  kAppBarTheme._();

  static AppBarTheme lightAppBarTheme = const AppBarTheme(
    // titleSpacing: 20,
    foregroundColor: Colors.white,
    backgroundColor: kColorConstants.klPrimaryColor,
    titleTextStyle: TextStyle(color: kColorConstants.klDateTextBottomNavBarSelectedIconColor,fontSize: 32.0,fontFamily: 'Poppins'),
    centerTitle: true,
    elevation: 10.0,
    iconTheme: IconThemeData(color: Colors.white,opticalSize: 32.0,size: 35,shadows: [Shadow(offset: Offset(2.0,2.0),blurRadius: 2.0,color: Color.fromARGB(255, 0, 0, 0))]),

  );
  static AppBarTheme lightAppBarThemeRedBg = const AppBarTheme(
    backgroundColor: kColorConstants.klPrimaryColor
  );
  static AppBarTheme darkAppBarTheme = const AppBarTheme();
}