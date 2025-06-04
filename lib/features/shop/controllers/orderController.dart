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
import '../../../common/widgets/successScreen.dart';
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
  var totalSales = 0.obs;


  Future<void> addToCart(OrderModel order) async {
    try {
      final userId = _authRepo.authUser?.uid;
      final batch = _firestore.batch();
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
        receiptImageUrl: order.receiptImageUrl, address:order.address,
      );

      final userOrderRef = _firestore.collection('Users').doc(order.userId).collection('orders').doc(order.orderId);
      batch.set(userOrderRef, order.toJson());

      await _firestore.collection('Users').doc(userId).collection('cart').doc(order.orderId).set(completeOrder.toJson());
      
      if(order.orderId!=null){
        final sellerOrder=await _firestore.collection('Users').doc(order.sellerId).collection('orders').doc(order.orderId);
        batch.set(sellerOrder, completeOrder.toJson());
      }
      await batch.commit();

    } catch (e) {
      debugPrint('Error adding to cart: $e');
      rethrow;
    }
  }
  Future<void> calculateTotalSales(String sellerId) async {
    try {
      double total = 0.0;
      final querySnapshot = await _firestore
          .collection('Users')
          .doc(sellerId)
          .collection('orders')
          // .where('status', isEqualTo: 'Payment Confirmed')
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('totalAmount')) {
          total += (data['totalAmount']);
        }
      }

      totalSales.value = total.toInt();
    } catch (e) {
      debugPrint('Error calculating total sales: $e');
      totalSales.value = 0;
    }
  }

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

  Future<void> createOrderFromCart({
    required List<OrderItem> items,
    required double totalAmount,
    required String productImage,
  }) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      // 1. Generate order ID
      final orderId = _firestore.collection('Users').doc(userId).collection('orders').doc().id;

      final firstProduct = await _firestore.collection('products').doc(items.first.productId).get();
      final sellerId = firstProduct.data()?['sellerId'] as String? ?? '';
      final address=firstProduct.data()?['address']as String??'';

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
          receiptImageUrl: '',
          sellerId: sellerId,
          address:address

      );

      // 3. Create order documents in both subcollections using batch
      final batch = _firestore.batch();

      // Add to user's orders subcollection
      final userOrderRef = _firestore.collection('Users').doc(userId).collection('orders').doc(orderId);
      print('added to orders');
      batch.set(userOrderRef, order.toJson());

      // Add to user's cart subcollection as an order
      final cartOrderRef = _firestore.collection('Users').doc(userId).collection('cart').doc(orderId);
      print('added to cart');
      batch.set(cartOrderRef, order.toJson());

      // Update user's order metadata
      final userRef = _firestore.collection('Users').doc(userId);
      batch.update(userRef, {
        'orderIds': FieldValue.arrayUnion([orderId]),
        'ordersPlaced': FieldValue.increment(1),
        'lastOrderDate': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      await _firestore.collection('Users').doc(userId).collection('cart').where('isOrder', isEqualTo: false).get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

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
    required String newStatus, // Add new status parameter
  }) async {
    try {
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final batch = _firestore.batch();

      // 1. Update cart document (in user's cart subcollection)
      final cartRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('cart')
          .doc(orderId);
      batch.update(cartRef, {
        'items': [updatedItem.toJson()],
        'totalAmount': updatedItem.price * updatedItem.quantity,
        'productImage': productImage,
        'status': newStatus, // Update status in cart
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update order document (in user's orders subcollection)
      final orderRef = _firestore
          .collection('Users')
          .doc(userId)
          .collection('orders')
          .doc(orderId);

      final orderDoc = await orderRef.get();
      if (orderDoc.exists) {
        batch.update(orderRef, {
          'items': [updatedItem.toJson()],
          'totalAmount': updatedItem.price * updatedItem.quantity,
          'productImage': productImage,
          'status': newStatus, // Update status in user's orders
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. Update in seller's orders subcollection
      final cartDoc = await cartRef.get();
      final sellerId = cartDoc.data()?['sellerId'] as String?;
      if (sellerId != null && sellerId.isNotEmpty) {
        final sellerOrderRef = _firestore
            .collection('Users')
            .doc(sellerId)
            .collection('orders')
            .doc(orderId);

        final sellerOrderDoc = await sellerOrderRef.get();
        if (sellerOrderDoc.exists) {
          batch.update(sellerOrderRef, {
            'items': [updatedItem.toJson()],
            'totalAmount': updatedItem.price * updatedItem.quantity,
            'productImage': productImage,
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      debugPrint('Updated order $orderId with status: $newStatus '
          '(user: $userId, seller: $sellerId)');
    } catch (e) {
      debugPrint('Error updating cart item: $e');
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
        userId: data['userId'] ?? '',
        sellerId: data['sellerId'] ?? '',
        items: items.map((item) => OrderItem.fromJson(item)).toList(),
        status: data['status'] ?? 'pending',
        orderDate: DateTime.parse(data['orderDate'] ?? DateTime.now().toIso8601String()),
        estimatedDelivery: DateTime.parse(data['estimatedDelivery'] ??
            DateTime.now().add(const Duration(days: 7)).toIso8601String()),
        totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
        productImage: data['productImage'] ?? imageUrl,
        receiptImageUrl: data['receiptImageUrl'],
        address: data['address']
      );
    }).toList());
  }

  Stream<List<OrderModel>> getOrderItemsStream() {
    final userId = _authRepo.authUser?.uid;
    if (userId == null) throw 'User not authenticated';

    return _firestore.collection('Users').doc(userId).collection('orders').orderBy('orderDate', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();

      // Safely parse with defaults
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      final imageUrl = items.isNotEmpty ? items[0]['imageUrl'] ?? '' : '';

      return OrderModel(
          orderId: doc.id,
          userId: data['userId'] ?? '',
          sellerId: data['sellerId'] ?? '',
          items: items.map((item) => OrderItem.fromJson(item)).toList(),
          status: data['status'] ?? 'pending',
          orderDate: DateTime.parse(data['orderDate'] ?? DateTime.now().toIso8601String()),
          estimatedDelivery: DateTime.parse(data['estimatedDelivery'] ??
              DateTime.now().add(const Duration(days: 7)).toIso8601String()),
          totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
          productImage: data['productImage'] ?? imageUrl,
          receiptImageUrl: data['receiptImageUrl'],
          address: data['address']
      );
    }).toList());
  }

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
        address: data['address']
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
      if (receiptFile == null) throw 'Please upload receipt first';

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
      final sellerId = productDoc.data()?['sellerId']?.toString() ?? '';
      if (sellerId.isEmpty) throw 'Invalid seller information';

      // 5. Convert amount with safety
      final amountString = amount.toStringAsFixed(0);

      // 6. Update seller sales
      await _userRepo.addSaleToSeller(sellerId, amountString);

      // 7. Upload receipt image
      final receiptUrl = await _orderRepo.uploadReceiptImage(
        orderId: orderId,
        imageFile: receiptFile,
        userId: userId,
      );
      if (receiptUrl.isEmpty) throw 'Failed to upload receipt';

      // 8. Create batch operation for atomic updates
      final batch = _firestore.batch();

      // 9. Get references to all documents first
      final cartRef = _firestore.collection('Users').doc(userId).collection('cart').doc(orderId);

      final buyerOrderRef = _firestore.collection('Users').doc(userId).collection('orders').doc(orderId);

      final sellerOrderRef = _firestore.collection('Users').doc(sellerId).collection('orders').doc(orderId);

      // 10. Create the order model first
      final order = OrderModel(
        orderId: orderId,
        userId: userId,
        items: cartItems.map((item) => item.toOrderItem()).toList(),
        status: 'paymentPendingVerification',
        orderDate: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 7)),
        totalAmount: cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
        productImage: cartItems.isNotEmpty ? cartItems.first.imageUrl : '',
        receiptImageUrl: receiptUrl,
        sellerId: sellerId,
        address: cartItems.first.address,
      );

      // 11. Check and create documents if they don't exist
      final buyerOrderDoc = await buyerOrderRef.get();
      if (!buyerOrderDoc.exists) {
        batch.set(buyerOrderRef, order.toJson());
      } else {
        batch.update(buyerOrderRef, {
          'receiptImageUrl': receiptUrl,
          'status': 'paymentPendingVerification',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      final sellerOrderDoc = await sellerOrderRef.get();
      if (!sellerOrderDoc.exists) {
        batch.set(sellerOrderRef, order.toJson());
      } else {
        batch.update(sellerOrderRef, {
          'receiptImageUrl': receiptUrl,
          'status': 'paymentPendingVerification',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // 12. Always update cart document
      batch.update(cartRef, {
        'receiptImageUrl': receiptUrl,
        'status': 'paymentPendingVerification',
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // 13. Execute all updates atomically
      await batch.commit();

      // 14. Clear cart
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

        // Get the cart document to find sellerId
        final cartDoc = await _firestore.collection('Users').doc(userId).collection('cart').doc(orderId).get();

        if (!cartDoc.exists) throw 'Cart document not found';

        final sellerId = cartDoc.data()?['sellerId'] as String?;
        if (sellerId == null || sellerId.isEmpty) throw 'Seller information missing';

        // Create batch for atomic updates
        final batch = _firestore.batch();

        // 1. Update buyer's cart document
        final cartRef = _firestore.collection('Users').doc(userId).collection('cart').doc(orderId);
        batch.update(cartRef, {
          'receiptImageUrl': receiptUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
          'status': 'Payment Confirmed'
        });

        // 2. Update customer's orders document
        final buyerOrderRef = _firestore.collection('Users').doc(userId).collection('orders').doc(orderId);
        batch.update(buyerOrderRef, {
          'receiptImageUrl': receiptUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
          'status': 'Payment Confirmed'

        });

        // 3. Update seller's orders document
        final sellerOrderRef = _firestore.collection('Users').doc(sellerId).collection('orders').doc(orderId);
        batch.update(sellerOrderRef, {
          'receiptImageUrl': receiptUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
          'status': 'Payment Confirmed'

        });

        // Execute all updates atomically
        await batch.commit();

        receiptImageUrl.value = receiptUrl;
      }
    } catch (e) {
      debugPrint('Error uploading receipt: $e');
      throw 'Failed to upload receipt. Please try again.';
    } finally {
      isUploading(false);
    }
  }
  Future<void> dispatchAllOrders(List<OrderModel> orders) async {
    try {
      isLoading(true);
      final userId = _authRepo.authUser?.uid;
      if (userId == null) throw 'User not authenticated';

      // Filter only orders with receipts
      final ordersToDispatch = orders.where((order) =>
      order.receiptImageUrl != null &&
          order.receiptImageUrl!.isNotEmpty &&
          order.orderId != 'INIT'
      ).toList();

      if (ordersToDispatch.isEmpty) {
        throw 'No valid orders to dispatch';
      }

      final batch = _firestore.batch();

      for (final order in ordersToDispatch) {
        // 1. Update buyer's cart document
        final cartRef = _firestore.collection('Users').doc(order.userId).collection('cart').doc(order.orderId);
        batch.update(cartRef, {
          'status': 'Order Dispatched',
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // 2. Update buyer's orders document
        final buyerOrderRef = _firestore.collection('Users').doc(order.userId).collection('orders').doc(order.orderId);
        batch.update(buyerOrderRef, {
          'status': 'Order Dispatched',
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // 3. Update seller's orders document
        final sellerOrderRef = _firestore.collection('Users').doc(userId).collection('orders').doc(order.orderId);
        batch.update(sellerOrderRef, {
          'status': 'Order Dispatched',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('Dispatched ${ordersToDispatch.length} orders');
      Get.offAll(() => const SuccessScreen(
          subTitle: 'Started Processing',
          btnText: 'Order dispatched, Return to Home'
      ));
    } catch (e) {
      debugPrint('Error dispatching orders: $e');
      kLoaders.errorSnackBar(
          title: 'Error',
          message: e.toString()
      );
      rethrow;
    } finally {
      isLoading(false);
    }
  }
  Future<void> clearUserCart(String userId) async {
    try {
      isLoading(true);

      // Create a batch operation for all deletions
      final batch = _firestore.batch();

      // 1. Clear cart items (keeping INIT document)
      final cartSnapshot = await _firestore.collection('Users').doc(userId).collection('cart').get();

      final cartDocsToDelete = cartSnapshot.docs.where((doc) => doc.id != 'initial').toList();

      for (final doc in cartDocsToDelete) {
        batch.delete(doc.reference);
      }

      // 2. Clear orders subcollection (keeping INIT document)
      final ordersSnapshot = await _firestore.collection('Users').doc(userId).collection('orders').get();

      final ordersDocsToDelete = ordersSnapshot.docs.where((doc) => doc.id != 'initial').toList();

      for (final doc in ordersDocsToDelete) {
        batch.delete(doc.reference);
      }

      // Commit all deletions in a single batch operation
      await batch.commit();

      debugPrint('''Cleared user data for $userId:
                  - Removed ${cartDocsToDelete.length} cart items
                  - Removed ${ordersDocsToDelete.length} orders
                    (preserved INIT documents in both collections)
                 ''');
    } catch (e) {
      debugPrint('Error clearing user data for $userId: $e');
      throw 'Failed to clear user data. Please try again.';
    } finally {
      isLoading(false);
    }
  }
}