import 'package:artswellfyp/common/widgets/customizedShapes/appBar.dart';
import 'package:artswellfyp/common/widgets/customizedShapes/product/verticalproductCard.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/size.dart';
import '../../../../utils/theme/theme.dart';
import '../../../personalization/controllers/userController.dart';
import '../../controllers/productController.dart';

class kFavoriteScreen extends StatefulWidget {
  const kFavoriteScreen({super.key});

  @override
  State<kFavoriteScreen> createState() => _kFavoriteScreenState();
}

class _kFavoriteScreenState extends State<kFavoriteScreen> {
  final productController = Get.put(ProductController());
  final userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    userController.fetchFavoriteProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorConstants.klPrimaryColor,
      appBar: const CustomAppbar(),
      body: Obx(() {
        // Get only favorite products
        final favoriteProducts = productController.products.where((product) => userController.favoriteProductIds.contains(product.id)).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(kSizes.mediumPadding),
          child: Column(
            children: [
              if (favoriteProducts.isEmpty)
                Center(
                  child: Text(
                    'No favorites yet',
                    style: kAppTheme.lightTheme.textTheme.displayMedium,
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: kSizes.gridViewSpace,
                    crossAxisSpacing: kSizes.gridViewSpace,
                    mainAxisExtent: 335,
                  ),
                  itemCount: favoriteProducts.length,
                  itemBuilder: (_, index) {
                    final product = favoriteProducts[index];
                    return ProductCardVertical(
                      productImagePath: product.productImages.isNotEmpty
                          ? product.productImages[0]
                          : 'assets/images/categories/stoneArt.png',
                      isFavorite: true, // Always true since these are favorites
                      onFavoriteToggle: () => userController
                          .toggleFavoriteProduct(product.id),
                      productId: product.id,
                      product: product,
                      labelText: product.productName,
                      priceText: product.productPrice,
                      isBidding: product.isBiddable,
                      rating: productController.averageRating.value,
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}


