import 'package:artswellfyp/features/shop/controllers/productController.dart';
import 'package:artswellfyp/features/shop/models/productModel.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productDetailMain/editProduct.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productMetaData.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/ratingShareWidget.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/stockText.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/bottomCartBar.dart';
import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';

import '../../../../../../common/widgets/customizedShapes/product/productImgSlider.dart';
import '../elevatedButtonRow.dart';
class ProductDetailSeller extends StatelessWidget {
  final ProductModel product;
  ProductDetailSeller({super.key,required this.product});

  final productCtrl = Get.put(ProductController());

  void updateCart(int itemCount) {
    print("Cart updated with $itemCount items.");
  }

  void incrementItemCount(int itemCount) {
    print("Incremented item count to $itemCount.");
  }

  void decrementItemCount(int itemCount) {
    print("Decremented item count to $itemCount.");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: kBottomAddToCart(
        productId: productCtrl.selectedProduct.value?.id ?? '',
        productName: productCtrl.selectedProduct.value?.productName ?? '',
        productPrice: productCtrl.selectedProduct.value?.productPrice.toDouble() ?? 0,
      ),
      backgroundColor: kColorConstants.klBottomSheetBgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductImageSlider(product: product,),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kSizes.largePadding,
                0,
                kSizes.largePadding,
                kSizes.largePadding,
              ),
              child: Column(
                children: [
                  kRatingAndShare(product: product,rating: product.averageRating),
                  kProductMetaData(product: product,),
                  kStockText(product: product,),
                  const SizedBox(height: 10),
                  kElevatedButtonRow(product: product,),
                  const SizedBox(height: 10),
                  if (productCtrl.selectedProduct.value?.isBiddable == true) //true->show btn/false-> hide btn
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to bidding screen if needed
                      },
                      child: const Text('Place your bid'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(() {
        return UserController.instance.user.value.role == 'Seller'
            ? FloatingActionButton(
          backgroundColor: kColorConstants.klOrangeColor,
          onPressed: () {
            Get.to(
                  () => EditProductScreen(productId: product.id,),
              transition: Transition.leftToRightWithFade,
              duration: const Duration(milliseconds: 500),
            );
          },
          child: const ImageIcon(
            AssetImage('assets/icons/edit.png'),
            color: kColorConstants.klAntiqueWhiteColor,
          ),
        )
            : const SizedBox.shrink();
      }),
    );
  }
}







