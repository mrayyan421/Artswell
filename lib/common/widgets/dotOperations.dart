import 'package:artswellfyp/features/authentication/controllers/initialScreenControllers.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../utils/constants/colorConstants.dart';
import '../../utils/constants/size.dart';
import '../../utils/device/deviceComponents.dart';

class dotNavigation extends StatelessWidget {
  const dotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller=AppLandingController.instance;
    return Positioned(
      left: kSizes.largeIcon,
      bottom: kDeviceComponents.getBottomNavBarHeight(context),
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotsClickNavigation,
        count: 3,
        effect: const ExpandingDotsEffect(
            activeDotColor: kColorConstants.klPrimaryColor,
            dotHeight: kSizes.smallPadding),
      ),
    );
  }
}
