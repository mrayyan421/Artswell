import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/productRepository/transactionRepository.dart';
import '../../../utils/constants/enumerations.dart';
import '../models/transactionModel.dart';

class TransactionController extends GetxController {
  static TransactionController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _transactionRepo = Get.put(TransactionRepository());
  final selectedPaymentMethod = TransactionType.cashOnDelivery.obs;
  final isLoading = false.obs;
  final RxString receiptImageUrl = ''.obs;

  // Main payment processing function
  Future<String> processPayment({
    required String userId,
    required double amount,
    String? paymentDetails,
  }) async {
    try {
      isLoading(true);

      // 1. Get the user's cart to extract orderId
      final cartDoc = await _getUserCart(userId);
      final orderId = cartDoc['orderId'] as String;

      // 2. Create transaction record
      final transaction = TransactionModel(
        id: '',
        userId: userId,
        orderId: orderId,
        amount: amount,
        type: selectedPaymentMethod.value,
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
        paymentDetails: paymentDetails,
      );

      // 3. Process payment based on type
      String transactionId;
      switch (selectedPaymentMethod.value) {
        case TransactionType.card:
          transactionId = await _processCardPayment(transaction);
          break;
        case TransactionType.bankTransfer:
          transactionId = await _processBankTransfer(transaction);
          break;
        case TransactionType.easyPaisaPayment:
          transactionId = await _processEasyPaisaPayment(transaction);
          break;
        case TransactionType.cashOnDelivery:
          transactionId = await _processCashOnDelivery(transaction);
          break;
      }

      return transactionId;
    } catch (e) {
      throw 'Payment processing failed: $e';
    } finally {
      isLoading(false);
    }
  }

  // Helper to get user's cart document
  Future<DocumentSnapshot> _getUserCart(String userId) async {
    final cartSnapshot = await _db
        .collection('Users')
        .doc(userId)
        .collection('cart')
        .limit(1)
        .get();
    if (cartSnapshot.docs.isEmpty) {
      throw 'User cart not found';
    }
    return cartSnapshot.docs.first;
  }

  // Payment type handlers
  Future<String> _processCardPayment(TransactionModel transaction) async {
    final transactionId = await _transactionRepo.createTransaction(transaction);
    await Future.delayed(const Duration(seconds: 2)); // Simulate processing
    await _transactionRepo.updateTransactionStatus(
      transactionId: transactionId,
      status: TransactionStatus.completed,
    );
    await _sendBuyerConfirmation(transactionId);
    return transactionId;
  }

  Future<String> _processBankTransfer(TransactionModel transaction) async {
    final transactionId = await _transactionRepo.createTransaction(transaction);
    return transactionId;
  }

  Future<String> _processEasyPaisaPayment(TransactionModel transaction) async {
    try {
      final transactionWithStatus = TransactionModel(
        id: '',
        userId: transaction.userId,
        orderId: transaction.orderId,
        amount: transaction.amount,
        type: transaction.type,
        status: TransactionStatus.pending,
        createdAt: transaction.createdAt,
        paymentDetails: transaction.paymentDetails,
      );

      final transactionId = await _transactionRepo.createTransaction(transactionWithStatus);
      return transactionId;
    } catch (e) {
      debugPrint('EasyPaisa payment error: $e');
      rethrow;
    }
  }


  Future<String> _processCashOnDelivery(TransactionModel transaction) async {
    try {
      final transactionWithStatus = TransactionModel(
        id: '',
        userId: transaction.userId,
        orderId: transaction.orderId,
        amount: transaction.amount,
        type: transaction.type,
        status: TransactionStatus.pending,
        createdAt: transaction.createdAt,
        paymentDetails: transaction.paymentDetails,
      );

      final transactionId = await _transactionRepo.createTransaction(transactionWithStatus);
      await _updateOrderStatus(transaction.orderId, 'pending');
      await _sendSellerNotification(transaction.orderId);
      return transactionId;
    } catch (e) {
      debugPrint('Cash on Delivery error: $e');
      rethrow;
    }
  }

  // Receipt handling
  Future<String> uploadPaymentReceipt(XFile imageFile) async {
    try {
      isLoading(true);
      final receiptUrl = await _uploadReceiptImage(imageFile);
      receiptImageUrl.value = receiptUrl;
      return receiptUrl;
    } catch (e) {
      throw 'Failed to upload receipt: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<String> _uploadReceiptImage(XFile image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('payment_receipts')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putData(await image.readAsBytes());
      return await ref.getDownloadURL();
    } catch (e) {
      throw 'Failed to upload receipt: $e';
    }
  }

