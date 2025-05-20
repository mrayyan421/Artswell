import 'dart:io';
import 'package:artswellfyp/bottomNavBar.dart';
import 'package:artswellfyp/common/widgets/successScreen.dart';
import 'package:artswellfyp/data/repositories/categoryRepository/categoryRepository.dart';
import 'package:artswellfyp/features/authentication/screens/login/login.dart';
import 'package:artswellfyp/features/authentication/screens/registration/registration.dart';
import 'package:artswellfyp/features/personalization/screens/settings/settings.dart';
import 'package:artswellfyp/features/shop/screens/home/userProfile.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppLandingController extends GetxController {
  static AppLandingController get instance => Get.find();
  final pageController = PageController();
  var currentIndex = 0.obs;
  var image = Rx<File?>(null);

  void updatePageIndicator(int index) {//function to update index
    currentIndex.value = index;
  }
  void nextPage() {//function to redirect to proceeding page
    if (currentIndex.value == 2) {
      final storage=GetStorage();
      if(kDebugMode){
        print('debugModeGetX');
        print(storage.read('isFirstTime'));
      }
      storage.write('isFirstTime', false);
      if(kDebugMode){
        print('debugModeGetX');
        print(storage.read('isFirstTime'));
      }
      Get.offAll(const LoginPage());
    } else {
      int nextPage = currentIndex.value + 1;
      pageController.jumpToPage(nextPage);
    }
  }
  void skipPage() {//function to redirect to skip to LoginPage
    Get.offAll(const LoginPage());
  }
  void dotsClickNavigation(int index) {//function to handle dot click
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }
  void registrationPageNavigation() {//function to navigate to registration page
    Get.to(const RegistrationPage(),transition: Transition.downToUp,duration: const Duration(milliseconds: kSizes.initialAnimationTime));
  }
  void loginPageNavigation() {//function to navigate to registration page
    Get.to(const LoginPage(),transition: Transition.leftToRight,duration: const Duration(milliseconds: kSizes.initialAnimationTime));
    CategoryRepository.instance.convertAssetImagesToStorageUrls();

  }
  void successPageNavigation() {//function to navigate to success page on registration
    Get.to(const SuccessScreen(subTitle: 'Congratulations!!! Lets get things running then, Shall we???', btnText: 'Get Started ->',),transition: Transition.fadeIn,duration: const Duration(milliseconds: kSizes.initialAnimationTime));
  }
  void appMainScreenPageNavigation() {//function to navigate to app Home page
    Get.to(const NavigationMenu(),transition: Transition.leftToRightWithFade,duration: const Duration(milliseconds: kSizes.initialAnimationTime));
    CategoryRepository.instance.convertAssetImagesToStorageUrls();

  }
  void homePageNavigation() {//function to navigate to home page
    Get.offAll(const NavigationMenu(),transition: Transition.rightToLeft,duration: const Duration(milliseconds: kSizes.initialAnimationTime));
    CategoryRepository.instance.convertAssetImagesToStorageUrls();
  }
  void accountScreenNavigation() {//function to navigate to user profile page
    Get.to(const AccountScreen(),transition: Transition.rightToLeft,duration: const Duration(milliseconds: kSizes.initialAnimationTime));
  }
  void settingsScreenNavigation() {//function to navigate to user profile page
    Get.to(const SettingsScreen(),transition: Transition.rightToLeft,duration: const Duration(milliseconds: kSizes.initialAnimationTime));
  }
  void setFile(File? newFile) {
    image.value = newFile;
  }
}
