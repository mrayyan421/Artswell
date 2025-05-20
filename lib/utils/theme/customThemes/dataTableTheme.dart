import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';

class kDataTableTheme{
  kDataTableTheme._();

  static DataTableThemeData lightDataTableThemeData=DataTableThemeData(
    checkboxHorizontalMargin: 3.0,
    columnSpacing: 2.0,
    decoration: BoxDecoration(color: kColorConstants.klTableColor, borderRadius: BorderRadius.circular(5.0),boxShadow: const <BoxShadow>[BoxShadow(color: kColorConstants.klShadowColor,offset: Offset(5.0, 5.0),blurRadius: 8.0,spreadRadius: 2.5),BoxShadow(color: kColorConstants.klGreyColor,offset: Offset(0.0,0.0),blurRadius: 0.0,spreadRadius: 0.0),])
  );
}