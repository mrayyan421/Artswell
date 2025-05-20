import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/size.dart';

// A widget for displaying an animated loading indicator with optional text and action button.
class AnimationLoaderWidget extends StatelessWidget {
  // Default constructor for the AnimationLoaderWidget.
  // Parameters:
  // - text: The text to be displayed below the animation.
  // - animation: The path to the Lottie animation file.
  // - showAction: Whether to show an action button below the text.
  // - actionText: The text to be displayed on the action button.
  // - onActionPressed: Callback function to be executed when the action button is pressed.
  const AnimationLoaderWidget({
    super.key,
    required this.text,
    required this.animation,
    this.showAction = false,
    this.actionText,
    this.onActionPressed,
  });

  final String text;
  final String animation;
  final bool showAction;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(animation, width: MediaQuery.of(context).size.width), // Display Lottie animation
          const SizedBox(height: kSizes.mediumPadding),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ), // Text
          const SizedBox(height: kSizes.mediumPadding),
          showAction
              ? SizedBox(
            width: 256,
            child: OutlinedButton(
              onPressed: onActionPressed,
              style: OutlinedButton.styleFrom(backgroundColor: kColorConstants.klOrangeColor),
              child: Text(
                actionText ?? '',
                style: Theme.of(context).textTheme.bodyMedium!.apply(color: kColorConstants.klAntiqueWhiteColor),
              ), // Text
            ), // OutlinedButton
          ) // SizedBox
              : const SizedBox(),
        ],
      ), // Column
    );
  }
}