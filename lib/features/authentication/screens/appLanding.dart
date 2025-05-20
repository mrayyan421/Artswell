import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/common/widgets/landingScreenSlider.dart';
import 'package:artswellfyp/common/widgets/dotOperations.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/features/authentication/controllers/initialScreenControllers.dart';

class Applanding extends StatelessWidget {
  const Applanding({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =Get.put(AppLandingController());
  return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const <Widget>[
              landingWidget1(
                img: 'assets/images/onboarding1.gif',
                title: 'Choose the best product',
                subtitle: 'Have the best ECommerce Experience by diving into the Artisan Industry',
              ),
              landingWidget1(
                img: 'assets/images/onboarding2.gif',
                title: 'Add to cart',
                subtitle: 'Fill the cart with unique local Art products',
              ),
              landingWidget1(
                img: 'assets/images/onboarding3.gif',
                title: 'On-time delivery',
                subtitle: 'Get a hold of your purchased items in no time',
              ),
            ],
          ),
          Positioned(
            top: 40.0,
            right: kSizes.mediumPadding,
            child: TextButton(
              onPressed: () {
                controller.skipPage();//change here as well after page1 creation
              },
              child: Text(
                'Skip',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const dotNavigation(), // dotOperation class to handle page index
          Positioned(
            bottom: 50.0,
            right: kSizes.mediumPadding,
            child: SizedBox(
              height: 70,
              width: 70.0,
              child: FloatingActionButton(
                onPressed: () {
                  AppLandingController.instance.nextPage();
                },
                child: Image.asset(
                  'assets/icons/rightArrow.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
