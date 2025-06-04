import 'package:artswellfyp/features/personalization/controllers/sellerStoryController.dart';
import 'package:artswellfyp/features/personalization/screens/sellerStory/sellerStory.dart';
import 'package:artswellfyp/features/shop/controllers/orderController.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productDetailMain/productDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';

import '../../../../common/widgets/customizedShapes/product/verticalproductCard.dart';
import '../../../personalization/controllers/userController.dart';
import '../../controllers/productController.dart';
import '../productDetails/productDetailScreen/productDetailMain/addProduct.dart';

class ShopScreen extends StatefulWidget {
  final String? sellerId;
  final String? shopName;
  const ShopScreen({super.key, this.sellerId, this.shopName});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final productController = Get.put(ProductController());
  final userController = Get.put(UserController());
  final orderController = Get.put(OrderController());
  final sellerStoryController = Get.put(SellerStoryController());
  final RxString shopName = 'Loading...'.obs;
  final RxDouble totalSales = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _loadShopName();
    if (UserController.instance.user.value.role == 'Seller') {
      orderController.calculateTotalSales(UserController.instance.user.value.uid);
    }
    // Load products when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.loadSellerProducts(
          widget.sellerId ?? userController.user.value.uid);
    });
  }

  Future<void> _loadShopName() async {
    final name = await productController.getShopName(widget.sellerId!);
    shopName.value = name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Image.asset('assets/icons/leftArrow.png'),
        ),
        title: Obx(() => Text(shopName.value)),
        centerTitle: true,
        backgroundColor: kColorConstants.klPrimaryColor,
      ),
      body: Obx(() {
        if (productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildProductList(context, productController, userController);
      }),
      floatingActionButton: _buildFloatingActionButton(userController),
    );
  }

  Widget _buildProductList(
      BuildContext context,
      ProductController productController,
      UserController userController) {
    if (productController.sellerProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No products yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: kSizes.mediumPadding),
            ElevatedButton(
              onPressed: () => Get.to(() => AddProductScreen()),
              child: const Text('Add Your First Product'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: kSizes.largePadding,
                  left: kSizes.largePadding,
                  right: kSizes.largePadding,
                  bottom: kSizes.mediumPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: UserController.instance.user.value.role == 'Seller'
                      ? Container(
                    padding: const EdgeInsets.all(kSizes.mediumPadding),
                    decoration: BoxDecoration(
                      color: kColorConstants.klSecondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(kSizes.largeBorderRadius),
                    ),
                    child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Products',
                            productController.sellerProducts.length.toString()),
                        _buildStatItem('Sales', 'PKR ${orderController.totalSales.value}'),
                        _buildStatItem('Rating',
                            productController.averageRating.value.toStringAsFixed(1)),
                      ],
                    )),
                  )
                      : const SizedBox.shrink(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: kSizes.largePadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: kSizes.gridViewSpace,
                    crossAxisSpacing: kSizes.gridViewSpace,
                    childAspectRatio: 0.65,
                    mainAxisExtent: 280,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final product = productController.sellerProducts[index];
                      return GestureDetector(
                          child: ProductCardVertical(
                          productImagePath: product.productImages.isNotEmpty
                          ? product.productImages[0]
                              : 'assets/images/categories/stoneArt.png',
                          labelText: product.productName,
                          product: product,
                          priceText: product.productPrice,
                          isBidding: product.isBiddable,
                          rating: product.averageRating,
                          showEditOptions: UserController.instance.user.value.role == 'Seller' ? true : false,
                          productId: product.id,
                          isFavorite: userController.isProductFavorite(product.id),
                      onFavoriteToggle: () => userController.toggleFavoriteProduct(product.id),
                      ),
                      onTap: () =>  Get.to(
                      () => UserController.instance.user.value.uid!=null?ProductDetail(product: product):SizedBox.shrink(),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 700),
                      ));
                    },
                    childCount: productController.sellerProducts.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Add the "View Success Story" button at the bottom
        if (productController.sellerProducts.isNotEmpty && UserController.instance.user.value.role=='Customer')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Get.to(
                        () => SellerStory(
                      sellerId: widget.sellerId ?? userController.user.value.uid,
                      shopName: shopName.value,
                    ),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: kColorConstants.klPrimaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'View Success Story',
                  style: TextStyle(
                    color: kColorConstants.klPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton(UserController userController) {
    return Obx(() {
      return userController.user.value.role == 'Seller'
          ? FloatingActionButton(
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
      )
          : const SizedBox.shrink();
    });
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kColorConstants.klSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}