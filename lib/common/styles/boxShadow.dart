import 'package:flutter/material.dart';

class kBoxShadow{
  static const verticalBoxShadow=BoxShadow(
    color: Color.fromRGBO(50, 50, 50, 0.65),offset: Offset(0, 2),blurRadius: 20,spreadRadius: 3.0
  );
  static const horizontalBoxShadow=BoxShadow(
      color: Color.fromRGBO(50, 50, 50, 0.65),offset: Offset(0, 2),blurRadius: 50,spreadRadius: 7.0
  );
}