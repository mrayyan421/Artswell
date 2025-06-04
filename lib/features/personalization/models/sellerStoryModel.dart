import 'package:cloud_firestore/cloud_firestore.dart';

class SellerStoryModel {
  final String? id;
  final String userId;
  String? profileImageUrl;
  String successStory;
  String remarks;
  String shopDetails;
  final Timestamp createdAt;
  Timestamp? updatedAt;
  final String shopName;

  SellerStoryModel({
    this.id,
    required this.userId,
    this.profileImageUrl,
    required this.successStory,
    required this.remarks,
    required this.shopDetails,
    required this.createdAt,
    this.updatedAt,
    required this.shopName
  });

  factory SellerStoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SellerStoryModel(
      id: doc.id,
      userId: data['userId'],
      profileImageUrl: data['profileImageUrl'],
      successStory: data['successStory'] ?? '',
      remarks: data['remarks'] ?? '',
      shopDetails: data['shopDetails'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
      shopName: data['shopName']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'profileImageUrl': profileImageUrl,
      'successStory': successStory,
      'remarks': remarks,
      'shopDetails': shopDetails,
      'createdAt': createdAt,
      'shopName':shopName,
      'updatedAt': updatedAt,
    };
  }
}