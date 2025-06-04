import 'package:artswellfyp/common/widgets/circularContainer.dart';
import 'package:artswellfyp/common/widgets/circularIcon.dart';
import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/features/shop/controllers/homeController.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/widgets/cartSkeleton/cartItem.dart';
import '../../../../common/widgets/loaders/basicLoaders.dart';
import '../../controllers/orderController.dart';
import '../../models/orderModel.dart';

class CartScreen extends StatelessWidget {
  final  _orderController = Get.put(OrderController());

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorConstants.klAntiqueWhiteColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Image.asset('assets/icons/leftArrow.png'),
        ),
        title: const Text('Cart'),
        centerTitle: true,
        backgroundColor: kColorConstants.klPrimaryColor,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderController.getCartItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          final cartItems = snapshot.data!;
          double subtotal = 0.0;
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            subtotal = snapshot.data!.fold(
              0.0,
                  (sum, item) => sum + (item.items.first.price * item.items.first.quantity),
            );
          }


          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kSizes.mediumPadding),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: kSizes.smallPadding),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final itemTotal = item.items.first.price * item.items.first.quantity;

                      if(item.receiptImageUrl!=null) {
                        return Column(
                        children: [
                          kCircularContainer(
                            backgroundColor: kColorConstants.klInactiveTrackColor,
                            width: null,
                            showBorder: true,
                            height: null,
                            padding: const EdgeInsets.all(kSizes.mediumBorderRadiusPadding),
                            child: kCartItem(
                              productName: item.items.first.name,
                              productImage: item.productImage,
                              price: item.items.first.price,
                              quantity: item.items.first.quantity,
                              productId: item.items.first.productId,
                              estimatedDelivery: item.estimatedDelivery.toString(),
                              address: item.address,
                              customerName: UserController.instance.user.value.fullName,
                              status: item.status,
                            ),
                          ),
                          const SizedBox(height: kSizes.smallestPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const SizedBox(width: 30),
                                  itemQuantityAddRemove(index, context, item),
                                ],
                              ),
                              Text(
                                'PKR ${itemTotal.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                      }
                    },
                  ),
                  const SizedBox(height: kSizes.smallPadding),
                  kCircularContainer(
                    padding: const EdgeInsets.all(kSizes.smallPadding),
                    backgroundColor: kColorConstants.klInactiveTrackColor,
                    width: null,
                    showBorder: true,
                    height: null,
                    child: // Replace the current button section with this:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Total Price: PKR ${subtotal.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: kSizes.smallPadding),
                        StreamBuilder<List<OrderModel>>(
                          stream: _orderController.getCartItemsStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const SizedBox();
                            }

                            final hasReceipt = snapshot.data!.any(
                                    (order) => order.receiptImageUrl?.isNotEmpty ?? false
                            );

                            if (!hasReceipt) {
                              return ElevatedButton(
                                onPressed: () => HomeController.instance.checkOutNavigation(),
                                child: const Text(
                                  'Proceed to Payment',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            // Get the first order with a receipt
                            final orderWithReceipt = snapshot.data!.firstWhere(
                                    (order) => order.receiptImageUrl?.isNotEmpty ?? false
                            );

                            return FutureBuilder<String>(
                              future: _orderController.getSellerPhoneNumber(orderWithReceipt.sellerId),
                              builder: (context, phoneSnapshot) {
                                return Column(
                                  children: [
                                    if (phoneSnapshot.hasData)Text('Contact Seller and provide Order information',textAlign: TextAlign.center,style: Theme.of(context).textTheme.displayMedium?.copyWith(fontStyle: FontStyle.italic,color: Colors.black),),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (phoneSnapshot.hasData) {
                                          _callSeller(phoneSnapshot.data!);
                                        }
                                      },
                                      child: Text(
                                        phoneSnapshot.hasData
                                            ? 'Contact Seller: ${phoneSnapshot.data}'
                                            : 'Loading...',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: kSizes.smallPadding),
                        ElevatedButton(
                          onPressed: () {
                            _showClearCartConfirmation(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kColorConstants.klSearchBarColor,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showClearCartConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to remove all Order History?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _orderController.clearUserCart(UserController.instance.user.value.uid);
      kLoaders.successSnackBar(title: 'Success', message: 'Order history cleared successfully');
    }
  }
  Widget itemQuantityAddRemove(int index, BuildContext context, OrderModel item) {
    // Check if receipt exists
    final hasReceipt = item.receiptImageUrl?.isNotEmpty ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!hasReceipt) ...[
          kCircularIcon(
            icon: 'assets/icons/remove.png',
            width: 38,
            height: 38,
            size: kSizes.mediumIcon,
            onPressed: () => _updateItemQuantity(index, item, -1),
          ),
          const SizedBox(width: kSizes.smallPadding),
          Text(
            '${item.items.first.quantity}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: kSizes.smallPadding),
          kCircularIcon(
            icon: 'assets/icons/add.png',
            width: 38,
            height: 38,
            size: kSizes.mediumIcon,
            onPressed: () => _updateItemQuantity(index, item, 1),
          ),
        ] else ...[
          const SizedBox(width: 38),
          const SizedBox(width: kSizes.smallPadding),
          const SizedBox(width: kSizes.smallPadding),
          const SizedBox(width: 38),
        ],
      ],
    );
  }

  // helper method to display seller's phone num
  void _callSeller(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      kLoaders.errorSnackBar(
          title: 'Error',
          message: 'Could not launch phone app'
      );
    }
  }

  Future<void> _updateItemQuantity(int index, OrderModel item, int change) async {
    try {
      final newQuantity = item.items.first.quantity + change;
      if (newQuantity < 1) return;

      final updatedItem = OrderItem(
        productId: item.items.first.productId,
        name: item.items.first.name,
        quantity: newQuantity,
        price: item.items.first.price,
        imageUrl: item.productImage,
        address: item.address
      );

      await _orderController.updateCartItem(
        newStatus: 'Payment Pending',
        orderId: item.orderId,
        updatedItem: updatedItem,
        productImage: item.productImage,
      );

      await CachedNetworkImage.evictFromCache(item.productImage);
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to update quantity');
    }
  }
}
