import 'package:artswellfyp/common/widgets/customizedShapes/appBar.dart';
import 'package:artswellfyp/features/authentication/controllers/initialScreenControllers.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _pickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery); // Or use pickVideo for videos
    if (pickedFile != null) {
      Get.find<AppLandingController>().setFile(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLandingController fileController = Get.find<AppLandingController>();

    return Scaffold(
      appBar: const CustomAppbar(),
      backgroundColor: kColorConstants.klPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              if (fileController.image.value!= null) {
                final fileExtension = fileController.image.value!.path.split('.').last;
                if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(fileController.image.value!),
                  );
                } else if (['mp4', 'mov', 'avi'].contains(fileExtension)) {
                  return const Text('Video file selected'); // Placeholder for video preview
                }
              }
              return const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile_icon.png') as ImageProvider,
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick Image or Video from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
