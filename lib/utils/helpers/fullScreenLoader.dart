import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/loaders/animationLoaderWidget.dart';

// A utility class for displaying a full-screen loading dialog.
class FFullScreenLoader {
  // Open a full-screen loading dialog with a given text and animation.
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false, // The dialog can't be dismissed by tapping outside it
      builder: (context) => PopScope(
        canPop: false, // Disable popping with the back button
        child: Container(
          color: kColorConstants.klDialogueBoxColor,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 200),
              AnimationLoaderWidget(text: text, animation: animation),
            ],
          ),
        ),
      ),
    );
  }
  static void hideLoading() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }
}