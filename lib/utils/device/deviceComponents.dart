import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:url_launcher/url_launcher_string.dart';

class kDeviceComponents{
  kDeviceComponents._();

  static bool isPortrait(BuildContext context){
    return MediaQuery.of(context).orientation== Orientation.portrait;
  }
  static bool isLandscape(BuildContext context){
    return MediaQuery.of(context).orientation== Orientation.landscape;
  }
  static void keyboardDisappears(BuildContext context){
    FocusScope.of(context).unfocus();
  }
  static void keyboardAppears(BuildContext context){
    FocusScope.of(context).requestFocus(FocusNode(),);
  }
  static double screenHeight(BuildContext context){
    return MediaQuery.sizeOf(context).height;
  }
  static double screenWidth(BuildContext context){
    return MediaQuery.sizeOf(context).width;
  }
  static double containerWidth(BuildContext context){
    return MediaQuery.of(context).size.width;
  }
  static double containerHeight(BuildContext context){
    return MediaQuery.of(context).size.height;
  }
  static Future<void> statusBarColor(Color color)async{
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color)
    );
  }
  static double statusBarHeight(BuildContext context){
    return MediaQuery.of(context).padding.top;
  }
  static Color getBottomNavBarColor(){
    return kColorConstants.klPrimaryColor;
  }
  static double getBottomNavBarHeight(BuildContext context){
    return MediaQuery.of(context).size.height * 0.1;
  }
  static Future<bool> internetAvailability()async{
    try{
      final response=await InternetAddress.lookup('host');
      return response.isNotEmpty && response[0].rawAddress.isNotEmpty;
    }on SocketException catch(_){
      return false;
    }
  }
  static void loadUrl(String urlString)async{
    if(await canLaunchUrlString(urlString)){
      await launchUrlString(urlString);
    }else{
      throw('$urlString couldn\'t be loaded');
    }
  /*static void cursorShape(MouseCursor cursor){

  }*/
}}