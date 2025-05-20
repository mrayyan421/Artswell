import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:artswellfyp/features/shop/models/orderModel.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Creates an order in both the main orders collection and user's subcollection atomically
  Future<void> createOrder(OrderModel order) async {
    try {
      final batch = _firestore.batch();

      // 1. Add to main orders collection
      final orderRef = _firestore.collection('orders').doc(order.orderId);
      batch.set(orderRef, order.toJson());

      // 2. Add to user's orders subcollection
      final userOrderRef = _firestore
          .collection('Users')
          .doc(order.userId)
          .collection('orders')
          .doc(order.orderId);
      batch.set(userOrderRef, order.toJson());

      // 3. Update user's order metadata
      final userRef = _firestore.collection('Users').doc(order.userId);
      batch.update(userRef, {
        'orderIds': FieldValue.arrayUnion([order.orderId]),
        'ordersPlaced': FieldValue.increment(1),
        'lastOrderDate': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      debugPrint('✅ Order ${order.orderId} created successfully for user ${order.userId}');
    } on FirebaseException catch (e) {
      debugPrint('🔥 Firestore error creating order: ${e.code} - ${e.message}');
      throw 'Failed to create order. Please try again.';
    } catch (e) {
      debugPrint('❌ Unexpected error creating order: $e');
      throw 'Order creation failed. Please check your connection.';
    }
  }

  /// Gets a real-time stream of orders for a specific user
  Stream<List<OrderModel>> getOrdersForUser(String userId) {
    try {
      return _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .snapshots()
          .handleError((error) {
        debugPrint('Error streaming orders: $error');
        throw 'Failed to load orders. Please try again.';
      })
          .map((snapshot) => snapshot.docs
          .map((doc) => OrderModel.fromSnapshot(doc))
          .toList());
    } catch (e) {
      debugPrint('Error setting up orders stream: $e');
      rethrow;
    }
  }

  /// Updates the status of an existing order
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Update main order document
        final orderRef = _firestore.collection('orders').doc(orderId);
        transaction.update(orderRef, {'status': newStatus});

        // Also update in user's subcollection if exists
        final doc = await orderRef.get();
        if (doc.exists) {
          final userId = doc.data()!['userId'];
          final userOrderRef = _firestore
              .collection('Users')
              .doc(userId)
              .collection('orders')
              .doc(orderId);
          transaction.update(userOrderRef, {'status': newStatus});
        }
      });
      debugPrint('🔄 Updated order $orderId status to $newStatus');
    } on FirebaseException catch (e) {
      debugPrint('Error updating order status: ${e.code} - ${e.message}');
      throw 'Failed to update order status.';
    }
  }
// In your uploadReceiptImage method (OrderRepository)
  Future<String> uploadReceiptImage({
    required String orderId,
    required File imageFile,
    required String userId,
  }) async {
    try {
      final ref = FirebaseStorage.instance
          .ref('order_receipts/$userId/$orderId-${DateTime.now().millisecondsSinceEpoch}');

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      if (url.isEmpty) throw 'Empty download URL';
      return url;
    } on FirebaseException catch (e) {
      throw 'Upload failed: ${e.code}';
    }
  }
  /// Uploads a receipt image and returns its download URL
  /*Future<String> uploadReceiptImage({
    required String orderId,
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Generate unique filename with order context
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = imageFile.path.split('.').last;
      final fileName = 'receipt_${orderId}_$timestamp.${ext == 'jpg' ? 'jpeg' : ext}';

      // Configure upload metadata
      final metadata = SettableMetadata(
        contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}',
        customMetadata: {
          'uploadedBy': userId,
          'orderId': orderId,
          'uploadedAt': timestamp.toString(),
        },
      );

      // Create storage reference
      final ref = _storage.ref()
          .child('order_receipts/$userId/$fileName');

      // Upload with progress monitoring
      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('📸 Receipt uploaded for order $orderId: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('🔥 Storage error uploading receipt: ${e.code} - ${e.message}');
      throw 'Receipt upload failed. Please try again.';
    } catch (e) {
      debugPrint('Error uploading receipt: $e');
      throw 'Could not upload receipt. Please check the file and try again.';
    }
  }*/
  Future<void> createOrderInUserSubcollection({
    required String userId,
    required OrderModel order,
  }) async {
    await _firestore
        .collection('Users')
        .doc(userId)
        .collection('orders')
        .doc(order.orderId)
        .set(order.toJson());
  }
  Future<void> createOrderInMainCollection({
    required OrderModel order,
  }) async {
    await _firestore
        .collection('orders')
        .doc(order.orderId)
        .set(order.toJson());
  }
  Future<void> createCompleteOrderWithUserUpdate({
    required String userId,
    required OrderModel order,
  }) async {
    final batch = _firestore.batch();

    // // 1. Main orders collection
    // final orderRef = _firestore.collection('orders').doc(order.orderId);
    // batch.set(orderRef, order.toJson());

    // 2. User's orders subcollection
    final userOrderRef = _firestore
        .collection('Users')
        .doc(userId)
        .collection('orders')
        .doc(order.orderId);
    batch.set(userOrderRef, order.toJson());

    // 3. Update user document (critical change)
    final userRef = _firestore.collection('Users').doc(userId);
    batch.update(userRef, {
      'ordersPlaced': FieldValue.arrayUnion([{
        'orderId': order.orderId,
        'receipImageUrl': order.receiptImageUrl,
        'orderDate': order.orderDate.toIso8601String(),
        'status': order.status,
      }]),
    });

    await batch.commit();
  }
  ///To create comp new order doc
  Future<void> createCompleteOrder({
    required String userId,
    required OrderModel order,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Main orders collection
      final orderRef = _firestore.collection('orders').doc(order.orderId);
      batch.set(orderRef, order.toJson());

      // 2. User's orders subcollection
      final userOrderRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('orders')
          .doc(order.orderId);
      batch.set(userOrderRef, order.toJson());

      // 3. Update user's ordersPlaced array (critical change)
      final userRef = _firestore.collection('Users').doc(userId);
      batch.update(userRef, {
        'ordersPlaced': FieldValue.arrayUnion([order.toMinimalJson()]),
      });

      await batch.commit();
      debugPrint('✅ Order created in all locations');
    } catch (e) {
      debugPrint('❌ Error creating complete order: $e');
      rethrow;
    }
  }
}