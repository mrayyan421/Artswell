import 'package:artswellfyp/common/widgets/successScreen.dart';
import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/features/shop/controllers/orderController.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';

class EasyPaisaUploadReceiptScreen extends StatelessWidget {
  final String orderId;
  final double amount;
  final _orderController = Get.put(OrderController());

  EasyPaisaUploadReceiptScreen({
    super.key,
    required this.orderId,
    required this.amount
  }) {
    // Validate amount when screen is created
    assert(amount > 0, 'Amount must be greater than zero');
  }

  Future<void> _submitReceipt() async {
    try {
      // 1. Validate receipt exists
      if (_orderController.receiptImage.value == null) {
        throw 'Please upload your payment receipt first';
      }

      // 2. Validate amount
      if (amount <= 0) {
        throw 'Invalid payment amount';
      }

      // 3. Get current user ID
      final userId = UserController.instance.user.value.uid;
      if (userId.isEmpty) {
        throw 'User not authenticated';
      }

      // 4. Submit receipt
      await _orderController.submitReceipt(orderId, amount);

      // 5. Clear cart after successful submission
      await _orderController.clearUserCart(userId);

      // 6. Navigate to success screen
      Get.offAll(() => const SuccessScreen(
        subTitle: 'Receipt submitted successfully! Wait for verification',
        btnText: 'Back to Home',
      ));

    } catch (e) {
      Get.offAll(() => const SuccessScreen(
        subTitle: 'Receipt submitted successfully! Wait for verification',
        btnText: 'Back to Home',
      ));
      rethrow;
    }
  }

  Future<void> _handleUpload() async {
    try {
      await _orderController.pickAndUploadReceipt(orderId);
    } on FirebaseException catch (e) {
      kLoaders.errorSnackBar(
        title: 'Upload Error',
        message: 'Firestore error: ${e.code}',
      );
    } catch (e) {
      kLoaders.errorSnackBar(
        title: 'Upload Failed',
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(child: const ImageIcon(AssetImage('assets/icons/leftArrow.png'),),),
        title: Text(
          'Upload Receipt',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(kSizes.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please upload your payment receipt for verification',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSizes.largePadding),

            Obx(() {
              if (_orderController.receiptImage.value != null) {
                return Container(
                  height: kDeviceComponents.screenHeight(context)/2,
                  decoration: BoxDecoration(
                    border: Border.all(color: kColorConstants.klPrimaryColor),
                    borderRadius: BorderRadius.circular(kSizes.mediumBorderRadius),
                  ),
                  child: Image.file(
                    _orderController.receiptImage.value!,
                    fit: BoxFit.contain,
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: _handleUpload,
                  child: Container(
                    height: kDeviceComponents.screenHeight(context)/2,
                    decoration: BoxDecoration(
                      border: Border.all(color: kColorConstants.klPrimaryColor),
                      borderRadius: BorderRadius.circular(kSizes.mediumBorderRadius),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          AssetImage('assets/icons/upload.png'),
                          size: 50,
                          color: kColorConstants.klPrimaryColor,
                        ),
                        SizedBox(height: kSizes.smallPadding),
                        Text(
                          'Tap to upload receipt',
                          style: TextStyle(color: kColorConstants.klPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),

            const SizedBox(height: kSizes.largePadding),

            Obx(() {
              if (_orderController.isUploading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(kColorConstants.klPrimaryColor),
                  ),
                );
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColorConstants.klPrimaryColor,
                  disabledBackgroundColor: Colors.grey,
                ),
                onPressed: _orderController.receiptImage.value != null
                    ? _submitReceipt
                    : null,
                child: const Text(
                  'Submit Receipt',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}