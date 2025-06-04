import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/common/widgets/successScreen.dart';
import 'package:artswellfyp/features/personalization/controllers/addressController.dart';
import 'package:artswellfyp/features/personalization/screens/profile/editCredentials.dart';
import 'package:artswellfyp/features/shop/controllers/productController.dart';
import 'package:artswellfyp/features/shop/screens/checkOut/checkOutMain/checkOut.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productDetailMain/productDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colorConstants.dart';
import '../../personalization/screens/address/addressCard.dart';
import '../../personalization/screens/address/addressMain/addNewAddress.dart';
import '../../personalization/screens/address/addressMain/address.dart';
import '../../personalization/screens/orderManagement.dart';
import '../models/productModel.dart';
//TODO: to mainly handle home paage navigations
class HomeController extends GetxController {
  static HomeController get instance => Get.find();
  final addController = PageController();
  var currentIndex = 0.obs;

  void updatePageIndicator(int index) {
    //function to update index
    currentIndex.value = index;
  }

  void editCredentials() {
    Get.to(
      const EditCredentialsScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 700),
    );
  }

  void returnPage() {
    Get.back();
  }

  /*void deleteDialogueBox(){

  }*/
  void productDetailPageNavigation(BuildContext context,ProductModel product) {
    Get.to(
      ProductDetail(product: product,),
      binding: BindingsBuilder(() => Get.put(ProductController())),
      transition: Transition.downToUp,
      duration: const Duration(seconds: 1),
    );
  }

  void userAddressNavigation() {
    Get.to(
      const UserAddressScreen(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 700),
    );
  }

  void userAddressCardNavigation() {
    final addressController = AddressController.instance;

    // Check if we have any addresses at all
    if (addressController.addresses.isEmpty) {
      kLoaders.errorSnackBar(
        title: 'No Addresses Available',
        message: 'Please add an address first',
      );
      return;
    }

    // Check if we have a default (selected) address
    final defaultAddress = addressController.addresses.firstWhereOrNull(
            (addr) => addr.isDefault
    );

    if (defaultAddress != null) {
      // Navigate to address confirmation screen with the selected address
      Get.to(
            () => Scaffold(
          appBar: AppBar(
            title: const Text('Confirm Address'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                kAddressContainer(
                  address: defaultAddress,
                  selectedAddress: true,
                  onTap: () {},
                  onLongTap: (){},
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle address confirmation
                    Get.back(result: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kColorConstants.klVisitStoreElevationBtnClr,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Confirm Address'),
                ),
              ],
            ),
          ),
        ),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 700),
      );
    } else {
      kLoaders.warningSnackBar(
        title: 'No Default Address',
        message: 'Please select a default address first',
      );
      Get.to(
            () => const UserAddressScreen(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 700),
      );
    }
  }
    void userAddAddressNavigation() {
      Get.to(
        const AddNewAddress(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 700),
      );
    }

    void checkOutNavigation() {
      Get.to(
        CheckoutScreen(),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 700),
      );
    }

    void successPaymentNavigation() {
      Get.to(
        const SuccessScreen(
          subTitle: 'Order Confirmed! Happy Shopping ;-)',
          btnText: '<-Continue Shopping',
        ),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 700),
      );
    }

    void orderPageNavigation() {
      Get.to(
        OrderManagementScreen(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 700),
      );
    }
  }

