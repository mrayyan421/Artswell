import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';

class kDateTimePickerTheme {
  kDateTimePickerTheme._();

  static DatePickerThemeData lightDateTimePickerTheme = DatePickerThemeData(
    backgroundColor: kColorConstants.klPrimaryColor,
    elevation: 5.0,
    shadowColor: kColorConstants.klGreyColor,
    surfaceTintColor: kColorConstants.klShapeColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    headerBackgroundColor: kColorConstants.klDateBgColor,
    headerForegroundColor: Colors.white,
    headerHeadlineStyle: const TextStyle(
      color: Colors.white,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
    headerHelpStyle: const TextStyle(
      color: kColorConstants.klHelpTextColor,
      fontSize: 14.0,
    ),
    yearStyle: const TextStyle(
      color: Colors.white,
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    ),
    weekdayStyle: const TextStyle(
      color: kColorConstants.klDateTextBottomNavBarSelectedIconColor,
      fontSize: 16.0,
    ),
    dayStyle: const TextStyle(
      color: kColorConstants.klDateTextBottomNavBarSelectedIconColor,
      fontSize: 16.0,
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return kColorConstants.klShapeColor;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return kColorConstants.klDateBgColor;
      }
      return Colors.transparent;
    }),
    dayOverlayColor: const WidgetStatePropertyAll(kColorConstants.klDayOverlayColor),
    dayShape: const WidgetStatePropertyAll(CircleBorder()),
    todayForegroundColor: const WidgetStatePropertyAll(kColorConstants.klSelectedDayColor1),
    todayBackgroundColor: const WidgetStatePropertyAll(kColorConstants.klSelectedDayColor2),
    todayBorder: const BorderSide(color: kColorConstants.klSelectedDayColor1, width: 2),
    yearForegroundColor: const WidgetStatePropertyAll(Colors.white),
    yearBackgroundColor: const WidgetStatePropertyAll(kColorConstants.klSelectedDayColor2),
    yearOverlayColor: const WidgetStatePropertyAll(kColorConstants.klDayOverlayColor),
    rangePickerBackgroundColor: kColorConstants.klSelectedRangeColor,
    rangePickerElevation: 3.0,
    rangePickerShadowColor: kColorConstants.klGreyColor,
    rangePickerSurfaceTintColor: kColorConstants.klSelectedDayColor2,
    rangePickerShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    rangePickerHeaderBackgroundColor: kColorConstants.klSelectedDayColor2,
    rangePickerHeaderForegroundColor: Colors.white,
    rangePickerHeaderHeadlineStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18.0,
    ),
    rangePickerHeaderHelpStyle: const TextStyle(
      color: kColorConstants.klAntiqueWhiteColor,
      fontSize: 14.0,
    ),
    // rangeSelectionBackgroundColor: WidgetStatePropertyAll<Color>(Colors.brown.shade400),
    rangeSelectionOverlayColor: const WidgetStatePropertyAll<Color>(kColorConstants.klSelectedRangeColor),
    dividerColor: kColorConstants.klAntiqueWhiteColor,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kColorConstants.klAntiqueWhiteColor),
      ),
    ),
    cancelButtonStyle: const ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(kColorConstants.klShapeColor),
    ),
    confirmButtonStyle: const ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(kColorConstants.klSelectedDayColor1),
    ),
  );

  static DatePickerThemeData darkDateTimePickerTheme = DatePickerThemeData(
    backgroundColor: kColorConstants.kdPrimaryColor,
    elevation: 5.0,
    shadowColor: Colors.black,
    surfaceTintColor: kColorConstants.klGreyColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    headerBackgroundColor: kColorConstants.kdShadowColor,
    headerForegroundColor: kColorConstants.klAntiqueWhiteColor,
    headerHeadlineStyle: const TextStyle(
      color: kColorConstants.klAntiqueWhiteColor,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
    headerHelpStyle: const TextStyle(
      color: kColorConstants.klDateTextBottomNavBarSelectedIconColor,
      fontSize: 14.0,
    ),
    yearStyle: const TextStyle(
      color: kColorConstants.klAntiqueWhiteColor,
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    ),
    weekdayStyle: const TextStyle(
      color: kColorConstants.klDayOverlayColor,
      fontSize: 16.0,
    ),
    dayStyle: const TextStyle(
      color: kColorConstants.kdGreyColor1,
      fontSize: 16.0,
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return kColorConstants.kdGreyColor1;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return kColorConstants.kdGreyColor2;
      }
      return Colors.transparent;
    }),
    dayOverlayColor: const WidgetStatePropertyAll(kColorConstants.kdGreyColor3),
    dayShape: const WidgetStatePropertyAll(CircleBorder(),),
    todayForegroundColor: const WidgetStatePropertyAll(kColorConstants.kdSelectedDayColor1),
    todayBackgroundColor: const WidgetStatePropertyAll(kColorConstants.kdSelectedDayColor2),
    todayBorder: const BorderSide(color: kColorConstants.kdSelectedDayColor1, width: 2),
    yearForegroundColor: const WidgetStatePropertyAll(kColorConstants.klAntiqueWhiteColor),
    yearBackgroundColor: const WidgetStatePropertyAll(kColorConstants.kdGreyColor2),
    yearOverlayColor: const WidgetStatePropertyAll(kColorConstants.kdGreyColor3),
    rangePickerBackgroundColor: kColorConstants.kdGreyColor1,
    rangePickerElevation: 3.0,
    rangePickerShadowColor: Colors.black,
    rangePickerSurfaceTintColor: kColorConstants.kdGreyColor1,
    rangePickerShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    rangePickerHeaderBackgroundColor: kColorConstants.kdGreyColor2,
    rangePickerHeaderForegroundColor: kColorConstants.klAntiqueWhiteColor,
    rangePickerHeaderHeadlineStyle: const TextStyle(
      color: kColorConstants.klAntiqueWhiteColor,
      fontWeight: FontWeight.bold,
      fontSize: 18.0,
    ),
    rangePickerHeaderHelpStyle: const TextStyle(
      color: kColorConstants.klAntiqueWhiteColor,
      fontSize: 14.0,
    ),
    // rangeSelectionBackgroundColor: WidgetStateProperty.all(Colors.grey.shade600),
    rangeSelectionOverlayColor: WidgetStatePropertyAll(Colors.grey.shade700),
    dividerColor: kColorConstants.kdGreyColor2,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kColorConstants.kdSelectedDayColor2),
      ),
    ),
    cancelButtonStyle: const ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(kColorConstants.kdGreyColor1),
    ),
    confirmButtonStyle: const ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(kColorConstants.kdGreyColor2),
    ),
  );
}
