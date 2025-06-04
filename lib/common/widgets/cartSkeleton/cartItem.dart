import 'package:artswellfyp/common/widgets/commonWidgets/roundedImagePromotion.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productNameText.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:flutter/material.dart';

import '../../../features/personalization/controllers/userController.dart';

class kCartItem extends StatelessWidget {
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String productId;
  final String estimatedDelivery;
  final String address;
  final bool? paymentConfirmation;
  final String customerName;
  final String status;

  const kCartItem({
    super.key,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.productId,
    required this.estimatedDelivery,
    this.paymentConfirmation=false,
    required this.address,
    required this.customerName,
    required this.status
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kColorConstants.klAntiqueWhiteColor,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: kSizes.smallPadding,
              bottom: kSizes.smallPadding,
            ),
            child: RoundedImagePromotion(
              img: productImage,
              width: 60,
              height: 60,
              borderRadius: BorderRadius.circular(kSizes.mediumBorderRadius),
            ),
          ),
          const SizedBox(width: kSizes.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: kProductTitleText(
                    title: productName,
                    maxLines: 1,
                  ),
                ),
                Text(
                  status == 'Order Dispatched'
                      ? 'Order Dispatched'
                      : (paymentConfirmation == true ? 'Payment Confirmed' : 'Pending Payment'),
                  style: TextStyle(
                    color: status == 'Order Dispatched'
                        ? kColorConstants.klSecondaryColor
                        : (paymentConfirmation == true ? kColorConstants.klVisitStoreElevationBtnClr : kColorConstants.klOrangeColor),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// Attributes - Now showing price and quantity
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'PKR ${price.toStringAsFixed(2)} • ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: 'Qty: $quantity • ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      TextSpan(
                        text: 'Address: $address • ',
                        style: Theme.of(context).textTheme.bodySmall, //TODO: REMOVE AFTER TESTING
                      ),
                      if (UserController.instance.user.value.role == 'Customer')
                        TextSpan(
                            text: 'Estimated delivery: $estimatedDelivery',
                            style: Theme.of(context).textTheme.bodySmall
                        )
                      else
                        TextSpan(
                            text: 'Customer: $customerName',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)
                        )
                    ],
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