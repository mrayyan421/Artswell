import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/features/shop/controllers/productController.dart';
import 'package:artswellfyp/features/shop/screens/cart/cart.dart';
import 'package:artswellfyp/features/shop/screens/favorite/favorite.dart';
import 'package:artswellfyp/features/shop/screens/home/home.dart';
import 'package:artswellfyp/features/shop/screens/store/shopScreen.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/theme/customThemes/textTheme.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/shop/controllers/orderController.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final productController = Get.put(ProductController());
    final ordeerController=Get.put(OrderController());

    return Scaffold(
      bottomNavigationBar: Obx(
            () => NavigationBar(
          backgroundColor: kColorConstants.klPrimaryColor,
          labelTextStyle: WidgetStatePropertyAll(
              kTextTheme.lightTextTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.w600
              )
          ),
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) {
            // Pre-load data when switching to HomeScreen
            if (index == 0) {
              productController.loadProducts();
            }
            controller.selectedIndex.value = index;
          },
              destinations: [
                const NavigationDestination(
                    icon: ImageIcon(AssetImage('assets/icons/home.png')),
                    label: 'Home'
                ),
                if(UserController.instance.user.value.role == 'Seller')
                  const NavigationDestination(
                      icon: ImageIcon(AssetImage('assets/icons/store.png')),
                      label: 'Shop'
                  ),
                const NavigationDestination(
                    icon: ImageIcon(AssetImage('assets/icons/bidding.png')),
                    label: 'Bidding'
                ),
                if(UserController.instance.user.value.role == 'Customer')
                  const NavigationDestination(
                      icon: ImageIcon(AssetImage('assets/icons/cart.png')),
                      label: 'Cart'
                  ),
                const NavigationDestination(
                    icon: ImageIcon(AssetImage('assets/icons/favorite.png')),
                    label: 'Favorites'
                ),
              ],
        ),
      ),
      body: Obx(() {
        // Show loading indicator only for HomeScreen while loading
        if ((controller.selectedIndex.value == 0 && productController.isLoading.value) ||
            (controller.selectedIndex.value == 3 && ordeerController.isLoading.value)) {
          return const Center(
            child: CircularProgressIndicator(
              color: kColorConstants.klPrimaryColor,
            ),
          );
        }
        return controller.screens[controller.selectedIndex.value];
      }),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final productController = Get.put(ProductController());

  List<Widget> get screens {
    final user = UserController.instance.user.value;
    if (user.role == 'Seller') {
      return [
        const HomeScreen(),
        ShopScreen(sellerId: user.uid,shopName: user.shopName,),
        _comingSoonWidget(), // Bidding for sellers
        const kFavoriteScreen(), // Favorites for sellers
        // _comingSoonWidget(), // Extra item if needed
      ];
    } else {
      // Customer screens
      return [
        const HomeScreen(),
        _comingSoonWidget(), // Bidding for customers
        CartScreen(), // Cart for customers
        const kFavoriteScreen(), // Favorites for customers
      ];
    }
  }

  Widget _comingSoonWidget() => Container(
    height: double.infinity,
    width: double.infinity,
    alignment: Alignment.center,
    child: Text('Coming Soon', style: kAppTheme.lightTheme.textTheme.titleLarge),
  );

  @override
  void onInit() {
    super.onInit();
    productController.loadProducts();
  }
}

