import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';

class klSliderTheme {
  klSliderTheme._();

  static SliderThemeData lightSliderTheme = const SliderThemeData(
    trackHeight: 4.0,
    activeTrackColor: kColorConstants.klPrimaryColor,
    inactiveTrackColor: kColorConstants.klInactiveTrackColor,
    thumbColor: kColorConstants.klOrangeColor,
    overlayColor: kColorConstants.klSliderOverlayColor,
    valueIndicatorColor: kColorConstants.klSecondaryColor,
    activeTickMarkColor: kColorConstants.klActiveTickMarkColor,
    inactiveTickMarkColor: kColorConstants.klInActiveTickMarkColor,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
    trackShape: RectangularSliderTrackShape(), // Track Shape
    overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0), // Overlay shape
    valueIndicatorTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  );

  static SliderThemeData darkSliderTheme = const SliderThemeData(
    trackHeight: 4.0,
    activeTrackColor: kColorConstants.klOrangeColor,
    inactiveTrackColor: Color(0xff1A1A1A), // Dark background for inactive track
    thumbColor: Color(0xffFFC100), // Yellow for the thumb
    overlayColor: Color(0x29FFC100), // Yellow transparent overlay
    valueIndicatorColor: Color(0xffC40C0C), // Maroon for the value indicator
    activeTickMarkColor: Color(0xffFFC100), // Yellow tick marks for the active track
    inactiveTickMarkColor: Color(0xffE8CEB0), // Beige tick marks on inactive track
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
    trackShape: RectangularSliderTrackShape(),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
    valueIndicatorTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  );
}
