import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class Warningpopup extends StatelessWidget {
  const Warningpopup({super.key, required this.confirmTxt, required this.onPressed, required this.warningText});

  final String warningText, confirmTxt;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(kSizes.mediumPadding),
      elevation: 10.0,
      insetAnimationCurve: Curves.bounceInOut,
      child: Container(
        height: 230,
        padding: const EdgeInsets.all(kSizes.mediumPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/warning.png'),
            const SizedBox(height: kSizes.smallPadding),
            Text(warningText, style: kAppTheme.lightTheme.textTheme.displaySmall),
            const SizedBox(height: kSizes.smallPadding),
            ElevatedButton(onPressed: onPressed, child: Text(confirmTxt)),
          ],
        ),
      ),
    );
  }
}
