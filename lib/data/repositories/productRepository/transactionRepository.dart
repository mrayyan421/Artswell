import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/shop/models/transactionModel.dart';
import '../../../utils/constants/enumerations.dart';

class TransactionRepository extends GetxController {
  static TransactionRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _db.collection('transactions').add(transaction.toJson());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create transaction: $e';
    }
  }

  Future<void> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status
  }) async {
    try {
      await _db.collection('transactions').doc(transactionId).update({
        'status': TransactionModel.transactionStatusToString(status),
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update transaction status: $e';
    }
  }

  Future<TransactionModel> getTransaction(String transactionId) async {
    try {
      final doc = await _db.collection('transactions').doc(transactionId).get();
      if (!doc.exists) throw 'Transaction not found';
      return TransactionModel.fromSnapshot(doc);
    } catch (e) {
      throw 'Failed to get transaction: $e';
    }
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    try {
      final snapshot = await _db.collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => TransactionModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Failed to get user transactions: $e';
    }
  }
  // Add these methods to your TransactionRepository class

  Future<void> updateReceiptUrl(String transactionId, String receiptUrl) async {
    try {
      await _db.collection('transactions').doc(transactionId).update({
        'receiptUrl': receiptUrl,
      });
    } catch (e) {
      throw 'Failed to update receipt URL: $e';
    }
  }

  Future<List<TransactionModel>> getPendingTransactionsForSeller(String sellerId) async {
    try {
      // First get all order IDs for this seller
      final ordersSnapshot = await _db.collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      if (ordersSnapshot.docs.isEmpty) return [];

      final orderIds = ordersSnapshot.docs.map((doc) => doc.id).toList();

      // Then get pending transactions for these orders
      final transactionsSnapshot = await _db.collection('transactions')
          .where('orderId', whereIn: orderIds)
          .where('status', isEqualTo: 'pending')
          .where('type', isEqualTo: 'easyPaisaPayment')
          .get();

      return transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw 'Failed to get pending transactions: $e';
    }
  }
}