import 'package:artswellfyp/common/widgets/commonWidgets/divider.dart';
import 'package:artswellfyp/common/widgets/customizedShapes/searchBarContainer.dart';
import 'package:artswellfyp/common/widgets/successScreen.dart';
import 'package:artswellfyp/features/shop/controllers/orderController.dart';
import 'package:artswellfyp/features/shop/screens/checkOut/billingAddress.dart';
import 'package:artswellfyp/features/shop/screens/checkOut/billingAmounts.dart';
import 'package:artswellfyp/features/shop/screens/checkOut/billingPayments.dart';
import 'package:artswellfyp/features/shop/screens/checkOut/checkOutMain/payoutScreens/easyPaisaPayment.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/cartSkeleton/cartItem.dart';
import '../../../../../common/widgets/circularContainer.dart';
import '../../../../../utils/constants/colorConstants.dart';
import '../../../models/orderModel.dart';

class CheckoutScreen extends StatelessWidget {
  final OrderController _orderController = Get.find();
  final RxDouble grandTotal = 0.0.obs;
  final RxString selectedPaymentMethod = 'Debit/Credit Card'.obs;
  final RxString selectedPaymentIcon = 'assets/icons/visa.png'.obs;

  CheckoutScreen({super.key});

  void _showPaymentMethodsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Payment Method'),
          content: SizedBox(
            width: double.maxFinite,
            height: kDeviceComponents.screenHeight(context) / 2,
            child: ListView(
              children: [
                ListTile(
                  leading: Image.asset('assets/icons/visa.png', width: 40),
                  title: const Text('Debit/Credit Card'),
                  onTap: () {
                    selectedPaymentMethod.value = 'Debit/Credit Card';
                    selectedPaymentIcon.value = 'assets/icons/visa.png';
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/icons/easyPaisa.png', width: 40),
                  title: const Text('EasyPaisa/JazzCash'),
                  onTap: () {
                    selectedPaymentMethod.value = 'EasyPaisa/JazzCash';
                    selectedPaymentIcon.value = 'assets/icons/easyPaisa.png';
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Image.asset('assets/icons/cod.png', width: 40),
                  title: const Text('Cash on Delivery'),
                  onTap: () {
                    selectedPaymentMethod.value = 'Cash on Delivery';
                    selectedPaymentIcon.value = 'assets/icons/cod.png';
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: Get.back,
          child: Image.asset('assets/icons/leftArrow.png'),
        ),
        title: const Text('CheckOut'),
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
          final orderId = cartItems.first.orderId; // Get order ID from first item
          final subtotal = cartItems.fold(0, (sum, item) => sum + item.totalAmount.toInt());

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(kSizes.mediumPadding),
              child: Column(
                children: [
                  // Items in Cart
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: kSizes.smallPadding),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return kCircularContainer(
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
                          // estimatedDelivery: item.estimatedDelivery.toString(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: kSizes.mediumPadding),

                  // Coupon TextField
                  kCircularContainer(
                    showBorder: true,
                    padding: const EdgeInsets.only(
                      top: kSizes.smallPadding,
                      bottom: kSizes.smallPadding,
                      right: kSizes.smallPadding,
                      left: kSizes.mediumPadding,
                    ),
                    backgroundColor: kColorConstants.klSearchBarColor,
                    width: null,
                    height: null,
                    child: Row(
                      children: [
                        Expanded(
                          child: SearchContainer(
                            text: 'Promo code here',
                            iconImg: 'assets/icons/phoneNo.png',
                            width: kDeviceComponents.screenWidth(context),
                          ),
                        ),
                        const SizedBox(width: kSizes.smallPadding),
                        SizedBox(
                          width: 99,
                          child: ElevatedButton(
                            onPressed: () {
                              // reduce price logic upon apply coupon
                            },
                            child: Text(
                              'Apply',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kSizes.mediumPadding),

                  // Order Summary Section
                  kCircularContainer(
                    padding: const EdgeInsets.all(kSizes.mediumPadding),
                    backgroundColor: kColorConstants.klAntiqueWhiteColor,
                    width: null,
                    showBorder: true,
                    height: null,
                    child: Column(
                      children: [
                        kBillingAmounts(
                          totalAmount: subtotal.toDouble(),
                          onGrandTotalCalculated: (total) => grandTotal.value = total,
                        ),
                        const SizedBox(height: kSizes.mediumPadding),
                        const AppDivider(thickness: 1, indent: 40, endIndent: 40),
                        Obx(() => kBillingPaymentsSection(
                          selectedPaymentMethod: selectedPaymentMethod.value,
                          selectedPaymentIcon: selectedPaymentIcon.value,
                          onChanged: () => _showPaymentMethodsDialog(context),
                        )),
                        kBillingAddressSection(),
                        Obx(() => ElevatedButton(
                          onPressed: () {
                            if (selectedPaymentMethod.value == 'EasyPaisa/JazzCash') {
                              Get.to(() => EasyPaisaUploadReceiptScreen(orderId: orderId,amount: grandTotal.value,));
                            } else {
                              Get.to(const SuccessScreen(
                                subTitle: 'Order Placed!',
                                btnText: '<- Let\'s get back',
                              ));
                            }
                          },
                          child: Text('Make Payment PKR ${grandTotal.value.toStringAsFixed(2)}'),
                        )),
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
}