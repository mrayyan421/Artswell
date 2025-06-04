import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/features/personalization/screens/profile/editCredentials.dart';
import 'package:artswellfyp/utils/helpers/fullScreenLoader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../data/repositories/userRepository/userRepository.dart';
import '../../../../../utils/http/networkManager.dart';
import '../../../../authentication/models/userModels/userModel.dart';
import '../../../controllers/userController.dart';

class UpdateNameController extends GetxController {
  // Singleton instance
  static UpdateNameController get instance => Get.find();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Dependencies
  final userController = UserController.instance;
  final userRepository = UserRepository.instance;
  final updateUserNameFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  /// Initialize name fields with current user data
  Future<void> initializeNames() async {
    nameController.text = userController.user.value.fullName ?? '';
    phoneController.text = userController.user.value.phoneNumber ?? '';
  }

  /// Update user name in Firestore and local state
  Future<void> updateUserName() async {
    // Show full screen loading
    FFullScreenLoader.openLoadingDialog('Updating your information...', 'assets/images/processing.gif');

    try {
      // Check network
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FFullScreenLoader.hideLoading();
        kLoaders.warningSnackBar(
          title: 'No Internet',
          message: 'Please check your connection.',
        );
        return;
      }

      // Validate form
      if (!updateUserNameFormKey.currentState!.validate()) {
        FFullScreenLoader.hideLoading();
        return;
      }

      // Prepare and update
      final newName = nameController.text.trim();
      final newPhone = phoneController.text.trim();
      final updateData = {'fullName': newName,'phoneNumber':newPhone};

      await userRepository.updateSingleField(updateData);

      // Update local user object safely
      userController.user.value = UserModel(
        uid: userController.user.value.uid,
        fullName: userController.user.value.fullName,
        email: userController.user.value.email,
        role: userController.user.value.role,
        phoneNumber: userController.user.value.phoneNumber,
        profilePic: userController.user.value.profilePic,
        createdAt: userController.user.value.createdAt,
        shopName: userController.user.value.shopName
      );

      // Hide loader before navigation
      FFullScreenLoader.hideLoading();

      // Success message
      kLoaders.successSnackBar(
        title: 'Success',
        message: 'Your name has been updated successfully',
      );

      // Navigate back
      Get.off(() => const EditCredentialsScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 700));
    } catch (e) {
      FFullScreenLoader.hideLoading();

      // Log for debugging
      debugPrint('Error updating name: $e');

      // Show error message
      kLoaders.errorSnackBar(
        title: 'Update Failed',
        message: e.toString(),
      );

      // Navigate back even on failure if desired
      Get.off(() => const EditCredentialsScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 700));
    }
  }


  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}