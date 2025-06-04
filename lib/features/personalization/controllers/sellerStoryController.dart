import 'dart:io';

import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../common/widgets/loaders/basicLoaders.dart';
import '../../../data/repositories/userRepository/sellerStoryRepository.dart';
import '../models/sellerStoryModel.dart';

import 'dart:io';


class SellerStoryController extends GetxController {
  static SellerStoryController get instance => Get.find();

  final SellerStoryRepository _repository = SellerStoryRepository();
  final Rx<SellerStoryModel> sellerStory = SellerStoryModel(
    userId: '',
    successStory: '',
    remarks: '',
    shopDetails: '',
    createdAt: Timestamp.now(),
    shopName: ''
  ).obs;

  @override
  void onInit() {
    super.onInit();
    loadSellerStory();
  }

  Future<void> loadSellerStory() async {
    try {
      final user = UserController.instance.user.value;
      sellerStory.value = await _repository.getSellerStory(user.uid);
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to load story');
    }
  }

  Future<void> updateStory({
    String? successStory,
    String? remarks,
    String? shopDetails,
  }) async {
    try {
      // Create new model instance without copyWith
      final updatedStory = SellerStoryModel(
        id: sellerStory.value.id,
        userId: sellerStory.value.userId,
        profileImageUrl: sellerStory.value.profileImageUrl,
        successStory: successStory ?? sellerStory.value.successStory,
        remarks: remarks ?? sellerStory.value.remarks,
        shopDetails: shopDetails ?? sellerStory.value.shopDetails,
        createdAt: sellerStory.value.createdAt,
        shopName:UserController.instance.user.value.shopName??'ArtsWell',
        updatedAt: Timestamp.now(),
      );

      await _repository.updateSellerStory(updatedStory);
      sellerStory.value = updatedStory;
      kLoaders.successSnackBar(title: 'Success', message: 'Story updated');
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to update story');
    }
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final imageUrl = await _repository.uploadProfileImage(
          sellerStory.value.userId,
          imageFile
      );

      // Create new model instance without copyWith
      final updatedStory = SellerStoryModel(
        id: sellerStory.value.id,
        userId: sellerStory.value.userId,
        profileImageUrl: imageUrl,
        successStory: sellerStory.value.successStory,
        remarks: sellerStory.value.remarks,
        shopDetails: sellerStory.value.shopDetails,
        createdAt: sellerStory.value.createdAt,
        updatedAt: Timestamp.now(),
        shopName: UserController.instance.user.value.shopName??'ArtsWell'
      );

      await _repository.updateSellerStory(updatedStory);
      sellerStory.value = updatedStory;

      Get.back();
      kLoaders.successSnackBar(title: 'Success', message: 'Profile picture updated');
    } catch (e) {
      Get.back();
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to upload image');
    }
  }
}