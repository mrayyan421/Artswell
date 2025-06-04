import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/personalization/controllers/userController.dart';
import '../../../../features/shop/controllers/productController.dart';
import '../../../../features/shop/models/productModel.dart';
import '../../../../utils/constants/colorConstants.dart';
import '../../../../utils/constants/size.dart';
import '../../circularIcon.dart';
import '../../commonWidgets/curvedEdgesWidget.dart';
import '../../commonWidgets/roundedImagePromotion.dart';

class ProductImageSlider extends StatelessWidget {
  final ProductModel product;

  const ProductImageSlider({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    // Initialize with the current product
    if (controller.selectedProduct.value?.id != product.id) {
      controller.selectedProduct.value = product;
    }

    return Obx(() {
      final currentProduct = controller.selectedProduct.value ?? product;
      final images = currentProduct.productImages ?? [];
      final primaryIndex = currentProduct.primaryImageIndex ?? 0;
      final primaryUrl = images.isNotEmpty ? images[primaryIndex] : null;

      return kCurvedEdgesWidget(
        child: Stack(
          children: [
            // Main product image
            SizedBox(
              height: 400,
              width: double.infinity,
              child: _buildMainImage(primaryUrl),
            ),

            // Thumbnail images
            if (images.length > 1)
              _buildThumbnailList(controller, currentProduct, images, primaryIndex),

            // App bar
            _buildAppBar(currentProduct),
          ],
        ),
      );
    });
  }

  Widget _buildMainImage(String? imageUrl) {
    return imageUrl != null
        ? CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => _buildPlaceholderImage(),
    )
        : _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'assets/images/categories/stoneArt.png',
      fit: BoxFit.cover,
    );
  }

  Widget _buildThumbnailList(
      ProductController controller,
      ProductModel product,
      List<String> images,
      int currentIndex,
      ) {
    return Positioned(
      bottom: kSizes.largePadding,
      left: kSizes.mediumPadding,
      right: 0,
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, __) => const SizedBox(width: kSizes.mediumPadding),
          itemBuilder: (_, index) => GestureDetector(
            onTap: () {
              // Update only if this is the current product
              if (controller.selectedProduct.value?.id == product.id) {
                controller.updatePrimaryImageLocally(index);
                controller.setPrimaryImage(product.id, index);
              }
            },
            child: Obx(() {
              final isSelected = (controller.selectedProduct.value?.id == product.id &&
                  controller.selectedProduct.value?.primaryImageIndex == index);
              return RoundedImagePromotion(
                img: images[index],
                height: 80,
                width: 95,
                borderRadius: BorderRadius.circular(25),
              );
            }),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ProductModel product) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: kCircularIcon(
        icon: 'assets/icons/leftArrow.png',
        size: 40,
        color: kColorConstants.kdGreyColor2,
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          final isFavorite = UserController.instance.isProductFavorite(product.id);
          return kCircularIcon(
            icon: isFavorite
                ? 'assets/icons/favoriteColored.png'
                : 'assets/icons/favorite.png',
            color: kColorConstants.klAntiqueWhiteColor,
            height: kSizes.xlargIcon,
            width: kSizes.xlargIcon,
            onPressed: () => UserController.instance.toggleFavoriteProduct(product.id),
          );
        }),
      ],
    );
  }
}