
import 'package:cloud_firestore/cloud_firestore.dart';

//TODO: this Model class defines the UserModel, its properties, & formats them in json format

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String? phoneNumber;
   String? profilePic;
  final DateTime createdAt;
  final List<String> favoriteProductIds;
  final List<String> orderIds;
  final List<String> ordersPlaced;
  final String? shopName;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profilePic,
    required this.createdAt,
    this.favoriteProductIds = const [],
    this.orderIds = const [],
    this.ordersPlaced = const [],
    this.shopName='ArtsWell'
  });

  // Convert UserModel to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'profilePictureUrl': profilePic,
      'favoriteProductIds': favoriteProductIds,
      'orderIds': orderIds,
      'ordersPlaced': ordersPlaced,
      'shopName':shopName
    };
  }
  factory UserModel.empty() {
    return UserModel(
      uid: '',fullName: '',email: '',role: '',phoneNumber: '',createdAt: DateTime.now(),profilePic: '',favoriteProductIds: [],orderIds: [],shopName: '',ordersPlaced: []
    );
  }
  // Create UserModel from JSON
  /// Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        uid: document.id,
        fullName: data['fullName'] ?? '',
        email: data['email'] ?? '',
        role: data['role'],
        phoneNumber: data['phoneNumber'] ?? 'Phone Number',
        createdAt: DateTime.parse(data['createdAt']),
        profilePic: data['profilePictureUrl'] ?? '',
          favoriteProductIds: List<String>.from(data['favoriteProductIds'] ?? []),
          orderIds: List<String>.from(data['orderIds'] ?? []),
          ordersPlaced: List<String>.from(data['orderPlaced'] ?? []),
        shopName: data['shopName'] ?? 'ArtsWell'
      );
    } else {
      return UserModel.empty();
    }
  }
  // Method
  // k, to update favorites
  UserModel updateFavorites(List<String> newFavorites) {
    return UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      role: role,
      phoneNumber: phoneNumber,
      profilePic: profilePic,
      createdAt: createdAt,
      favoriteProductIds: newFavorites,
      orderIds: orderIds,
      ordersPlaced: ordersPlaced,
      shopName: shopName
    );
  }
  UserModel updateOrderIds(List<String> newOrderIds) {
    return UserModel(
      uid: uid,
      fullName: fullName,
      email: email,
      role: role,
      phoneNumber: phoneNumber,
      profilePic: profilePic,
      createdAt: createdAt,
      favoriteProductIds: favoriteProductIds,
      orderIds: newOrderIds,
      ordersPlaced: ordersPlaced,
      shopName: shopName
    );
  }
  // In your UserModel or ProductModel
  String? get safeImageUrl {
    if (profilePic!.contains('firebasestorage')) {
      return profilePic!.replaceAll(' ', '%20') // Encode spaces
          .replaceAll('&token=', '?token='); // Fix token param
    }
    return profilePic;
  }
}
