import 'package:artswellfyp/common/widgets/customizedShapes/product/verticalproductCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../features/personalization/controllers/userController.dart';
import '../../../features/shop/controllers/productController.dart';
import '../../../utils/constants/colorConstants.dart';
import '../../../utils/constants/size.dart';

class SearchResultsBottomSheet extends StatelessWidget {
  const SearchResultsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.put(ProductController());

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(kSizes.mediumPadding),
      decoration: const BoxDecoration(
        color: kColorConstants.klAntiqueWhiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Obx(() {
        if (productController.searchQuery.isEmpty) {
          return Center(
            child: Text(
              'Start typing to search products',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        if (productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productController.searchResults.isEmpty) {
          return Center(
            child: Text(
              'No products found for "${productController.searchQuery.value}"',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return GridView.builder(
          gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: kSizes.gridViewSpace,
            crossAxisSpacing: kSizes.gridViewSpace,
            childAspectRatio: 0.65,
          ),
          itemCount: productController.searchResults.length,
          itemBuilder: (context, index) {
            final product = productController.searchResults[index];
            return ProductCardVertical(
              productImagePath: product.productImages.isNotEmpty
                  ? product.productImages[0]
                  : 'assets/images/categories/stoneArt.png',
              isFavorite: UserController.instance.isProductFavorite(product.id),
              onFavoriteToggle: () => UserController.instance.toggleFavoriteProduct(product.id),
              productId: product.id,
              labelText: product.productName,
              priceText: product.productPrice,
              isBidding: product.isBiddable,
              rating: product.averageRating,
              product: product,
            );
          },
        );
      }),
    );
  }
}