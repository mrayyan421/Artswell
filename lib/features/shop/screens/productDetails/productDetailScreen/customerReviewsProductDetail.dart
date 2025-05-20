import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/features/shop/controllers/productController.dart';
import '../../../../../utils/constants/size.dart';
import '../reviews/userReview.dart';

class kCustomerReviewsWidget extends StatelessWidget {
  final ProductController productCtrl = Get.find();

  kCustomerReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (productCtrl.productComments.isEmpty) {
        return const Column(
          children: [
            SizedBox(height: kSizes.mediumPadding),
            Text('No comments yet'),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kSizes.mediumPadding),
          Text(
            'Customer Comments (${productCtrl.productComments.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: kSizes.mediumPadding),
          ...productCtrl.productComments.map((comment) =>
              UserReviewCard(comment: comment)
          ),
        ],
      );
    });
  }
}