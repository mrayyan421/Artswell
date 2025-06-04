
//TODO: Create API for order management

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String sellerId;
  final List<OrderItem> items;
  final String status;
  final DateTime orderDate;
  final DateTime estimatedDelivery;
  final double totalAmount;
  final String productImage;
  final String? receiptImageUrl;
  final String address;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.sellerId,
    required this.items,
    required this.status,
    required this.orderDate,
    required this.estimatedDelivery,
    required this.totalAmount,
    required this.productImage,
    required this.address,
    this.receiptImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'sellerId':sellerId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'estimatedDelivery': estimatedDelivery.toIso8601String(),
      'totalAmount': totalAmount,
      'productImage':productImage,
      'receiptImageUrl': receiptImageUrl,
      'address':address
    };
  }

  factory OrderModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return OrderModel(
      orderId: doc.id,
      userId: data['userId'],
      sellerId: data['sellerId'],
      items: (data['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      status: data['status'],
      orderDate: DateTime.parse(data['orderDate']),
      estimatedDelivery: DateTime.parse(data['estimatedDelivery']),
      totalAmount: data['totalAmount'],
      productImage: data['productImage']??'',
      receiptImageUrl: data['receiptImageUrl'],
      address: data['address']
    );
  }
  Map<String, dynamic> toMinimalJson() => {
    'orderId': orderId,
    'receiptImageUrl': receiptImageUrl,
    'orderDate': orderDate.toIso8601String(),
    'status': status,
    'totalAmount': totalAmount,
    'productImage': productImage,
    'address':address
  };
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String address;


  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    required this.address
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'address':address,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
        productId: json['productId'],
        name: json['name'],
        quantity: json['quantity'],
        price: json['price'],
        imageUrl: json['imageUrl'],
      address: json['address']
    );
  }
  factory OrderItem.fromCartItem(CartItem item) {
    return OrderItem(
      productId: item.productId,
      name: item.name,
      quantity: item.quantity,
      price: item.price,
      imageUrl: item.imageUrl,
      address: item.address
    );
  }
}

// Add this CartItem model
class CartItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;
  final String address;

  CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.address
  });
  OrderItem toOrderItem() {
    return OrderItem(
      productId: productId,
      name: name,
      quantity: quantity,
      price: price,
      imageUrl: imageUrl,
      address: address
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'address':address
    };
  }
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
        productId: json['productId'],
        name: json['name'],
        quantity: json['quantity'],
        price: json['price'],
        imageUrl: json['imageUrl'],
      address: json['address']
    );
  }
}