import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/utils/local_storage/localStorage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/authenticationRepository/authenticationRepository.dart';
import '../../../utils/helpers/fullScreenLoader.dart';
import '../../../utils/http/networkManager.dart';

class LoginController extends GetxController {
  // Observable variables for UI state to only build the specific component for which used
  RxBool rememberMe = false.obs;
  // RxBool hidePassword = true.obs;

  // Controllers for text input fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Form key for validation
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  //local storage GetX instance
  kLocalStorage localStorage=kLocalStorage();
  final userController=Get.put(UserController());

  @override
  void onInit() async {
    super.onInit();
    // Read the stored email asynchronously
    final email = await localStorage.readData('Remember me email');
    if (emailController is String) {
      emailController.text = emailController.text;
    }
  }
  //dunc to login with email/pwd and authenticate email
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      FFullScreenLoader.openLoadingDialog(
          'Matching information and logging you in...', 'assets/images/processing.gif');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.hideLoading();
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        FFullScreenLoader.hideLoading();
        return;
      }

      // Save Data if "Remember Me" is selected
     if (rememberMe.value) {
        localStorage.saveData('REMEMBER_ME_EMAIL', emailController.text.trim());
        localStorage.saveData('REMEMBER_ME_PASSWORD', passwordController.text.trim());
      }

      // Login User using Email & Password Authentication
      final userCredentials = await AuthenticationRepository.instance.loginWithEmailAndPassword(emailController.text.trim(), passwordController.text.trim());

      // Remove Loader
      FFullScreenLoader.hideLoading();

      // Redirect to appropriate screen
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Handle Errors and Stop Loader
      FFullScreenLoader.hideLoading();
    }
  }
  //func for google signin authentication
Future<void>googleSignIn()async{
    try{
      FFullScreenLoader.openLoadingDialog('Just a minute, Verifying to Log you in', 'assets/images/processing.gif');
      final isConnected=await NetworkManager.instance.isConnected();
      if(!isConnected){
        FFullScreenLoader.hideLoading();
        return;
      }
      final userCredentials=await AuthenticationRepository.instance.loginWithGoogle(emailController.text.trim(), passwordController.text.trim());
      await userController.saveUserRecord(userCredentials);
      FFullScreenLoader.hideLoading();
      AuthenticationRepository.instance.screenRedirect();
    }catch(e){
      kLoaders.errorSnackBar(title: 'Dang it',message: e.toString());
    }
}
}