
import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';

class kHelperFunctions{
  kHelperFunctions._();

  static Color getColor(String colorValue){//function to chose from colors
    if(colorValue==kColorConstants.klPrimaryColor){
      return kColorConstants.klPrimaryColor;
    }else if(colorValue==kColorConstants.klSecondaryColor){
      return kColorConstants.klSecondaryColor;
    }
    else{
      return kColorConstants.klHelpTextColor;
    }
  }
  static Size screenSize(BuildContext context) {//function for responsive screen layout
    return MediaQuery.of(context).size;
  }
  static double screenWidth(BuildContext context, {double ratio = 1.0}) { //responsive width
    return screenSize(context).width * ratio;
  }
  static double screenHeight(BuildContext context, {double ratio = 1.0}) { //responsive height
    return screenSize(context).height * ratio;
  }
  }