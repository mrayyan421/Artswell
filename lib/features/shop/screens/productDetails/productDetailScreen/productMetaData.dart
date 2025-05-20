import 'package:artswellfyp/features/shop/models/productModel.dart';
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productMetaData.dart' as _commentController;
import 'package:artswellfyp/features/shop/screens/productDetails/productDetailScreen/productNameText.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import '../../../../../common/widgets/loaders/basicLoaders.dart';
import '../../../../../utils/constants/colorConstants.dart';
import '../../../../../utils/constants/size.dart';
import '../../../../../utils/theme/theme.dart';
import '../../../controllers/productController.dart';

class kProductMetaData extends StatefulWidget {
  final ProductModel product;

  kProductMetaData({super.key,required this.product});

  @override
  State<kProductMetaData> createState() => _kProductMetaDataState();
}
@override
void dispose() {
  _commentController.dispose();
  // _userRating.close();
  // _isLoading.close();
  // super.dispose();
}
class _kProductMetaDataState extends State<kProductMetaData> {
  final String dummyTxt = 'This needs to be updated on product add';
  final String catDummyTxt = 'dummy categ';
  final productCtrl = Get.put(ProductController());



  @override
  Widget build(BuildContext context) {
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      productCtrl.refreshComments(product.id);
    });*/


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Price & Sale Price
        Row(
          children: [
            /// Sale Tag
            Container(
              decoration: BoxDecoration(
                color: kColorConstants.klSecondaryColor,
                borderRadius: BorderRadius.circular(kSizes.mediumBorderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: kSizes.mediumPadding,
                  vertical: kSizes.mediumPadding),
              child: Text(
                '25%',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .apply(color: Colors.black),
              ),
            ),
            const SizedBox(width: kSizes.mediumPadding),

            /// Price
            Text(
              'PKR ${widget.product.productPrice}',
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        const SizedBox(height: kSizes.mediumPadding / 1.5),

         Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            kProductTitleText(
              title: widget.product.productName,smallSize: true,
            ),
            TextButton(
              onPressed: () {
                // Navigate to product category
              },
              child: Text(widget.product.category),
            )
          ],
        ),

        const SizedBox(height: kSizes.mediumPadding / 3.9),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: kAppTheme.lightTheme.textTheme.displayLarge,
            ),
             ReadMoreText(
              widget.product.productDescription,
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Show More',
              trimExpandedText: 'Show less',
              lessStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kColorConstants.klErrorColor,
              ),
              moreStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kColorConstants.klSliderOverlayColor,
              ),
            ),

            const SizedBox(height: kSizes.mediumPadding / 1.5),
            const Divider(),

            // Display average rating if available
              if (widget.product.averageRating > 0)
                Row(
                  children: [
                    Text(
                      'Average Rating: ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    RatingBarIndicator(
                      rating: widget.product.averageRating,
                      itemBuilder: (context, index) => const ImageIcon(
                        AssetImage('assets/icons/ratingIconColored.png'),
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                    ),
                    Text(
                      ' (${widget.product.averageRating.toStringAsFixed(1)})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),


            // Comments Section with proper Obx implementation
// Replace your current Obx comments section with:
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .doc(widget.product.id)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: kSizes.mediumPadding),
                      Text(
                        "No comments yet",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  );
                }

                final comments = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'id': doc.id,
                    'comment': data['comment'] ?? '',
                    'userName': data['userName'] ?? 'Anonymous',
                    'rating': data['rating'] ?? 0.0,
                    'createdAt': data['createdAt'],
                  };
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Comments:",
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: kSizes.smallPadding),
                    ...comments.map((comment) => _buildCommentCard(context, comment)),
                  ],
                );
              },
            ),

            // Add Comment Button
            TextButton(
              onPressed: () => _showAddCommentDialog(context),
              child: const Text('Add Review'),
            ),
          ],
        ),
      ],
    );
  }

  // Extracted comment card widget for better readability
  Widget _buildCommentCard(BuildContext context, Map<String, dynamic> comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: kSizes.smallPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kSizes.mediumBorderRadius),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(kSizes.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Commenter Info and Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User Avatar (replace with actual user image if available)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: kColorConstants.klSecondaryColor.withOpacity(0.2),
                  child: Text(
                    comment['userName']?.toString().isNotEmpty == true
                        ? comment['userName'][0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: kColorConstants.klSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // User Name
                Expanded(
                  child: Text(
                    comment['userName']?.toString() ?? 'Anonymous',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Rating Stars
                RatingBarIndicator(
                  rating: (comment['rating'] as num?)?.toDouble() ?? 0.0,
                  itemBuilder: (context, index) =>  const ImageIcon(
                    AssetImage('assets/icons/ratingIconUnColored.png'),
                    color: kColorConstants.klSecondaryColor,
                  ),
                  itemCount: 5,
                  itemSize: 16.0,
                ),
              ],
            ),
            const SizedBox(height: kSizes.mediumPadding),

            // Comment Text
            Text(
              comment['comment'].toString() ,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: kSizes.mediumPadding),

            // Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const ImageIcon(
                  AssetImage('assets/icons/dob.png'),
                  size: 14,
                  color: kColorConstants.klGreyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(comment['createdAt']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: kColorConstants.klGreyColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return DateFormat('MMM d, yyyy • h:mm a').format(timestamp.toDate());
      } else if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return DateFormat('MMM d, yyyy • h:mm a').format(date);
      }
      return 'Recently';
    } catch (e) {
      return 'Recently';
    }
  }

  void _showAddCommentDialog(BuildContext context) {
    final commentController = TextEditingController();
    double userRating = 0.0;
    final isLoading = false.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Obx(() {
          return AlertDialog(
            title: const Text('Add Review'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rating Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Rating:'),
                      const SizedBox(height: 8),
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const ImageIcon(
                          AssetImage('assets/icons/ratingIconUnColored.png'),
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          userRating = rating;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Comment Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Review:'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: "Share your experience...",
                          border: const OutlineInputBorder(),
                          errorText: commentController.text.trim().isEmpty &&
                              isLoading.value
                              ? 'Please enter your review'
                              : null,
                        ),
                        maxLines: 5,
                        minLines: 3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () {
                  Navigator.pop(context);
                  commentController.dispose();
                },
                child: const Text('Cancel'),
              ),

              // Submit Button
              TextButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                  final comment = commentController.text.trim();
                  if (userRating == 0.0) {
                    kLoaders.errorSnackBar(
                      title: 'Rating Required',
                      message: 'Please select a star rating',
                    );
                    return;
                  }

                  if (comment.isEmpty) {
                    kLoaders.errorSnackBar(
                      title: 'Review Required',
                      message: 'Please write your review',
                    );
                    return;
                  }

                  isLoading.value = true;
                  try {
                    await productCtrl.addComment(
                      widget.product.id, // Using the widget's product directly
                      comment,
                      userRating,
                    );
                    kLoaders.successSnackBar(
                      title: 'Thank You!',
                      message: 'Your review has been submitted',
                    );
                    Navigator.pop(context);
                    commentController.dispose();
                  } catch (e) {
                    kLoaders.errorSnackBar(
                      title: 'Submission Failed',
                      message: 'Error: ${e.toString()}',
                    );
                  } finally {
                    isLoading.value = false;
                  }
                },
                child: isLoading.value
                    ? const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text(
                  'Submit Review',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
      },
    );

  }
}

