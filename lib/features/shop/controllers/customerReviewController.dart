// File: lib/features/shop/controllers/customerReviewController.dart
import 'package:get/get.dart';
import '../../../common/widgets/loaders/basicLoaders.dart';
import '../../../data/repositories/productRepository/customerReviewRepository.dart';
import '../../personalization/controllers/userController.dart';
import '../models/customerReviewModel.dart';

class CustomerReviewController extends GetxController {
  static CustomerReviewController get instance => Get.find();
  final _repo = CustomerReviewRepository();
  final _userCtrl = Get.put(UserController());

  final RxList<CustomerReviewModel> reviews = <CustomerReviewModel>[].obs;
  final RxInt reviewCount = 0.obs;

  Future<void> addComment(String productId, String comment) async {
    try {
      final user = _userCtrl.user.value;
      if (user.uid.isEmpty) throw 'User not authenticated';

      // Create new review document if none exists
      if (reviews.isEmpty) {
        await _repo.createReview(
          productId: productId,
          userId: user.uid,
          userName: user.fullName,
          comment: comment,
          rating: 0, // Default rating for comment-only
        );
      } else {
        // Add comment to existing review
        await _repo.addCommentToReview(
          reviewId: reviews.first.id,
          comment: comment,
          userId: user.uid,
          userName: user.fullName,
        );
      }

      await fetchProductReviews(productId);
      kLoaders.successSnackBar(title: 'Success', message: 'Comment added!');
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> fetchProductReviews(String productId) async {
    try {
      reviews.value = await _repo.getReviewsForProduct(productId);
      reviewCount.value = reviews.length;
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }
}