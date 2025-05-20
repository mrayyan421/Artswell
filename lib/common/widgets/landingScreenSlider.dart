import 'package:flutter/material.dart';
import '../../utils/constants/size.dart';
import '../../utils/helpers/helperFuncs.dart';

class landingWidget1 extends StatelessWidget {
  const landingWidget1({
    super.key,required this.img,required this.title,required this.subtitle
  });

  final String img,title,subtitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kSizes.mediumPadding),
      child: Column(
        children: <Widget>[
          Image.asset(
            img,
            // 'assets/images/onboarding1.gif',
            width: kHelperFunctions.screenWidth(context) * 0.8,
            height: kHelperFunctions.screenHeight(context) * 0.6,
          ),
          Text(
            // 'Choose the best product',
              title,
              style: Theme.of(context).textTheme.headlineMedium,textAlign: TextAlign.center),
          const SizedBox(height: kSizes.largePadding),
          Text(
              subtitle,
              // 'Have the best ECommerce Experience by diving into the Artisan Industry',
              style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.center),
        ],
      ),
    );
  }
}