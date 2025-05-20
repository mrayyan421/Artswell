import 'package:artswellfyp/features/authentication/screens/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/widgets/loaders/basicLoaders.dart';
import '../../../data/repositories/authenticationRepository/authenticationRepository.dart';
import '../../../utils/helpers/fullScreenLoader.dart';
import '../../../utils/http/networkManager.dart';

class ForgotPasswordController extends GetxController {
  // Singleton instance of the controller
  static ForgotPasswordController get instance => Get.find();

  // Variables
  final email = TextEditingController();
  final GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  /// Send Reset Password Email
  Future<void> sendForgetPasswordEmailForCurrentUser() async {
    try {
      // Show loading dialog
      FFullScreenLoader.openLoadingDialog('Processing your request...', 'assets/images/processing.gif');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.hideLoading();
        kLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      // Validate form input
      if (!forgetPasswordFormKey.currentState!.validate()) {
        FFullScreenLoader.hideLoading();
        return;
      }

      final emailAddress = email.text.trim();
      if (emailAddress.isEmpty) {
        FFullScreenLoader.hideLoading();
        kLoaders.errorSnackBar(title: 'Error', message: 'Please enter an email address');
        return;
      }

      // Send the password reset email
      await AuthenticationRepository.instance.resetPassword(emailAddress);

      // Stop loading and show success snack bar
      FFullScreenLoader.hideLoading();
      kLoaders.successSnackBar(
        title: 'Email Sent',
        message: 'A password reset link has been sent to $emailAddress.',
      );

      // Go back to login screen
      Get.offAll(() => const LoginPage());
    } catch (e) {
      // Handle errors and stop loader
      FFullScreenLoader.hideLoading();
      kLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }

  /// Resend Password Reset Email (Optional Functionality)
/*  Future<void> resendPasswordResetEmail(String emailAddress) async {
    try {
      // Show loading dialog
      FFullScreenLoader.openLoadingDialog('Resending Email...', 'assets/images/processing.gif');

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.hideLoading();
        kLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      // Resend the password reset email
      await AuthenticationRepository.instance.resetPassword();

      // Stop loading and show success snack bar
      FFullScreenLoader.hideLoading();
      kLoaders.successSnackBar(
        title: 'Email Resent',
        message: 'The password reset link has been resent to $emailAddress.',
      );
    } catch (e) {
      FFullScreenLoader.hideLoading();
      kLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }*/
}
