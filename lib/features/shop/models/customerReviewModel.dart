import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String userType;
  final String productId;
  final double rating;
  final String productReview;
  final DateTime datePublished;
  final String? sellerReply;
  final String? sellerName;
  final DateTime? sellerReplyDate;
  final List<Map<String, dynamic>> comments;

  CustomerReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userType,
    required this.productId,
    required this.rating,
    required this.productReview,
    required this.datePublished,
    this.sellerReply,
    this.sellerReplyDate,
    this.sellerName,
    this.comments= const []
  });

  factory CustomerReviewModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userType: data['userType'] ?? '',
      productId: data['productId'] ?? '',
      productReview: data['productReview'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      datePublished: (data['datePublished'] as Timestamp).toDate(),
      sellerReply: data['sellerReply'],
      sellerReplyDate: data['sellerReplyDate'] != null
          ? (data['sellerReplyDate'] as Timestamp).toDate()
          : null,
      sellerName: data['sellerName'],
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userType': userType,
    'productId': productId,
    'productReview': productReview,
    'rating': rating,
    'datePublished': datePublished,
    'sellerReply': sellerReply,
    'sellerReplyDate': sellerReplyDate,
    'sellerName': sellerName,
    'comments': comments,
  };
}
