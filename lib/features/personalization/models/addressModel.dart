import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String address;
  final String postalCode;
  final String state;
  final String city;
  final String country;
  bool isDefault;
  final Timestamp createdAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.postalCode,
    required this.state,
    required this.city,
    required this.country,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'postalCode': postalCode,
      'state': state,
      'city': city,
      'country': country,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      postalCode: data['postalCode'] ?? '',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp),
    );
  }
}