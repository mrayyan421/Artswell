import 'package:artswellfyp/common/widgets/commonWidgets/divider.dart';
import 'package:artswellfyp/data/repositories/userRepository/userRepository.dart';
import 'package:artswellfyp/features/personalization/screens/profile/changeDetailScreens/changeName.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/commonWidgets/popups/warningPopup.dart';
import '../../../../common/widgets/editCredentialsTile.dart';
import '../../../../common/widgets/loaders/basicLoaders.dart';
import '../../controllers/userController.dart';
import 'changeDetailScreens/changePhoneNumber.dart';
import 'changeDetailScreens/changeShopName.dart';

class EditCredentialsScreen extends StatefulWidget {
  const EditCredentialsScreen({super.key});

  @override
  State<EditCredentialsScreen> createState() => _EditCredentialsScreenState();
}

class _EditCredentialsScreenState extends State<EditCredentialsScreen> {
  final userController = UserController.instance;
  final userRepository = Get.find<UserRepository>();


  Future<void> _copyToClipboard(String text, String fieldName) async {
    if (text.isEmpty) {
      kLoaders.warningSnackBar(
        title: 'Nothing to copy',
        message: '$fieldName is empty',
      );
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: text));
      kLoaders.successSnackBar(
        title: 'Copied!',
        message: '$fieldName copied to clipboard',
      );
    } catch (e) {
      kLoaders.errorSnackBar(
        title: 'Copy Failed',
        message: 'Could not copy $fieldName: ${e.toString()}',
      );
      debugPrint('Error copying to clipboard: $e');
    }
  }

  void _showWarningPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return Warningpopup(
          warningText: "Are you sure you want to delete your account?",
          confirmTxt: "Delete",
          onPressed: () async {
            String? userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId != null) {
              await FirebaseFirestore.instance.collection("Users").doc(userId).delete();
              await UserRepository.instance.deleteUser(userId);
              Get.back();
            } else {
              print("Error: No user is signed in.");
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorConstants.klPrimaryColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: const ImageIcon(AssetImage('assets/icons/leftArrow.png')),
        ),
        title: const Text('Profile Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: kSizes.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: kSizes.smallPadding),
            Hero(
              tag: 'settingsProfileIconTag',
              child: Obx((){
                final networkImg=userController.user.value.profilePic;
                final img=networkImg!.isNotEmpty?NetworkImage(networkImg):const AssetImage('assets/icons/acct.png');
                return  CircleAvatar(
                    radius: 50,
                    backgroundImage: img as ImageProvider/*_selectedImage != null
                      ? FileImage(_selectedImage!)
                      : const AssetImage('assets/icons/acct.png') as ImageProvider,*/
                );}
              ),
            ),
            TextButton(
              onPressed: userController.uploadUserDP,
              child: Text(
                'Change Profile Picture',
                style: kAppTheme.lightTheme.textTheme.displayMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
            const AppDivider(
                thickness: kSizes.dividerHeight + 0.1,
                indent: 40,
                endIndent: 40),
            // Editable Fields
            Obx(()=> editCredentialsTile(
              title: 'Name',
              value: userController.user.value.fullName,
              imgPath: 'assets/icons/rightArrow.png',
              onTap: () {
                Get.to(const ChangeNameScreen(), transition: Transition.leftToRightWithFade, duration: const Duration(milliseconds: 500));
              },
            ),
            ),
            const SizedBox(height: kSizes.smallPadding),
            // Copyable Fields
            editCredentialsTile(
              title: 'User Id',
              value: userController.user.value.uid,
              imgPath: 'assets/icons/copy.png',
              onTap: () {
                _copyToClipboard(userController.user.value.uid, 'User ID');
              },
            ),
            const SizedBox(height: kSizes.smallPadding),
            editCredentialsTile(
              title: 'Email',
              value: userController.user.value.email,
              imgPath: 'assets/icons/copy.png',
              onTap: () {
                _copyToClipboard(userController.user.value.email, 'Email');
              },
            ),
            const SizedBox(height: kSizes.smallPadding),
            Obx(()=> editCredentialsTile(
              title: 'Mobile number',
              value: userController.user.value.phoneNumber.toString(),
              imgPath: 'assets/icons/rightArrow.png',
              onTap: () {
                Get.to(const ChangePhoneNumber(),
                    transition: Transition.leftToRightWithFade,
                    duration: const Duration(milliseconds: 500));
              },
            ),
            ),
            const SizedBox(height: kSizes.smallPadding),
            Obx(()=> userController.user.value.role=='Seller'? editCredentialsTile(
              title: 'Shop Name',
              value: userController.user.value.shopName.toString(),
              imgPath: 'assets/icons/rightArrow.png',
              onTap: () {
                Get.to(const ChangeShopName(),
                    transition: Transition.leftToRightWithFade,
                    duration: const Duration(milliseconds: 500));
              },
            ):const SizedBox.shrink()
            ),
            const SizedBox(height: kSizes.smallPadding),
            /*editCredentialsTile(
              title: 'Mailing Address',
              value: 'Mailing Address goes here',
              imgPath: 'assets/icons/rightArrow.png',
              onTap: () {
                // Add address editing logic here
              },
            ),
            const SizedBox(height: kSizes.smallPadding),
            editCredentialsTile(
              title: 'Billing Address',
              value: 'Billing Address goes here',
              imgPath: 'assets/icons/rightArrow.png',
              onTap: () {
                // Add address editing logic here
              },
            ),
            const SizedBox(height: kSizes.smallPadding),*/
            editCredentialsTile(
              title: 'Date of Joining',
              value: userController.user.value.createdAt.toString() ?? 'N/A',
              imgPath: 'assets/icons/copy.png',
              onTap: () {
                _copyToClipboard(
                    userController.user.value.createdAt.toString() ?? '',
                    'Date of Joining'
                );
              },
            ),
            const SizedBox(height: kSizes.smallPadding),
            TextButton(
              onPressed: _showWarningPopup,
              child: Text(
                'Delete Account',
                style: kAppTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: kColorConstants.klSearchBarColor,
                ),
              ),
            ),
            const SizedBox(height: kSizes.mediumPadding),
          ],
        ),
      ),
    );
  }
}