import 'package:artswellfyp/features/shop/controllers/productController.dart';
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
import '../../../../models/productModel.dart';
import '../elevatedButtonRow.dart';
import 'addProduct.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetail extends StatefulWidget {
  final ProductModel product;

  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final  productCtrl = Get.put(ProductController());
  final UserController userController = Get.put(UserController());
  late final RxDouble averageRating;

  @override
  void initState() {
    super.initState();
    averageRating = 0.0.obs;
    productCtrl.refreshComments(widget.product.id);
  }

  @override
  void dispose() {
    // Dispose all Rx variables and controllers
    averageRating.close();
    super.dispose();
  }

  void updateCart(int itemCount) {
    debugPrint("Cart updated with $itemCount items.");
  }

  void incrementItemCount(int itemCount) {
    debugPrint("Incremented item count to $itemCount.");
  }

  void decrementItemCount(int itemCount) {
    debugPrint("Decremented item count to $itemCount.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: userController.user.value.role == 'Customer'
          ? kBottomAddToCart(
        productId: widget.product.id,
        productName: widget.product.productName,
        productPrice: widget.product.productPrice.toDouble(),
      )
          : null,
      backgroundColor: kColorConstants.klBottomSheetBgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductImageSlider(product: widget.product),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kSizes.largePadding,
                0,
                kSizes.largePadding,
                kSizes.largePadding,
              ),
              child: Column(
                children: [
                  kRatingAndShare(
                    rating: widget.product.averageRating,
                    product: widget.product,
                  ),
                  kProductMetaData(product: widget.product),
                  kStockText(product: widget.product),
                  const SizedBox(height: 10),
                  kElevatedButtonRow(product: widget.product),
                  const SizedBox(height: 10),
                  if (widget.product.isBiddable == true)
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
      floatingActionButton: userController.user.value.role == 'Seller'
          ? Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 10),
        child: FloatingActionButton(
          backgroundColor: kColorConstants.klOrangeColor,
          onPressed: () {
            Get.to(
                  () => AddProductScreen(),
              transition: Transition.leftToRightWithFade,
              duration: const Duration(milliseconds: 500),
            );
          },
          child: const ImageIcon(
            AssetImage('assets/icons/add.png'),
            color: kColorConstants.klAntiqueWhiteColor,
          ),
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}







