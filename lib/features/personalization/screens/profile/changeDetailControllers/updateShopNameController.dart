import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/features/personalization/screens/profile/editCredentials.dart';
import 'package:artswellfyp/utils/helpers/fullScreenLoader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../data/repositories/userRepository/userRepository.dart';
import '../../../../../utils/http/networkManager.dart';
import '../../../../authentication/models/userModels/userModel.dart';
import '../../../controllers/userController.dart';

class UpdateShopNameController extends GetxController {
  static UpdateShopNameController get instance => Get.find();

  // Controller for shop name only
  final shopNameController = TextEditingController();

  // Dependencies
  final userController = UserController.instance;
  final userRepository = UserRepository.instance;
  final updateShopNameFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    initializeShopName();
    super.onInit();
  }

  /// Initialize shop name field with current user data
  Future<void> initializeShopName() async {
    shopNameController.text = userController.user.value.shopName ?? '';
  }

  /// Update shop name in Firestore and local state
  Future<void> updateShopName() async {
    // Show full screen loading
    FFullScreenLoader.openLoadingDialog(
        'Updating shop name...',
        'assets/images/processing.gif'
    );

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
      if (!updateShopNameFormKey.currentState!.validate()) {
        FFullScreenLoader.hideLoading();
        return;
      }

      // Prepare and update
      final newShopName = shopNameController.text.trim();
      final updateData = {'shopName': newShopName};

      await userRepository.updateSingleField(updateData);

      // Update local user object
      userController.user.value = UserModel(
          uid: userController.user.value.uid,
          fullName: userController.user.value.fullName,
          email: userController.user.value.email,
          role: userController.user.value.role,
          phoneNumber: userController.user.value.phoneNumber,
          profilePic: userController.user.value.profilePic,
          createdAt: userController.user.value.createdAt,
          shopName: newShopName,
          favoriteProductIds: userController.user.value.favoriteProductIds,
          orderIds: userController.user.value.orderIds
      );

      // Hide loader before navigation
      FFullScreenLoader.hideLoading();

      // Success message
      kLoaders.successSnackBar(
        title: 'Success',
        message: 'Shop name updated successfully',
      );

      // Navigate back
      Get.off(() => const EditCredentialsScreen());
    } catch (e) {
      FFullScreenLoader.hideLoading();
      debugPrint('Error updating shop name: $e');
      kLoaders.errorSnackBar(
        title: 'Update Failed',
        message: e.toString(),
      );
      Get.off(() => const EditCredentialsScreen());
    }
  }
}
