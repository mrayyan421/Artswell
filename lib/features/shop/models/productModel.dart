import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String productName;
  final String productDescription;
  final List<String> productImages;
  int? primaryImageIndex;
  final bool inStock;
  final int productPrice;
  bool isBiddable;
  final bool isFavorite;
  final String sellerId;
  // final String shopName; //this feild
  final String comment;
  final String category;
  final List<Map<String, dynamic>> feedback;
  final int reviewCount;
  final List<String> comments;
  final Timestamp createdAt;
  final double averageRating;

  ProductModel({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.productImages,
    this.primaryImageIndex,
    required this.inStock,
    required this.productPrice,
    required this.isBiddable,
    required this.isFavorite,
    required this.sellerId,
    // required this.shopName,
    this.comment = '',
    this.category = '',
    this.feedback= const [],
    required this.reviewCount,
    required this.comments,
    required this.createdAt,
    required this.averageRating
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProductModel(
        id: doc.id,
        productName: data['productName'] as String? ?? '',
        productDescription: data['productDescription'] as String? ?? '',
        productImages: List<String>.from(data['productImages'] ?? []),
        primaryImageIndex: data.containsKey('primaryImageIndex') ? (data['primaryImageIndex'] as int?) : null,
        inStock: data['inStock'] as bool? ?? true,
        productPrice: (data['productPrice'] as num?)?.toInt() ?? 0,
        isBiddable: data['isBiddable'] as bool? ?? false,
        isFavorite: data['isFavorite'] as bool? ?? false,
        sellerId: data['sellerId'] as String? ?? '',
        // shopName: data['shopName'] as String,
        comment: data['comment'] as String? ?? '',
        category: data['category'] as String? ?? '',
        feedback: List<Map<String, dynamic>>.from(data['feedback'] ?? []),
        reviewCount: data.containsKey('reviewCount') ? (data['reviewCount']) : 0,
        comments: List<String>.from(data['comments'] ?? []),
        createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
        averageRating: data['averageRating']??0.0
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'productName': productName,//done
      'productDescription': productDescription,//done
      'productImages': productImages,//done
      'inStock': inStock,
      'productPrice': productPrice,//done
      'isBiddable': isBiddable,
      'isFavorite': isFavorite,
      'sellerId': sellerId,//TBD
      // 'shopName':shopName,
      'comment': comment,
      'category': category,
      'reviewCount':reviewCount,
      'feedback':feedback,
      'createdAt': createdAt,
      'averageRating':averageRating
    };
    if (primaryImageIndex != null) {
      json['primaryImageIndex'] = primaryImageIndex;
    }
    return json;
  }
  static Map<String, dynamic> getInitialCommentData() {
    return {
      'initialized': true,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'init',
    };
  }
}
class ShopInfo {
  final String sellerId;
  final String shopName;

  ShopInfo({required this.sellerId, required this.shopName});
}
