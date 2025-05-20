import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';

class kInputDecorationTheme {
  kInputDecorationTheme._();

  static InputDecorationTheme lightInputDecoration = InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kColorConstants.klPrimaryColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kColorConstants.klGreyColor, width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kColorConstants.klErrorColor, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color:kColorConstants.klErrorColor, width: 2.0),
    ),
    fillColor: kColorConstants.klGreyColor,
    filled: true,
  );

  static InputDecorationTheme darkInputDecoration = InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kColorConstants.klFocusedBorderColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kColorConstants.klNonFocusedBorderColor, width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kColorConstants.klErrorColor, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kColorConstants.klPrimaryColor, width: 2.0),
    ),
    fillColor: kColorConstants.klPrimaryColor,
    filled: true,
  );
}
