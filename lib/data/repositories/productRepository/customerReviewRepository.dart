// File: lib/data/repositories/customerReviewRepository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/shop/models/customerReviewModel.dart';

class CustomerReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<CustomerReviewModel>> getReviewsForProduct(String productId) async {
    final snapshot = await _db.collection('CustomerReviews')
        .where('productId', isEqualTo: productId)
        .get();
    return snapshot.docs.map((doc) => CustomerReviewModel.fromSnapshot(doc)).toList();
  }

  Future<void> addCommentToReview({
    required String reviewId,
    required String comment,
    required String userId,
    required String userName,
  }) async {
    await _db.collection('CustomerReviews').doc(reviewId).update({
      'comments': FieldValue.arrayUnion([{
        'text': comment,
        'userId': userId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp()
      }])
    });
  }

  Future<void> createReview({
    required String productId,
    required String userId,
    required String userName,
    required String comment,
    required double rating,
  }) async {
    await _db.collection('CustomerReviews').add({
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comments': [{
        'text': comment,
        'userId': userId,
        'userName': userName,
        'timestamp': FieldValue.serverTimestamp()
      }],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}