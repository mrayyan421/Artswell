import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../../../features/personalization/models/sellerStoryModel.dart';

class SellerStoryRepository extends GetxController {
  static SellerStoryRepository get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<SellerStoryModel> getSellerStory(String userId) async {
    final doc = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('seller_stories')
        .doc(userId)
        .get();
    return SellerStoryModel.fromFirestore(doc);
  }
  CollectionReference _sellerStoryCollection(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('seller_stories');
  }
  Future<void> initializeUserAddresses(String userId, String name, String? phoneNumber) async {
    try {
      final storyRef = _sellerStoryCollection(userId).doc('default_$userId');
      final doc = await storyRef.get();

      if (!doc.exists) {
        await storyRef.set({
          'id': 'default_$userId',
          'userId': userId,
          'name': name.isNotEmpty ? name : 'User',
          'phoneNumber': phoneNumber ?? '',
          'address': '',
          'postalCode': '',
          'state': '',
          'city': '',
          'country': '',
          'isDefault': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to initialize addresses: ${e.toString()}';
    }
  }

  Future<void> updateSellerStory(SellerStoryModel story) async {
    await _firestore
        .collection('Users')
        .doc(story.userId)
        .collection('seller_stories')
        .doc(story.userId)
        .update({
      'profileImageUrl': story.profileImageUrl,
      'successStory': story.successStory,
      'remarks': story.remarks,
      'shopDetails': story.shopDetails,
      'shopName':story.shopName,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    final ref = _storage.ref().child('Users/$userId/seller_stories/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
}