  // Order status updates
  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({'status': status});
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  Future<void> sendTestEmail() async {
    await FirebaseFirestore.instance.collection('mail').add({
      'to': 'fproject219@gmail.com',
      'message': {
        'subject': 'Test Order #123',
        'html': '''
        <h1>Test Notification</h1>
        <p>This is a test email from Firebase Functions!</p>
      '''
      }
    });
  }
  // Notification system
  Future<void> _sendSellerNotification(String orderId) async {
    try {
      // 1. Get order details
      final orderDoc = await _db.collection('orders').doc(orderId).get();
      final sellerId = orderDoc['sellerId'];

      // 2. Get seller email
      final sellerDoc = await _db.collection('Users').doc(sellerId).get();
      final sellerEmail = sellerDoc['email'];

      // 3. Trigger Cloud Function to send email
      await _db.collection('mail').add({
        'to': sellerEmail,
        'message': {
          'subject': 'New Order Received - ${orderDoc['orderNumber']}',
          'text': 'You have a new order that requires your attention.',
          'html': '''
            <h1>New Order Notification</h1>
            <p>Order ID: ${orderDoc.id}</p>
            <p>Amount: ${orderDoc['totalAmount']}</p>
            <p>Please review the order in your seller dashboard.</p>
          ''',
        }
      });
    } catch (e) {
      debugPrint('Failed to send seller notification: $e');
    }
  }

  Future<void> _sendBuyerConfirmation(String transactionId) async {
    try {
      // 1. Get transaction details
      final transaction = await _transactionRepo.getTransaction(transactionId);

      // 2. Get buyer details
      final buyerDoc = await _db.collection('Users').doc(transaction.userId).get();
      final buyerEmail = buyerDoc['email'];

      // 3. Get order details
      final orderDoc = await _db.collection('orders').doc(transaction.orderId).get();

      // 4. Trigger Cloud Function to send email
      await _db.collection('mail').add({
        'to': buyerEmail,
        'message': {
          'subject': 'Order Confirmed - ${orderDoc['orderNumber']}',
          'text': 'Your payment has been processed successfully.',
          'html': '''
            <h1>Order Confirmation</h1>
            <p>Order ID: ${orderDoc.id}</p>
            <p>Amount: ${transaction.amount}</p>
            <p>Thank you for your purchase!</p>
          ''',
        }
      });
    } catch (e) {
      debugPrint('Failed to send buyer confirmation: $e');
    }
  }

  Future<void> _sendBuyerRejection(String transactionId) async {
    try {
      // Similar to _sendBuyerConfirmation but with rejection message
      final transaction = await _transactionRepo.getTransaction(transactionId);
      final buyerDoc = await _db.collection('Users').doc(transaction.userId).get();

      await _db.collection('mail').add({
        'to': buyerDoc['email'],
        'message': {
          'subject': 'Payment Verification Failed',
          'text': 'We couldn\'t verify your payment.',
          'html': '''
            <h1>Payment Issue</h1>
            <p>Please contact support with your transaction ID: $transactionId</p>
          ''',
        }
      });
    } catch (e) {
      debugPrint('Failed to send buyer rejection: $e');
    }
  }

  // Seller approval functions
  Future<void> approveTransaction(String transactionId) async {
    try {
      isLoading(true);
      // 1. Update transaction status
      await _transactionRepo.updateTransactionStatus(
        transactionId: transactionId,
        status: TransactionStatus.completed,
      );

      // 2. Get order ID from transaction
      final transaction = await _transactionRepo.getTransaction(transactionId);

      // 3. Update order status
      await _updateOrderStatus(transaction.orderId, 'processing');

      // 4. Notify buyer
      await _sendBuyerConfirmation(transactionId);

    } catch (e) {
      throw 'Failed to approve transaction: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<void> rejectTransaction(String transactionId) async {
    try {
      isLoading(true);
      await _transactionRepo.updateTransactionStatus(
        transactionId: transactionId,
        status: TransactionStatus.failed,
      );

      final transaction = await _transactionRepo.getTransaction(transactionId);
      await _updateOrderStatus(transaction.orderId, 'cancelled');
      await _sendBuyerRejection(transactionId);

    } catch (e) {
      throw 'Failed to reject transaction: $e';
    } finally {
      isLoading(false);
    }
  }

  // Get pending transactions for seller dashboard
  Future<List<TransactionModel>> getPendingTransactions(String sellerId) async {
    try {
      // 1. Get all order IDs for this seller
      final ordersSnapshot = await _db
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      if (ordersSnapshot.docs.isEmpty) return [];

      final orderIds = ordersSnapshot.docs.map((doc) => doc.id).toList();

      // 2. Get pending transactions for these orders
      final transactionsSnapshot = await _db
          .collection('transactions')
          .where('orderId', whereIn: orderIds)
          .where('status', isEqualTo: 'pendingVerification')
          .get();

      return transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get pending transactions: $e';
    }
  }
}