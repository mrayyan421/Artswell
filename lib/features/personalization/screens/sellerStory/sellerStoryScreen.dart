import 'dart:io';

import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/features/personalization/screens/sellerStory/sellerStory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/loaders/basicLoaders.dart';
import '../../../../utils/constants/colorConstants.dart';
import '../../controllers/sellerStoryController.dart';

class SellerStoryScreen extends StatelessWidget {
  final _storyController = TextEditingController();
  final _remarksController = TextEditingController();
  final _shopDetailsController = TextEditingController();
  final _controller = Get.put(SellerStoryController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final avatarRadius = isMobile ? 50.0 : 80.0;
    final horizontalPadding = isMobile ? 16.0 : 32.0;
    final verticalPadding = isMobile ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const ImageIcon(AssetImage('assets/icons/leftArrow.png')),
        ),
        title: const Text('Seller Story'),
        centerTitle: true,
        backgroundColor: kColorConstants.klPrimaryColor,
      ),
      body: Obx(() {
        final story = _controller.sellerStory.value;
        _storyController.text = story.successStory;
        _remarksController.text = story.remarks;
        _shopDetailsController.text = story.shopDetails;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 800, // Maximum content width for larger screens
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundImage: story.profileImageUrl != null
                                ? NetworkImage(story.profileImageUrl!)
                                : const AssetImage(
                                        'assets/images/default_profile.png')
                                    as ImageProvider,
                            child: story.profileImageUrl == null
                                ? ImageIcon(
                                    const AssetImage('assets/icons/add.png'),
                                    size: avatarRadius * 0.6,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to change story picture',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  _buildResponsiveTextField(
                    context: context,
                    controller: _storyController,
                    label: 'Your Success Story',
                    maxLines: isMobile ? 5 : 8,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 24),

                  _buildResponsiveTextField(
                    context: context,
                    controller: _remarksController,
                    label: 'Remarks About Our App',
                    maxLines: isMobile ? 3 : 5,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 24),

                  _buildResponsiveTextField(
                    context: context,
                    controller: _shopDetailsController,
                    label: 'Shop Details',
                    maxLines: isMobile ? 3 : 5,
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: isMobile ? double.infinity : 300,
                    child: ElevatedButton(
                      onPressed: () => _controller.updateStory(
                        successStory: _storyController.text,
                        remarks: _remarksController.text,
                        shopDetails: _shopDetailsController.text,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Story',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton:_controller.sellerStory.value.id!=null? FloatingActionButton(
          child: const ImageIcon(AssetImage('assets/icons/rightArrow.png')),
          onPressed: () => Get.to(
              SellerStory(
                  sellerId: UserController.instance.user.value.uid,
                  shopName: UserController.instance.user.value.shopName ??
                      'ArtsWell'),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 700))):const SizedBox.shrink(),
    );
  }

  Widget _buildResponsiveTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required int maxLines,
    required bool isMobile,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 16 : 20,
        ),
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isMobile ? 14 : 16,
          ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        await _controller.uploadProfilePicture(File(pickedFile.path));
      }
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to pick image');
    }
  }
}
