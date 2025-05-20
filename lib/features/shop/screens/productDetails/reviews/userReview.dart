import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:artswellfyp/features/shop/controllers/productController.dart';
import '../../../../../utils/constants/size.dart';

class UserReviewCard extends StatelessWidget {
  final Map<String, dynamic> comment;
  final ProductController productCtrl = Get.put(ProductController());

  UserReviewCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final createdAt = comment['createdAt'] != null
        ? DateTime.parse(comment['createdAt'].toDate().toString())
        : DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: kSizes.mediumPadding),
      child: Padding(
        padding: const EdgeInsets.all(kSizes.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/icons/acct.png'),
                    ),
                    const SizedBox(width: kSizes.mediumPadding),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['userName'] ?? 'Anonymous',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                // if (comment['userId'] == UserController.instance.user.value.uid)
                  /*IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => productCtrl.deleteComment(
                        productCtrl.selectedProduct.value!.id,
                        comment['commentId']
                    ),
                  ),*/
              ],
            ),
            const SizedBox(height: kSizes.mediumPadding),

            // Comment Text
            Text(
              comment['text'] ?? 'No comment text',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}