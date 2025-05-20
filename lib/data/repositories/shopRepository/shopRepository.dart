import 'package:cloud_firestore/cloud_firestore.dart';

class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getShopName(String sellerId) async {
    final doc = await _firestore.collection('users').doc(sellerId).get();
    return doc['shopName'] ?? 'ArtsWell';
  }

  Future<void> updateShopName(String sellerId, String newShopName) async {
    await _firestore.collection('users').doc(sellerId).update({
      'shopName': newShopName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}