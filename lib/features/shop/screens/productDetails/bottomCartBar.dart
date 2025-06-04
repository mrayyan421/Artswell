import 'package:artswellfyp/features/personalization/controllers/addressController.dart';
import 'package:artswellfyp/features/shop/controllers/productController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:artswellfyp/common/widgets/circularIcon.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/features/shop/controllers/orderController.dart';
import 'package:artswellfyp/features/shop/models/orderModel.dart';
import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';

import '../../../../data/repositories/authenticationRepository/authenticationRepository.dart';

class kBottomAddToCart extends StatefulWidget {
  final String productId;
  final String productName;
  final double productPrice;

  const kBottomAddToCart({
    super.key,
    required this.productId,
    required this.productName,
    required this.productPrice,
  });

  @override
  State<kBottomAddToCart> createState() => _kBottomAddToCartState();
}

class _kBottomAddToCartState extends State<kBottomAddToCart> {
  int _itemCount = 0;
  final OrderController _orderController = Get.put(OrderController());
  final productController=Get.put(ProductController());


  void incrementItemCount() {
    setState(() {
      _itemCount++;
    });
  }

  void decrementItemCount() {
    if (_itemCount > 0) {
      setState(() {
        _itemCount--;
      });
    }
  }

  Future<void> _addToCart() async {
    try {
      // Check for valid item count
      if (_itemCount == 0) {
        kLoaders.warningSnackBar(
            title: 'No Items Selected',
            message: 'Please select at least one item to add to cart'
        );
        return;
      }

      // Verify user authentication
      final authUser = AuthenticationRepository.instance.authUser;
      if (authUser == null) {
        kLoaders.errorSnackBar(title: 'Error', message: 'Please login to add items to cart');
        return;
      }

      // Validate product data
      final product = productController.selectedProduct.value;
      if (product == null) {
        kLoaders.errorSnackBar(title: 'Error', message: 'Product information is not available');
        return;
      }

      if (product.productImages.isEmpty) {
        kLoaders.errorSnackBar(title: 'Error', message: 'Product images are not available');
        return;
      }

      // Get user's default address (where isDefault == true)
      final addressQuery = await FirebaseFirestore.instance
          .collection('Users')
          .doc(authUser.uid)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (addressQuery.docs.isEmpty) {
        kLoaders.warningSnackBar(
            title: 'Address Required',
            message: 'Please set a default address before adding to cart'
        );
        return;
      }

      final defaultAddress = addressQuery.docs.first.data();

      // Extract only the required fields and format as a string
      final addressString = _formatAddress(defaultAddress);

      // Create order item with address
      final orderItem = OrderItem(
          productId: product.id,
          name: product.productName,
          quantity: _itemCount,
          price: product.productPrice.toDouble(),
          imageUrl: product.productImages.first,
          address: addressString
      );

      // Create cart document with address
      final order = OrderModel(
          orderId: 'CART-${DateTime.now().millisecondsSinceEpoch}',
          userId: authUser.uid,
          items: [orderItem],
          status: 'In Cart',
          orderDate: DateTime.now(),
          estimatedDelivery: DateTime.now().add(const Duration(days: 5)),
          totalAmount: product.productPrice.toDouble() * _itemCount,
          productImage: product.productImages.first,
          receiptImageUrl: '',
          sellerId: product.sellerId,
          address: addressString
      );

      debugPrint('Adding to cart: ${order.toJson()}');

      // Add to cart
      await _orderController.addToCart(order);

      // Reset counter
      if (mounted) {
        setState(() => _itemCount = 0);
      }

      kLoaders.successSnackBar(
          title: 'Added to Cart',
          message: '${product.productName} added to your cart! To Check-out, tap on \'Buy now\' button'
      );
    } catch (e, stackTrace) {
      debugPrint('Add to cart error: $e\n$stackTrace');
      kLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to add to cart. Please try again.'
      );
    }
  }
  String _formatAddress(Map<String, dynamic> address) {
    return '${address['name'] ?? ''}\n'
        '${address['address'] ?? ''}\n'
        '${address['city'] ?? ''}, ${address['postalCode'] ?? ''}\n'
        '${address['country'] ?? ''}\n'
        'Phone: ${address['phone'] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSizes.mediumPadding,
        vertical: kSizes.mediumPadding / 2,
      ),
      decoration: const BoxDecoration(
        color: kColorConstants.klPrimaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(kSizes.mediumBorderRadius),
          topRight: Radius.circular(kSizes.mediumBorderRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              kCircularIcon(
                icon: 'assets/icons/remove.png',
                backgroundColor: kColorConstants.klGreyColor,
                width: 40,
                height: 40,
                color: kColorConstants.klAntiqueWhiteColor,
                onPressed: decrementItemCount,
              ),
              const SizedBox(width: kSizes.smallPadding),
              Text(
                '$_itemCount',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(width: kSizes.smallPadding),
              kCircularIcon(
                icon: 'assets/icons/add.png',
                backgroundColor: kColorConstants.klAntiqueWhiteColor,
                width: 40,
                height: 40,
                color: kColorConstants.klAntiqueWhiteColor,
                onPressed: incrementItemCount,
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: kColorConstants.klSecondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kSizes.largeBorderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: kSizes.mediumPadding,
                  vertical: kSizes.smallPadding),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ImageIcon(
                  AssetImage('assets/icons/cart.png'),
                  color: Colors.black,
                  size: 20,
                ),
                const SizedBox(width: kSizes.smallPadding / 2),
                Text(
                  'Add to Cart',
                  style: kAppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}