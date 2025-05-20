import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/enumerations.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String orderId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? paymentDetails;
  final String? receiptUrl;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.type,
    this.status = TransactionStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.paymentDetails,
    this.receiptUrl,
  });

  factory TransactionModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return TransactionModel(
      id: snap.id,
      userId: data['userId'],
      orderId: data['orderId'],
      amount: data['amount'].toDouble(),
      type: _stringToTransactionType(data['type']),
      status: _stringToTransactionStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      paymentDetails: data['paymentDetails'],
      receiptUrl: data['receiptUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'orderId': orderId,
    'amount': amount,
    'type': _transactionTypeToString(type),
    'status': transactionStatusToString(status),
    'createdAt': Timestamp.fromDate(createdAt),
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'paymentDetails': paymentDetails,
    'receiptUrl': receiptUrl,
  };

  static TransactionType _stringToTransactionType(String type) {
    switch (type) {
      case 'creditCard': return TransactionType.card;
      case 'bankTransfer': return TransactionType.bankTransfer;
      case 'easyPaisaPayment': return TransactionType.easyPaisaPayment;
      case 'cashOnDelivery': return TransactionType.cashOnDelivery;
      default: return TransactionType.cashOnDelivery;
    }
  }

  static String _transactionTypeToString(TransactionType type) {
    return type.toString().split('.').last;
  }

  static TransactionStatus _stringToTransactionStatus(String status) {
    switch (status) {
      case 'pending': return TransactionStatus.pending;
      case 'completed': return TransactionStatus.completed;
      case 'failed': return TransactionStatus.failed;
      case 'refunded': return TransactionStatus.refunded;
      case 'cancelled': return TransactionStatus.cancelled;
      default: return TransactionStatus.pending;
    }
  }

  static String transactionStatusToString(TransactionStatus status) {
    return status.toString().split('.').last;
  }
}