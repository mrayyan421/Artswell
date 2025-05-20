import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class kLoaders {
//a customized toast msg
  static customToast({required message}) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        elevation: 0,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color.fromRGBO(128, 128, 128, 0.9)
          ),
          child: Center(
            child: Text(
              message,
              style: Theme.of(Get.context!).textTheme.labelMedium,
            ),
          ),
        ),
      ),
    );
  }

  // Displays a success snackbar with a title and optional msg.
  static void successSnackBar({required String title, String message = '', int duration = 3}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: kColorConstants.klVisitStoreElevationBtnClr,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check, color: kColorConstants.klAntiqueWhiteColor),
    );
  }

  // Displays a warning snackbar with a title and optional message.
  static void warningSnackBar({required String title, String message = ''}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: kColorConstants.klAntiqueWhiteColor,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.warning, color: kColorConstants.klAntiqueWhiteColor),
    );
  }
  static void errorSnackBar({required String title, String message = ''}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: kColorConstants.klAntiqueWhiteColor,
      backgroundColor: kColorConstants.klSearchBarColor,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.warning, color: kColorConstants.klAntiqueWhiteColor),
    );
  }
}