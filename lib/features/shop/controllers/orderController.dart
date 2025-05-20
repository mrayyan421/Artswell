// order_controller.dart
import 'dart:io';

import 'package:artswellfyp/data/repositories/userRepository/userRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:artswellfyp/features/shop/models/orderModel.dart';
import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/widgets/loaders/basicLoaders.dart';
import '../../../data/repositories/productRepository/orderRepository.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final  _authRepo = Get.put(AuthenticationRepository());
  final _userRepo=Get.put(UserRepository());
  final  _orderRepo = Get.put(OrderRepository());
  final Rx<File?> receiptImage = Rx<File?>(null);
  final RxString receiptImageUrl = ''.obs;
  final RxBool isUploading = false.obs;
  final isLoading = false.obs;
  final RxList<OrderModel> userOrders = <OrderModel>[].obs;


  Future<void> addToCart(OrderModel order) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      // Ensure all required fields are present
      final completeOrder = OrderModel(
        orderId: order.orderId,
        userId: userId,
        sellerId: order.sellerId,
        items: order.items,
        status: order.status,
        orderDate: order.orderDate,
        estimatedDelivery: order.estimatedDelivery,
        totalAmount: order.totalAmount,
        productImage: order.productImage,
        receiptImageUrl: order.receiptImageUrl,
      );

      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('cart')
          .doc(order.orderId)
          .set(completeOrder.toJson());

    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }
  /*Future<void> addToCart(OrderModel order) async {
    try {
      // 1. Validate user authentication
      final userId = _authRepo.authUser?.uid;
      if (userId == null) {
        throw 'User not authenticated. Please log in.';
      }

      // 2. Validate order data
      if (order.orderId.isEmpty || order.items.isEmpty) {
        throw 'Invalid order data';
      }

      // 3. Prepare Firestore batch
      final batch = _firestore.batch();

      // 4. Add/update cart document
      final cartRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('cart')
          .doc(order.orderId);

      batch.set(cartRef, {
        ...order.toJson(),
        'receiptImageUrl': '',
        'lastUpdated': FieldValue.serverTimestamp(), // Add timestamp for sorting
      }, SetOptions(merge: true)); // Merge to preserve existing fields if doc exists

      // 5. Update user's orderIds array
      final userRef = _firestore.collection('Users').doc(userId);
      batch.update(userRef, {
        'orderIds': FieldValue.arrayUnion([order.orderId]),
        'cartUpdatedAt': FieldValue.serverTimestamp(),
      });

      // 6. Commit batch
      await batch.commit();

      debugPrint('🛒 Cart updated successfully for user $userId');
    } on FirebaseException catch (e) {
      debugPrint('🔥 Firestore error: ${e.code} - ${e.message}');
      throw 'Failed to update cart. Please try again.';
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw 'Failed to add to cart. Please check your connection.';
    }
  }*/
  Future<void> loadUserOrders() async {
    try {
      isLoading(true);
      final userId = _authRepo.authUser?.uid;
      if (userId == null) return;

      final orderIds = await _getUserOrderIds(userId);
      if (orderIds.isEmpty) return;

      userOrders.value = await _getOrdersDetails(orderIds);
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to load orders');
    }finally{
      isLoading(false);
    }
  }
  Future<List<String>> _getUserOrderIds(String userId) async {
    final doc = await _firestore.collection('Users').doc(userId).get();
    return List<String>.from(doc.data()?['orderIds'] ?? []);
  }
  Future<List<OrderModel>> _getOrdersDetails(List<String> orderIds) async {
    final orders = <OrderModel>[];
    for (final id in orderIds) {
      final doc = await _firestore.collection('orders').doc(id).get();
      if (doc.exists) {
        orders.add(OrderModel.fromSnapshot(doc));
      }
    }
    return orders;
  }
  // Add these methods to your existing OrderController
  Future<void> createOrderFromCart({
    required List<OrderItem> items,
    required double totalAmount,
    required String productImage,
  }) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      // 1. Generate order ID
      final orderId = _firestore.collection('orders').doc().id;

      final firstProduct=await _firestore.collection('products').doc(items.first.productId).get();
      final sellerId=firstProduct.data()?['sellerId'] as String? ?? '';
      // 2. Create order model
      final order = OrderModel(
          orderId: orderId,
          userId: userId,
          items: items,
          status: 'paymentPending',
          orderDate: DateTime.now(),
          estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
          totalAmount: totalAmount,
          productImage: productImage,
          receiptImageUrl: '', sellerId:sellerId
      );

      // 3. Create order document
      await _orderRepo.createOrder(order);

      // 4. Clear cart (optional)
      await clearUserCart(userId);

      kLoaders.successSnackBar(
        title: 'Order Placed!',
        message: 'Your order has been created successfully',
      );
    } catch (e) {
      kLoaders.errorSnackBar(
        title: 'Order Failed',
        message: 'Failed to create order: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> updateCartItem({
    required String orderId,
    required OrderItem updatedItem,
    required String productImage,
  }) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      await _firestore
          .collection('Users')
          .doc(userId)
          .collection('cart')
          .doc(orderId)
          .update({
        'items': [updatedItem.toJson()],
        'totalAmount': updatedItem.price * updatedItem.quantity,
        'productImage': productImage,
      });
    } catch (e) {
      rethrow;
    }
  }
  Stream<List<OrderModel>> getCartItemsStream() {
    final userId = _authRepo.authUser?.uid;
    if (userId == null) throw 'User not authenticated';

    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('cart')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();

      // Safely parse with defaults
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      final imageUrl = items.isNotEmpty ? items[0]['imageUrl'] ?? '' : '';

      return OrderModel(
        orderId: doc.id,
        userId: data['userId'] ?? '', // Default empty string
        sellerId: data['sellerId'] ?? '', // Default empty string
        items: items.map((item) => OrderItem.fromJson(item)).toList(),
        status: data['status'] ?? 'pending', // Default status
        orderDate: DateTime.parse(data['orderDate'] ?? DateTime.now().toIso8601String()),
        estimatedDelivery: DateTime.parse(data['estimatedDelivery'] ??
            DateTime.now().add(const Duration(days: 7)).toIso8601String()),
        totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
        productImage: data['productImage'] ?? imageUrl,
        receiptImageUrl: data['receiptImageUrl'],
      );
    }).toList());
  }
  /*Stream<List<OrderModel>> getCartItemsStream() {
    final userId = _authRepo.authUser?.uid;
    if (userId == null) throw 'User not authenticated';

    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('cart')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      // Extract imageUrl from the first item in the items array
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      final imageUrl = items.isNotEmpty ? items[0]['imageUrl'] ?? '' : '';

      return OrderModel(
        orderId: doc.id,
        userId: data['userId'],
        items: items.map((item) => OrderItem.fromJson(item)).toList(),
        status: data['status'],
        orderDate: DateTime.parse(data['orderDate']),
        estimatedDelivery: DateTime.parse(data['estimatedDelivery']),
        totalAmount: data['totalAmount'],
        productImage: imageUrl,
        receiptImageUrl: data['receiptImageUrl'],
        sellerId: data['sellerId']
      );
    }).toList());
  }*/

  Future<List<CartItem>> _getUserCartItems(String userId) async {
    final snapshot = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('cart')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CartItem(
        productId: data['productId'],
        name: data['name'],
        quantity: data['quantity'],
        price: data['price'].toDouble(),
        imageUrl: data['imageUrl'],
      );
    }).toList();
  }
  Future<void> submitOrder(OrderModel order) async {
    try {
      // 1. Get seller ID from product
      final productDoc = await _firestore.collection('products').doc(order.orderId).get();
      final sellerId = productDoc['sellerId'] as String;

      // 2. Convert amount to string with 2 decimal places
      final amountString = order.totalAmount.toStringAsFixed(0);

      // 3. Update seller's document
      await _firestore.collection('users').doc(sellerId).update({
        'ordersPlaced': FieldValue.arrayUnion([amountString]),
        // 'totalSales': FieldValue.increment(order.grandTotal), // Optional
      });

      // 4. Save order document
      await _firestore.collection('orders').doc(order.orderId).set(order.toJson());

    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to process order');
    }
  }
  Future<void> submitReceipt(String orderId, double amount) async {
    try {
      // 1. Validate critical values
      final receiptFile = receiptImage.value;
      if (receiptFile == null) throw 'Please upload receipt first'; // Add null check

      isUploading(true);

      // 2. Validate user authentication
      final userId = _authRepo.authUser?.uid;
      if (userId == null || userId.isEmpty) throw 'User not authenticated';

      // 3. Get cart items
      final cartItems = await _getUserCartItems(userId);
      if (cartItems.isEmpty) throw 'Cart is empty';

      // 4. Get seller ID with null safety
      final firstProductId = cartItems.first.productId;
      final productDoc = await _firestore.collection('products').doc(firstProductId).get();
      final sellerId = productDoc.data()?['sellerId']?.toString() ?? ''; // Convert to string
      if (sellerId.isEmpty) throw 'Invalid seller information';

      // 5. Convert amount with safety
      final amountString = amount.toStringAsFixed(0); // Handle null case

      // 6. Update seller sales
      await _userRepo.addSaleToSeller(sellerId, amountString);

      final receiptUrl = await _orderRepo.uploadReceiptImage(
        orderId: orderId,
        imageFile: receiptFile,
        userId: userId,
      );
      if (receiptUrl.isEmpty) throw 'Failed to upload receipt';

      // Create order - now with required receiptImageUrl
      final order = OrderModel(
          orderId: orderId,
          userId: userId,
          items: cartItems.map((item) => item.toOrderItem()).toList(),
          status: 'paymentPendingVerification',
          orderDate: DateTime.now(),
          estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
          totalAmount: cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
          productImage: cartItems.isNotEmpty ? cartItems.first.imageUrl : '',
          receiptImageUrl: receiptUrl, // Now required
          sellerId: sellerId
      );

      // Save to all locations
      await _orderRepo.createCompleteOrder(
        userId: userId,
        order: order,
      );

      // Clear cart
      await clearUserCart(userId);

      isUploading(false);
    } catch (e) {
      isUploading(false);
      debugPrint('Order submission error: $e');
      rethrow;
    }
  }
  Future<String> getSellerPhoneNumber(String sellerId) async {
    try {
      final doc = await _firestore.collection('Users').doc(sellerId).get();
      return doc['phoneNumber']?.toString() ?? 'Phone not available';
    } catch (e) {
      debugPrint('Error fetching phone: $e');
      return 'Error loading phone';
    }
  }
  // ----------------------real---------------
  /*Future<void> submitReceipt(String orderId) async {
    try {
      if (receiptImage.value == null) {
        throw 'Please upload a receipt first';
      }

      isUploading(true);

      // 1. Get current user
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      // 2. Get cart items from User's cart subcollection
      final cartItems = await _getUserCartItems(userId);

      if (cartItems.isEmpty) {
        throw 'No items in cart to create order';
      }

      // 3. Upload receipt
      final receiptUrl = await _orderRepo.uploadReceiptImage(
        orderId: orderId,
        imageFile: receiptImage.value!,
        userId: userId,
      );

      // 4. Create order model with receipt
      final order = OrderModel(
        orderId: orderId,
        userId: userId,
        items: cartItems.map((item) => OrderItem(
          productId: item.productId,
          name: item.name,
          quantity: item.quantity,
          price: item.price,
          imageUrl: item.imageUrl,
        )).toList(),
        status: 'paymentPendingVerification',
        orderDate: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
        totalAmount: cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
        productImage: cartItems.isNotEmpty ? cartItems.first.imageUrl : '',
        receiptImageUrl: receiptUrl,
      );

      // 5. Create order
      await _orderRepo.createOrder(order);

      // 6. Clear cart
      await _clearUserCart(userId);

      isUploading(false);
    } catch (e) {
      isUploading(false);
      rethrow;
    }
  }*/
  Future<void> pickAndUploadReceipt(String orderId) async {
    try {
      isUploading(true);
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1200,
        maxWidth: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        receiptImage.value = File(pickedFile.path);

        // Upload receipt and get URL
        final receiptUrl = await _orderRepo.uploadReceiptImage(
          orderId: orderId,
          imageFile: receiptImage.value!,
          userId: userId,
        );

        // Store the URL in the cart document
        await _firestore
            .collection('Users')
            .doc(userId)
            .collection('cart')
            .doc(orderId)
            .update({
          'receiptImageUrl': receiptUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        receiptImageUrl.value = receiptUrl;
      }
    } catch (e) {
      debugPrint('Error uploading receipt: $e');
      throw 'Failed to upload receipt. Please try again.';
    } finally {
      isUploading(false);
    }
  }
  Future<void> clearUserCart(String userId) async {
    try {
      isLoading(true);
      // Get all documents from the user's cart subcollection
      final cartSnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('cart')
          .get();

      // Check if there are any documents to delete (excluding INIT)
      final docsToDelete = cartSnapshot.docs.where((doc) => doc.id != 'initial').toList();

      if (docsToDelete.isEmpty) {
        debugPrint('No cart items to clear for user $userId');
        return;
      }

      // Create a batch operation
      final batch = _firestore.batch();

      // Add delete operations for all documents except INIT
      for (final doc in docsToDelete) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('Cleared ${docsToDelete.length} cart items for user $userId (preserved INIT document)');
    } catch (e) {
      debugPrint('Error clearing cart for user $userId: $e');
      throw 'Failed to clear cart. Please try again.';
    }finally{
      isLoading(false);
    }
  }
}