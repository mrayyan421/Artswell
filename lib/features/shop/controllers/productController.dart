import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/widgets/loaders/basicLoaders.dart';
import '../../../data/repositories/productRepository/productRepository.dart';
import '../../../data/repositories/userRepository/userRepository.dart';
import '../../personalization/controllers/userController.dart';
import '../models/orderModel.dart';
import '../models/productModel.dart';


import 'orderController.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final _repo=Get.put(ProductRepository());
  final orderController=Get.put(OrderController());
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxList<Map<String, dynamic>> productComments = <Map<String, dynamic>>[].obs;
  final int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  final RxList<ProductModel> sellerProducts = <ProductModel>[].obs;

  final RxDouble averageRating=0.0.obs;
  final RxList<Map<String,dynamic>>reviews=<Map<String,dynamic>>[].obs;
  var products = <ProductModel>[].obs;
  final Rx<bool> isLoading = false.obs;
  var errorMessage = RxnString();
  /// The seller’s primary image URL (or empty if none)
  final RxString primaryImageUrl = ''.obs;
  /// The seller’s additional product-image URLs
  final RxList<String> secondaryImageUrls = <String>[].obs;
  static final _cache = <String, List<ProductModel>>{};
  static DateTime? _lastFetchTime;
  final RxMap<String, String> _shopNames = <String, String>{}.obs;
  final RxList<CartItem> cartItems = <CartItem>[].obs;

  //search vars
  final RxString searchQuery = RxString('');
  // final RxString selectedCategory = RxString('');
  final RxString selectedSort = RxString('latest');
  //category sort vars
  final RxList<ProductModel> categoryProducts = <ProductModel>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isCategoryLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    // loadComments(ProductController().selectedProduct.value!.id);
    // _loadShopImages();
  }

  Future<void> loadProducts() async {
    try {
      // Don't reload if data is fresh (e.g., within last 30 seconds)
      if (_lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < const Duration(seconds: 30) &&
          _cache.containsKey(selectedSort.value)) {
        products.value = _cache[selectedSort.value]!;
        return;
      }
      isLoading(true);
      List<ProductModel> loadedProducts;

      if (selectedSort.value.isEmpty || selectedSort.value == 'latest') {
        loadedProducts = await _repo.getLatestProducts();
      } else if (selectedSort.value == 'priceLowToHigh') {
        loadedProducts = await _repo.fetchProductsSortedByPrice(ascending: true);
      } else if (selectedSort.value == 'priceHighToLow') {
        loadedProducts = await _repo.fetchProductsSortedByPrice(ascending: false);
      } else {
        loadedProducts = await _repo.fetchAll();
      }

      // Update cache
      _cache[selectedSort.value] = loadedProducts;
      _lastFetchTime = DateTime.now();
      products.value = loadedProducts;

      // isLoading(false);
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to load products');
    } finally {
      isLoading(false);
    }
  }
  Future<String> getShopName(String sellerId) async {
    if (_shopNames.containsKey(sellerId)) return _shopNames[sellerId]!;

    try {
      final shopInfo = await _repo.getShopInfo(sellerId);
      _shopNames[sellerId] = shopInfo.shopName;
      return _shopNames[sellerId]!;
    } catch (e) {
      return 'ArtsWell';
    }
  }
  Future<void> loadSellerProducts(String? sellerId) async {
    try {
      isLoading(true);
      final result = sellerId == null
          ? await ProductRepository.instance.getCurrentSellerProducts()
          : await ProductRepository.instance.fetchSellerProducts(sellerId);
      sellerProducts.assignAll(result);
      isLoading(false);
    } catch (e) {
      isLoading(false);
      kLoaders.errorSnackBar(title: 'Error', message: 'Failed to load products: ${e.toString()}');
    }
  }
  Future<void> loadCategoryProducts(String category) async {
    try {
      isLoading(true);
      selectedCategory.value = category;
      final products = await _repo.fetchProductsByCategory(category);
      categoryProducts.assignAll(products);
    } catch (e) {
      categoryProducts.clear();
      kLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  void clearCategoryFilters() {
    selectedCategory.value = '';
    categoryProducts.clear();
  }

  Future<DocumentSnapshot?> _getLastVisibleDocument() async {
    if(products.isEmpty) return null;
    final lastProduct = products.value.last;
    return await _repo.getDocumentSnapshot(lastProduct.id);
  }

  Future<void> refreshComments(String productId) async {
    try {
      isLoading(true);
      final comments = await _repo.getProductComments(productId);
      productComments.assignAll(comments);

      // Calc average rating
      if (productComments.isNotEmpty) {
        final totalRating = productComments.fold(0.0, (sum, comment) {
          return sum + (comment['rating'] ?? 0.0);
        });
        averageRating.value = totalRating / productComments.length-1;
      } else {
        averageRating.value = 0.0;
      }
    } catch (e) {
      kLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to refresh comments: ${e.toString()}'
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateAverageRating(String productId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .get();

    if (snapshot.docs.isEmpty) return;

    final total = snapshot.docs.fold(0.0, (sum, doc) {
      return sum + (doc.data()['rating'] as num).toDouble();
    });

    final average = total / snapshot.docs.length;
    averageRating.value = double.parse(average.toStringAsFixed(1));

    // Update product document with new average
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .update({
      'averageRating': averageRating.value,
      'reviewCount': snapshot.docs.length,
    });
  }
  @override
  void onClose() {
    super.onClose();
  }
  Future<void> addComment(String productId, String comment, double rating) async {
    try {
      final user = UserController.instance.user.value;
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('comments')
          .add({
        'comment': comment,
        'rating': rating,
        'userId': user.uid,
        'userName': user.fullName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // No need to manually refresh - the stream will update automatically
      kLoaders.successSnackBar(
          title: 'Success',
          message: 'Comment added successfully'
      );
    } catch (e) {
      kLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to add comment: ${e.toString()}'
      );
      rethrow;
    }
  }
  /*Future<void> addComment(String productId, String commentText, double rating) async {
    try {
      final user = UserController.instance.user.value;

      // Add to comments subcollection
      await _repo.addComment(productId, {
        'comment': commentText,
        'userId': user.uid,
        'userName': user.fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'rating': rating,
      });

      // Refresh comments after adding new one
      await refreshComments(productId);

      // Also update average rating
      await updateAverageRating(productId);

      kLoaders.successSnackBar(
          title: 'Success',
          message: 'Comment added successfully'
      );
    } catch (e) {
      print('Failed to add comment: $e');
      kLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to add comment: ${e.toString()}'
      );
    }
  }*/
  /* Future<double> calculateAverageRating(String productId) async {
    try {
      final comments = await _repo.getProductComments(productId);
      if (comments.isEmpty) return 0.0;

      final totalRating = comments.fold(0.0, (sum, comment) {
        return sum + (comment['rating'] ?? 0.0);
      });

      return totalRating / comments.length;
    } catch (e) {
      return 0.0;
    }
  }*/
  ///Trigger func for uploading imgs
  /*Future<void> pickAndUploadImage(String productId) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Upload the image using ProductRepository
        await _repo.addImages(
          productId: productId,
          files: [file],
        );

        // Refresh the product data
        final updatedProduct = await _repo.getProductById(productId);
        selectedProduct.value = updatedProduct;

        kLoaders.successSnackBar(
            title: 'Success!',
            message: 'Image uploaded successfully'
        );
      }
    } catch (e) {
      kLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to upload image: ${e.toString()}'
      );
    }
  }*/
  Future<void> pickAndUploadImage(String productId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

        // Upload the image
        final String imgUrl = await UserRepository.instance.uploadImage(
            'product_images/$uid',
            pickedFile
        );

        // Get current product data
        final currentProduct = await _repo.getProductById(productId);
        List<String> productImages = currentProduct.productImages ?? [];

        // Replace the first image (thumbnail) or add if empty
        if (productImages.isNotEmpty) {
          productImages[0] = imgUrl;
        } else {
          productImages.add(imgUrl);
        }

        // Update the product document
        await _repo.updateProduct(
          id: productId,
          newImageUrls: productImages,
          primaryImageIndex: 0, // Always set primary image to index 0
        );

        // Update local state
        selectedProduct.value = ProductModel(
          id: currentProduct.id,
          productName: currentProduct.productName,
          productImages: productImages,
          primaryImageIndex: 0,
          inStock: currentProduct.inStock,
          isBiddable: currentProduct.isBiddable,
          isFavorite: currentProduct.isFavorite,
          productDescription: currentProduct.productDescription,
          productPrice: currentProduct.productPrice,
          sellerId: currentProduct.sellerId,
          comment: currentProduct.comment,
          category: currentProduct.category,
          feedback: currentProduct.feedback,
          reviewCount: currentProduct.reviewCount,
          comments: currentProduct.comments,
          createdAt: currentProduct.createdAt,
          averageRating: currentProduct.averageRating,
        );

        Get.back();
        kLoaders.successSnackBar(
            title: 'Success!',
            message: 'Thumbnail image updated successfully'
        );
      } else {
        Get.back();
      }
    } catch (e) {
      Get.back();
      debugPrint('Image upload error: $e');
      kLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to update thumbnail: ${e.toString()}'
      );
    }
  }
  //----------------------working func
  //----------------------------------
  /*Future<void> pickAndUploadImage(String productId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

        // Upload image
        final String imgUrl = await UserRepository.instance.uploadImage(
            'product_images/$uid',
            file
        );

        // Update product with new image
        final currentProduct = selectedProduct.value;
        if (currentProduct != null) {
          final updatedImages = [
            imgUrl,
            ...(currentProduct.productImages?.skip(1) ?? <String>[])
          ];

          await _repo.updateProduct(
            id: productId,
            newImageUrls: updatedImages,
            primaryImageIndex: 0,
          );

          // Update local state
          selectedProduct.value = ProductModel(
            id: productId,  // This is passed to the function; Firestore auto-generates it when using .add()
            productName: selectedProduct.value?.productName??'Product1',
            productImages: [imgUrl],
            primaryImageIndex: 0,  //first image is primary so 0
            inStock: selectedProduct.value?.inStock??true,//if new product is in stock
            isBiddable: selectedProduct.value?.isBiddable??false,
            isFavorite: selectedProduct.value?.isFavorite??false,
            productDescription: selectedProduct.value?.productDescription??'Product description comes here',
            productPrice: selectedProduct.value?.productPrice??0,
            sellerId: UserController.instance.user.value.uid,
            comment: selectedProduct.value?.comment??'',
            category: selectedProduct.value?.category??'Calligraphy',
            feedback: selectedProduct.value?.feedback??[],
            reviewCount: selectedProduct.value?.reviewCount??0,
            comments: selectedProduct.value?.comments??[],
            createdAt: selectedProduct.value?.createdAt??Timestamp.now(),
            averageRating: selectedProduct.value?.averageRating??0.0
          );
        }

        Get.back();
        kLoaders.successSnackBar(
            title: 'Success!',
            message: 'Image uploaded successfully'
        );
      } else {
        Get.back();
      }
    } catch (e) {
      Get.back();
      debugPrint('Image upload error: $e');
      kLoaders.errorSnackBar(
          title: 'Upload Failed',
          message: 'Failed to upload image: ${e.toString()}'
      );
      rethrow;
    }
  }*/
  /*Future<void> pickAndUploadImage(String productId) async {
    try{
      print('pickAndUploadImage called with productId: $productId');
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final imgUrl = await UserRepository.instance.uploadImage('product_images/$uid', pickedFile);


      Map<String, dynamic> json = {'productImages': [imgUrl]};//ask gpt how to store the image in first index
      await UserRepository.instance.updateSingleField(json);//add this method inside user repository and ask gpt how to update method for Seller

      final currentUser = UserController.instance.user.value;

      selectedProduct.value = ProductModel(
        id: productId,  // This is passed to the function; Firestore auto-generates it when using .add()
        productName: selectedProduct.value?.productName??'Product1',
        productImages: [imgUrl],
        primaryImageIndex: 0,  //first image is primary so 0
        inStock: selectedProduct.value?.inStock??true,//if new product is in stock
        isBiddable: selectedProduct.value?.isBiddable??false,
        isFavorite: selectedProduct.value?.isFavorite??false,
        productDescription: selectedProduct.value?.productDescription??'Product description comes here',
        productPrice: selectedProduct.value?.productPrice??0,
        sellerId: currentUser.uid,
        comment: selectedProduct.value?.comment??'',
        category: selectedProduct.value?.category??'Calligraphy',
        feedback: selectedProduct.value?.feedback??[],
        reviewCount: selectedProduct.value?.reviewCount??0,
          comments: selectedProduct.value?.comments??[],
        createdAt: selectedProduct.value?.createdAt??Timestamp.now(),
        averageRating: selectedProduct.value?.averageRating??0.0
      );
      await updateProduct(id: productId, newImages: [File(imgUrl)]);
      kLoaders.successSnackBar(title: 'Success!',message: 'Image uploaded successfully');
    }}catch(e){
      print(e);
      kLoaders.errorSnackBar(title: 'Hmmm...',message: e.toString());
    }
  }*/


  ///adding images
  Future<String> add({
    required String name,
    required String description,
    required List<File> images,
    required int price,
    bool inStock = true,
    bool isBiddable = false,
    required String category,
    required List<String> feedback,
    int reviewCount=0,
    required Timestamp createdAt,
    required double averageRating
  }) async {
    await _repo.ensureSeller();
    isLoading(true);
    try {
      final newId = await _repo.addProduct(
          name: name,
          description: description,
          images: images,
          price: price,
          inStock: inStock,
          isBiddable:isBiddable,
          category:category,
          feedback: feedback,
          reviewCount: reviewCount,
          createdAt:createdAt,
          averageRating: averageRating
      );
      await loadProducts();
      return newId;
    } finally {
      isLoading(false);
    }
  }

  ///to update product
  Future<void> updateProduct({
    required String id,
    String? name,
    String? description,
    List<XFile>? newImages,  // Changed from List<File> to List<XFile>
    int? price,
    bool? inStock,
    int? primaryImageIndex,
    bool? isBiddable,
    bool? isFavorite,
    String? category,
  }) async {
    try {
      isLoading(true);

      List<String>? imageUrls;
      if (newImages != null && newImages.isNotEmpty) {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
        imageUrls = await _uploadImages(newImages, 'product_images/$uid');

        // Add to user's productImages list in Firestore
        if (uid != 'unknown') {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(uid)
              .update({
            'productImages': FieldValue.arrayUnion(imageUrls)
          });
        }
      }

      await _repo.updateProduct(
        id: id,
        name: name,
        description: description,
        newImageUrls: imageUrls,
        price: price,
        inStock: inStock,
        primaryImageIndex: primaryImageIndex,
        isBiddable: isBiddable,
        isFavorite: isFavorite,
        category: category,
      );

      await loadProducts();
    } catch (e) {
      errorMessage(e.toString());
      rethrow;  // Re-throw to allow error handling upstream
    } finally {
      isLoading(false);
    }
  }

  Future<List<String>> _uploadImages(List<XFile> images, String path) async {
    try {
      final List<String> urls = [];
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';
      for (final image in images) {
        final url = await UserRepository.instance.uploadImage(path, image);
        urls.add(url);

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'productImages': FieldValue.arrayUnion([url])
        });
      }
      return urls;
    } catch (e) {
      throw 'Failed to upload images: $e';
    }
  }

  // In your ProductController
  /*Future<void> setPrimaryImage(String productId, int index) async {
    try {
      // Validate the index
      if (selectedProduct.value == null ||
          selectedProduct.value!.productImages == null ||
          index < 0 ||
          index >= selectedProduct.value!.productImages!.length) {
        throw 'Invalid image index';
      }

      // Update in Firestore
      await _repo.setPrimaryImage(
        productId: productId,
        newPrimaryIndex: index,
      );

      // No need to update local state here - already done in widget
    } catch (e) {
      Get.snackbar('Error', 'Failed to update image: ${e.toString()}');
      // Revert the UI change
      selectedProduct.refresh();
    }
  }*/
  void updatePrimaryImageLocally(int index) {
    if (selectedProduct.value != null) {
      selectedProduct.value!.primaryImageIndex = index;
      selectedProduct.refresh();
    }
  }
  Future<void> setPrimaryImage(String productId, int index) async {
    try {
      // Verify we're working with the correct product
      if (selectedProduct.value?.id != productId) return;

      // Validate the index
      final images = selectedProduct.value?.productImages;
      if (images == null || index < 0 || index >= images.length) {
        throw 'Invalid image index';
      }

      // Update in Firestore
      await _repo.setPrimaryImage(
        productId: productId,
        newPrimaryIndex: index,
      );

    } catch (e) {
      Get.snackbar('Error', 'Failed to update image: ${e.toString()}');
      // Revert local change
      selectedProduct.refresh();
    }
  }
  ///To set bg img
  ///real one----------------------------
  /*Future<void> setPrimaryImage(String productId, int newIndex) async {
    try {
      // Get current product values
      final current = selectedProduct.value;
      if (current == null || current.id != productId) return;

      // Create new ProductModel with updated index
      selectedProduct.value = ProductModel(
        id: current.id,
        productName: current.productName,
        productImages: current.productImages,
        primaryImageIndex: newIndex, // This is the only changed field
        inStock: current.inStock,
        isBiddable: current.isBiddable,
        isFavorite: current.isFavorite,
        productDescription: current.productDescription,
        productPrice: current.productPrice,
        sellerId: current.sellerId,
        comment: current.comment,
        category: current.category,
        feedback: current.feedback,
        reviewCount: current.reviewCount,
        comments: current.comments,
        createdAt: current.createdAt,
        averageRating: current.averageRating,
      );

      // Update in Firestore
      await _repo.setPrimaryImage(
        productId: productId,
        newPrimaryIndex: newIndex,
      );

    } catch (e) {
      errorMessage(e.toString());
      // Optionally revert visual change here if needed
    }
  }*/
  /*Future<void> setPrimaryImage(String productId, int index) async {
    try {
      isLoading(true);
      await _repo.setPrimaryImage(productId: productId, newPrimaryIndex: index);
      await loadProducts();

      final updated = products.firstWhereOrNull((p) => p.id == productId);
      if (updated != null) selectedProduct.value = updated;

    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }*/
  Future<void> setSecondaryImages(String productId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Pick images using XFile directly
      final picked = await ImagePicker().pickMultiImage();
      if (picked.isEmpty) {
        Get.back();
        return;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

      // Upload new images directly using XFiles
      final newUrls = await _uploadImages(picked, 'product_images/$uid'); // Changed to use XFiles directly

      // Get current product data
      final currentProduct = selectedProduct.value;
      if (currentProduct == null) throw 'Product not loaded';

      // Combine with existing images (keeping the first image as thumbnail)
      final updatedImages = [
        currentProduct.productImages.first ?? '', // Keep existing thumbnail
        ...(currentProduct.productImages.skip(1) ?? <String>[]), // Existing secondary images
        ...newUrls // New images
      ];

      // Update Firestore
      await _repo.updateProduct(
        id: productId,
        newImageUrls: updatedImages,
        primaryImageIndex: currentProduct.primaryImageIndex,
      );

      // Update local state
      selectedProduct.value = ProductModel(
          id: productId,
          productName: selectedProduct.value?.productName ?? 'Product1',
          productImages: updatedImages,
          primaryImageIndex: 0,
          inStock: selectedProduct.value?.inStock ?? true,
          isBiddable: selectedProduct.value?.isBiddable ?? false,
          isFavorite: selectedProduct.value?.isFavorite ?? false,
          productDescription: selectedProduct.value?.productDescription ?? 'Product description comes here',
          productPrice: selectedProduct.value?.productPrice ?? 0,
          sellerId: UserController.instance.user.value.uid,
          comment: selectedProduct.value?.comment ?? '',
          category: selectedProduct.value?.category ?? 'Calligraphy',
          feedback: selectedProduct.value?.feedback ?? [],
          reviewCount: selectedProduct.value?.reviewCount ?? 0,
          comments: selectedProduct.value?.comments ?? [],
          createdAt: selectedProduct.value?.createdAt ?? Timestamp.now(),
          averageRating: selectedProduct.value?.averageRating ?? 0.0
      );

      // Add to user's productImages list in Firestore
      if (uid != 'unknown_user') {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .update({
          'productImages': FieldValue.arrayUnion(newUrls)
        });
      }

      Get.back();
      kLoaders.successSnackBar(
          title: 'Success!',
          message: 'Additional images added successfully'
      );
    } catch (e) {
      Get.back();
      debugPrint('Error adding secondary images: $e');
      kLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to add images: ${e.toString()}'
      );
      rethrow;
    }
  }


  Future<void> deleteImage(String productId, int index) async {
    try {
      isLoading(true);
      await _repo.deleteImage(productId: productId, index: index);
      await loadProducts();
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;
      await _repo.deleteProduct(productId);
      sellerProducts.removeWhere((product) => product.id == productId);
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

}





