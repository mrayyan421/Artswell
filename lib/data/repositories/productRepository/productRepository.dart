import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../features/personalization/controllers/userController.dart';
import '../../../features/shop/models/productModel.dart';



import '../authenticationRepository/authenticationRepository.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _userCtrl = Get.find<UserController>();


  Future<void> ensureSeller() async {
    final currentUser = _userCtrl.user.value;
    if (currentUser.uid.isEmpty || currentUser.role != 'Seller') {
      throw 'Only Sellers may add or update products.';
    }
  }

  Future<List<ProductModel>> getLatestProducts({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _db.collection('products')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } on FirebaseException catch (e) {
      throw 'Firestore Error: ${e.code} - ${e.message}';
    } catch (e) {
      throw 'Failed to fetch latest products: ${e.toString()}';
    }
  }
  // Add this to your ProductRepository
  Future<List<ProductModel>> searchProducts({
    required String query,
    required String sortOption,
  }) async {
    try {
      if (query.isEmpty) return [];

      final searchTerm = query.toLowerCase();
      // Create separate queries for each field
      final nameQuery = _db.collection('products')
          .where('productName', isGreaterThanOrEqualTo: searchTerm)
          .where('productName', isLessThanOrEqualTo: '$searchTerm\uf8ff');

      final descQuery = _db.collection('products')
          .where('productDescription', isGreaterThanOrEqualTo: searchTerm)
          .where('productDescription', isLessThanOrEqualTo: '$searchTerm\uf8ff');

      final categoryQuery = _db.collection('products')
          .where('category', isGreaterThanOrEqualTo: searchTerm)
          .where('category', isLessThanOrEqualTo: '$searchTerm\uf8ff');

      // Execute all queries in parallel
      final results = await Future.wait([
        nameQuery.get(),
        descQuery.get(),
        categoryQuery.get(),
      ]);

      // Combine results and remove duplicates
      final allDocs = results.expand((snapshot) => snapshot.docs).toList();
      final uniqueDocs = allDocs.fold<Map<String, DocumentSnapshot>>({}, (map, doc) {
        map[doc.id] = doc;
        return map;
      }).values.toList();

      // Convert to ProductModels
      List<ProductModel> products = uniqueDocs
          .map((doc) => ProductModel.fromSnapshot(doc))
          .toList();

      // Apply sorting
      switch (sortOption) {
        case 'priceLowToHigh':
          products.sort((a, b) => a.productPrice.compareTo(b.productPrice));
          break;
        case 'priceHighToLow':
          products.sort((a, b) => b.productPrice.compareTo(a.productPrice));
          break;
        case 'latest':
        default:
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
      return products;
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    try {
      if (category.isEmpty) return [];

      // Normalize the category for search
      final normalizedCategory = category.toLowerCase();

      // Firestore query to fetch products with exact matching category
      final querySnapshot = await _db.collection('products').where('category', isEqualTo: normalizedCategory).get();

      // Convert documents to ProductModel list
      List<ProductModel> products = querySnapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();

      // Optional: sort by createdAt descending (latest first)
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return products;
    } catch (e) {
      debugPrint('Fetch category products error: $e');
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  Future<List<ProductModel>> fetchAll() async {
    try {
      final QuerySnapshot snap = await _db.collection('products').get();
      return snap.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  //fetch user's shops items
  Future<List<ProductModel>> fetchSellerProducts(String sellerId) async {
    try {
      final snapshot = await _db.collection('products').where('sellerId', isEqualTo: sellerId).get();

      return snapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Failed to fetch seller products: $e';
    }
  }
  Future<List<ProductModel>> getCurrentSellerProducts() async {
    final userId = AuthenticationRepository.instance.authUser?.uid;
    return fetchSellerProducts(userId!);
  }
  Future<ProductModel> getProductById(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists) throw 'Product not found';
    return ProductModel.fromSnapshot(doc);
  }
  Future<ShopInfo> getShopInfo(String sellerId) async {
    final doc = await _db.collection('Users').doc(sellerId).get();
    return ShopInfo(
      sellerId: sellerId,
      shopName: doc['shopName'] ?? 'Shop',
    );
  }


  Future<List<String>> _uploadImages(List<File> images, String path) async {
    try {
      final List<String> urls = [];
      final storageRef = _storage.ref();

      for (final image in images) {
        // Create unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ext = image.path.split('.').last;
        final fileName = '$timestamp.$ext';

        // Upload file
        final uploadTask = storageRef.child('$path/$fileName').putFile(image);
        final snapshot = await uploadTask;

        // Get download URL
        final downloadUrl = await snapshot.ref.getDownloadURL();
        urls.add(downloadUrl);
      }

      return urls;
    } catch (e) {
      throw 'Image upload failed: $e';
    }
  }

  Future<String> addProduct({
    required String name,
    required String description,
    required List<File> images,
    required int price,
    bool inStock = true,
    bool isBiddable = false,
    required String category,
    List<String> feedback = const [],
    int reviewCount = 0,
    required Timestamp createdAt,
    required double averageRating
  }) async {
    try {
      await ensureSeller();
      final sellerId = _userCtrl.user.value.uid;
      final imageUrls = await _uploadImages(images, 'product_images/$sellerId');

      final docRef = await _db.collection('products').add({
        'productName': name,
        'productDescription': description,
        'productImages': imageUrls,
        'primaryImageIndex': 0,
        'inStock': inStock,
        'productPrice': price,
        'isBiddable': isBiddable,
        'category': category,
        'isFavorite': false,
        'sellerId': sellerId,
        'feedback': feedback,
        'reviewCount': reviewCount,
        'createdAt': FieldValue.serverTimestamp(),
        'averageRating':averageRating
      });

      await _initializeCommentsSubcollection(docRef.id);
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> _initializeCommentsSubcollection(String productId) async {
    try {
      await _db.collection('products')
          .doc(productId)
          .collection('comments')
          .add({
        'initialized': true,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'init' // Marker document
      });
      print('Created comments subcollection for product $productId');
    } catch (e) {
      print('Error initializing comments subcollection: $e');
      rethrow;
    }
  }

  Future<void> addComment(String productId, Map<String, dynamic> comment) async {
    await _db.collection('products').doc(productId).collection('comments').add({
      'comment': comment['comment'],
      'userId': comment['userId'],
      'userName': comment['userName'],
      'createdAt': FieldValue.serverTimestamp(),
      'rating': comment['rating'] ?? 0.0,
    });
  }
  // Add this method to your ProductRepository
  Future<List<Map<String, dynamic>>> getProductComments(String productId) async {
    try {
      final snapshot = await _db.collection('products').doc(productId).collection('comments').orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'comment': data['comment'] ?? '', // Ensure proper fallbacks
          'userId': data['userId'] ?? '',
          'userName': data['userName'] ?? '',
          'rating': data['rating'] ?? 0.0,
          'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
        };
      }).toList();
    } catch (e) {
      throw 'Failed to fetch comments: $e';
    }
  }
  Stream<QuerySnapshot> getCommentsStream(String productId) {
    return _db.collection('products').doc(productId).collection('comments').orderBy('timestamp', descending: true).snapshots();
  }
  Future<List<Map<String, dynamic>>> getComments(String productId) async {
    final snapshot = await _db.collection('products').doc(productId).collection('comments').orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }


  Future<void> updateCommentPlaceholder({
    required String productId,
    required String newCommentText,
  }) async {
    final currentUser = _userCtrl.user.value;
    final commentDocRef = _db.collection('products').doc(productId).collection('comments').doc('comment');

    await commentDocRef.update({
      'comment': newCommentText,
      'userId': currentUser.uid,
      'userName': currentUser.fullName,
      'userType': currentUser.role,
      'createdAt': FieldValue.serverTimestamp().toString(),
      'initialized': false, // Optional: you can set it false after real comment
    });
  }

  Future<void> updateProduct({
    required String id,
    String? name,
    String? description,
    List<String>? newImageUrls,
    int? price,
    bool? inStock,
    int? primaryImageIndex,
    bool? isBiddable,
    bool? isFavorite,
    String? category,
  }) async {
    await ensureSeller();

    final docRef = _db.collection('products').doc(id);
    final data = <String, dynamic>{};

    // Only update fields that are provided
    if (name != null) data['productName'] = name;
    if (description != null) data['productDescription'] = description;
    if (price != null) data['productPrice'] = price;
    if (inStock != null) data['inStock'] = inStock;
    if (primaryImageIndex != null) data['primaryImageIndex'] = primaryImageIndex;
    if (isBiddable != null) data['isBiddable'] = isBiddable;
    if (isFavorite != null) data['isFavorite'] = isFavorite;
    if (category != null) data['category'] = category;

    // Handle image updates
    if (newImageUrls != null) {
      data['productImages'] = newImageUrls;

      // Ensure primary index is valid
      if (newImageUrls.isNotEmpty && !data.containsKey('primaryImageIndex')) {
        data['primaryImageIndex'] = 0; // Default to first image
      }
    }

    await docRef.update(data);
  }

  Future<void> setPrimaryImage({
    required String productId,
    required int newPrimaryIndex,
  }) async {
    final docRef = _db.collection('products').doc(productId);
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) throw 'Product not found';

    final images = List<String>.from(docSnapshot.get('productImages') ?? []);
    if (newPrimaryIndex < 0 || newPrimaryIndex >= images.length) {
      throw 'Invalid primary image index';
    }

    await docRef.update({'primaryImageIndex': newPrimaryIndex});
  }

  Future<void> addImages({
    required String productId,
    required List<File> files,
  }) async {
    try {
      // Get current user ID for storage path
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      // Upload new images
      final newUrls = await _uploadImages(
        files,
        'product_images/$userId',
      );

      // Get current images from Firestore
      final doc = await _db.collection('products').doc(productId).get();
      final currentImages = List<String>.from(doc['productImages'] ?? []);

      // Combine with new URLs
      final updatedImages = [...currentImages, ...newUrls];

      // Update Firestore
      await _db.collection('products').doc(productId).update({
        'productImages': updatedImages,
      });
    } catch (e) {
      throw 'Failed to add images: $e';
    }
  }

  Future<List<String>> fetchImageUrls(String productId)async{
    final doc=await _db.collection('products').doc(productId).get();
    if(!doc.exists)throw 'Product not found';
    return List<String>.from(doc.get('productImages'));
  }
  // Add these to ProductRepository
  Future<List<ProductModel>> fetchPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query query = _db.collection('products').orderBy('productName').limit(limit);

    if(lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snap = await query.get();
    return snap.docs.map(ProductModel.fromSnapshot).toList();
  }

  Future<List<ProductModel>> fetchProductsSortedByPrice({required bool ascending}) async {
    try {
      final query = _db.collection('products')
          .orderBy('productPrice', descending: !ascending);

      final snap = await query.get();
      return snap.docs.map(ProductModel.fromSnapshot).toList();
    } catch (e) {
      throw 'Failed to fetch sorted products: $e';
    }
  }



  Future<DocumentSnapshot> getDocumentSnapshot(String productId) async {
    return await _db.collection('products').doc(productId).get();
  }

  ///delete selected prod
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }
}