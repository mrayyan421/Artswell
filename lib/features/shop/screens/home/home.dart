//TODO: CREATE Home screen
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/common/widgets/customizedShapes/appBar.dart';
import 'package:artswellfyp/common/widgets/customizedShapes/product/verticalproductCard.dart';
import 'package:artswellfyp/features/shop/controllers/categoryController.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import '../../../../common/widgets/bottomSheetContainer.dart';
import '../../../../common/widgets/commonWidgets/filter.dart';
import '../../../../common/widgets/commonWidgets/titleText.dart';
import '../../../../common/widgets/customizedShapes/searchBarContainer.dart';
import '../../../../common/widgets/customizedShapes/searchResultsBottomSheet.dart';
import '../../../../common/widgets/verticalTextWidget.dart';
import '../../../../common/widgets/commonWidgets/productListingStructure.dart';
import '../../../personalization/controllers/userController.dart';
import '../../controllers/productController.dart';
import '../productDetails/productDetailScreen/productDetailMain/productDetails.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final productController = Get.put(ProductController());
  final userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.loadProducts();
    });
  }

  void _onCategoryTap(int index, String category) {
    setState(() {
      _selectedIndex = (_selectedIndex == index) ? -1 : index;
    });

    if (_selectedIndex == index) {
      productController.loadCategoryProducts(category);
    } else {
      productController.clearCategoryFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppbar(),
      backgroundColor: kColorConstants.klPrimaryColor,
      body: Obx(() {
        if (productController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: kColorConstants.klSecondaryColor,
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(kSizes.largePadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SearchContainer(
                    onSearchValue: (searchQuery) {
                      // Trigger search and update products
                      productController.loadProducts();
                      // productController.searchProducts(searchQuery);
                    },
                    text: 'What are you looking for?',
                    iconImg: 'assets/icons/search.png',
                    width: kDeviceComponents.screenWidth(context),
                    // onClear: () => productController.clearSearch(), // Add this
                  ),
                  const SizedBox(height: kSizes.mediumPadding),
                  Padding(
                    padding: const EdgeInsets.only(top:kSizes.largePadding,left: kSizes.smallPadding),
                    child: Column(
                      children: [
                        const SectionHeading(
                          title: 'Popular Categories',
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: kSizes.mediumPadding),
                        Obx(() {
                          if (categoryController.isLoading.value) {
                            return const SizedBox(
                              height: 80.0,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: kColorConstants.klSecondaryColor,
                                ),
                              ),
                            );
                          }
                          if (categoryController.featuredCategories.isEmpty) {
                            return Center(
                              child: Text(
                                'No Data found',
                                style: Theme.of(context).textTheme.displayMedium,
                              ),
                            );
                          }
                          return SizedBox(
                            height: kDeviceComponents.screenHeight(context)/10,
                            child: ListView.builder(
                              itemCount: categoryController.allCategories.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, index) {
                                final category = categoryController.allCategories[index];
                                return VerticalTextWidget(
                                  img: category.image,
                                  title: category.name,
                                  onTap: () => _onCategoryTap(index,category.name),
                                );
                              },
                            ),
                          );
                        }),SizedBox(height: kDeviceComponents.screenHeight(context)*0.021,),Obx(() => Text(
                          '${userController.user.value.role == 'Seller' ? 'Sell' : 'Buy'} the best handicrafts',style: Theme.of(context).textTheme.displayMedium?.copyWith(fontStyle: FontStyle.italic),
                        ))
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      }),
      bottomSheet: Obx(() {
        if (productController.isLoading.value) {
          return const SizedBox.shrink();
        }

        return BottomSheet(
          onClosing: () {},
          enableDrag: true,
          builder: (BuildContext context) {
            return BottomSheetContainer(
              height: kDeviceComponents.screenHeight(context)*0.35,
              child: CustomScrollView(
                slivers: [
                  // Filter section with constrained width
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSizes.largePadding,
                        vertical: kSizes.mediumPadding,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: kDeviceComponents.screenWidth(context) * 0.4,
                          child: const KFilter(),
                        ),
                      ),
                    ),
                  ),

                  // Product listing title
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: kSizes.largePadding),
                      child: ProductListingStructure(),
                    ),
                  ),

                  // Products grid
                  if (productController.products.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          // Different messages for search vs regular
                          productController.searchQuery.value.isEmpty
                              ? 'No products available'
                              : 'No products found for "${productController.searchQuery.value}"',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSizes.mediumPadding,
                        vertical: kSizes.smallPadding,
                      ),
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
                              if (index >= productController.products.length) {
                                return const SizedBox(); // or a fallback widget
                              }

                              final product = productController.products[index];

                              return GestureDetector(
                                onTap: () => Get.to(
                                      () => ProductDetail(product: product),
                                  transition: Transition.downToUp,
                                  duration: const Duration(milliseconds: 700),
                                ),
                                child: ProductCardVertical(
                                  productImagePath: product.productImages.isNotEmpty
                                      ? product.productImages[0]
                                      : 'assets/images/categories/stoneArt.png',
                                  isFavorite: userController.isProductFavorite(product.id),
                                  onFavoriteToggle: () => userController.toggleFavoriteProduct(product.id),
                                  productId: product.id,
                                  labelText: product.productName,
                                  priceText: product.productPrice,
                                  isBidding: product.isBiddable,
                                  rating: productController.averageRating.value,
                                  product: product,
                                ),
                              );
                            },
                            childCount: productController.products.length,
                          )

                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}