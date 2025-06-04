import 'package:artswellfyp/data/repositories/productRepository/productRepository.dart';
import 'package:artswellfyp/features/shop/controllers/productController.dart';
import 'package:artswellfyp/features/shop/models/productModel.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productDetailMain/productDetailsSeller.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/common/styles/boxShadow.dart';
import 'package:artswellfyp/common/widgets/commonWidgets/roundedImagePromotion.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:artswellfyp/utils/constants/size.dart';

import '../../../../features/personalization/controllers/userController.dart';
import '../../../../features/shop/screens/productDetails/productDetailScreen/productDetailMain/editProduct.dart';

class ProductCardVertical extends StatefulWidget {
  const ProductCardVertical({
    super.key,
    required this.productId,
    required this.product,
    required this.productImagePath,
    required this.labelText,
    required this.priceText,
    required this.isBidding,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.rating,
    this.showEditOptions = false,
    this.onEditPressed,
    this.onTap,
  });

  final String productId;
  final String productImagePath;
  final String labelText;
  final int priceText;
  final bool isBidding;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final double rating;
  final bool showEditOptions;
  final VoidCallback? onEditPressed;
  final VoidCallback? onTap;
  final ProductModel product;

  @override
  State<ProductCardVertical> createState() => _ProductCardVerticalState();
}

class _ProductCardVerticalState extends State<ProductCardVertical> {
  @override
  Widget build(BuildContext context) {
    final filledStars = widget.rating.floor();
    final hasHalfStar = widget.rating - filledStars >= 0.5;
    final productCtrl=Get.put(ProductController());

    return Obx((){
      final isCurrentlyFavorite = UserController.instance.isProductFavorite(widget.productId);
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: const [kBoxShadow.verticalBoxShadow],
            borderRadius: BorderRadius.circular(kSizes.itemImgRadius),
            color: kColorConstants.klProductContainerBgColor,
          ),height: kDeviceComponents.screenHeight(context)/8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with badges
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(kSizes.itemImgRadius),
                    child: RoundedImagePromotion(
                      img: widget.productImagePath,
                      width: double.infinity,
                      height: UserController.instance.user.value.role=='Customer'?130:160,
                      borderRadius: BorderRadius.circular(kSizes.itemImgRadius),
                    ),
                  ),

                  // Biddable Badge
                  if (widget.isBidding)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(225, 138, 1, 0.8),
                          borderRadius: BorderRadius.circular(kSizes.mediumPadding),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSizes.smallPadding,
                          vertical: 2,
                        ),
                        child: Text(
                          'Biddable',
                          style: kAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                  // Favorite Button - Updated to use ImageIcon
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: widget.onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255,255,255,0.8),
                          shape: BoxShape.circle,
                        ),
                        child: ImageIcon(
                          AssetImage(
                            isCurrentlyFavorite
                                ? 'assets/icons/favoriteColored.png'
                                : 'assets/icons/favorite.png',
                          ),
                          size: 18,
                          // color: isCurrentlyFavorite
                          //     ? kColorConstants.klSecondaryColor
                          //     : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Edit Button (for sellers)
                  if (widget.showEditOptions)
                    Positioned(
                      right: 8,
                      bottom: 6,
                      child: GestureDetector(
                        onTap: widget.onEditPressed,
                        child:PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(255,255,255,0.7),
                              shape: BoxShape.circle,
                            ),
                            child:const ImageIcon(
                              AssetImage('assets/icons/edit.png'),
                              color: kColorConstants.klSelectedDayColor1,
                              size: 18,
                            ),
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _handleEditProduct();
                              // productCtrl.selectedProduct.value =
                              //     productCtrl.products.firstWhere((p) => p.id == productCtrl.selectedProduct.value!.id);
                            } else if (value == 'delete') {
                              await _showDeleteConfirmation(context,widget.productId);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit Product'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete Product'),
                            ),
                          ],),
                      ),
                    ),
                ],
              ),

              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(kSizes.smallPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Expanded(
                        child: Text(
                          widget.labelText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kAppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 4),

                      // Price
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Price: ',
                              style: kAppTheme.lightTheme.textTheme.bodySmall,
                            ),
                          ),
                          // SizedBox(width: 45,),
                          Text(
                            'PKR ${widget.priceText}',
                            style: kAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: kColorConstants.klSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Rating
                      /*Row(
                        children: [
                          Text(
                            'Rating: ',
                            style: kAppTheme.lightTheme.textTheme.bodySmall,
                          ),
                          Row(
                            children: List.generate(widget.rating.toInt(), (index) {
                              if (index < filledStars) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Image.asset(
                                    'assets/icons/ratingIconColored.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                );
                              } else if (index == filledStars && hasHalfStar) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Image.asset(
                                    'assets/icons/ratingIconColoredHalf.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Image.asset(
                                    'assets/icons/ratingIconUnColored.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                );
                              }
                            }),
                          ),
                          const SizedBox(width: 4),
                          // Text(
                          //   '(${widget.rating.toStringAsFixed(1)})',
                          //   style: kAppTheme.lightTheme.textTheme.bodySmall,
                          // ),
                        ],
                      ),*/
                      const SizedBox(height: 8),
                      // Shop Now Button
                      if (UserController.instance.user.value.role=='Customer')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(ProductDetailSeller(product: widget.product,), transition: Transition.downToUp, duration: const Duration(milliseconds: kSizes.initialAnimationTime),);},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              backgroundColor: kColorConstants.klSecondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Shop Now',
                              style: kAppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );}
    );
  }
  Future<void> _handleEditProduct() async {
    final repo=Get.put(ProductRepository());
    try {
      // Load the full product details
      final product = await repo.getProductById(widget.productId);
      ProductController().selectedProduct.value = product;

      Get.to(
            () => EditProductScreen(productId: product.id,),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 700),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load product for editing: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  Future<void> _showDeleteConfirmation(BuildContext context, String productId) async {
    final controller =Get.put(ProductController());
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await controller.deleteProduct(productId);  //instead of delete image create method deleteProduct in prd ctrl
              },
            ),
          ],
        );
      },
    );
  }

}
