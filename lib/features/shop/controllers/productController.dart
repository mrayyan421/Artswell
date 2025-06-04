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
  final RxList<ProductModel> sellerProducts = <ProductModel>[].obs;
  final RxList<ProductModel> allProducts=<ProductModel>[].obs;

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
  RxList<ProductModel> searchResults = <ProductModel>[].obs;
  late Worker _searchDebounce;


  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  // var allProducts = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  // final RxString selectedCategory = RxString('');
  final RxString selectedSort = RxString('latest');
  //category sort vars
  final RxList<ProductModel> categoryProducts = <ProductModel>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isCategoryLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    _searchDebounce = debounce(
      searchQuery,
          (_) {
        debugPrint("Debounced search: ${searchQuery.value}");
        loadProducts();
      },
      time: const Duration(milliseconds: 500),
    );
  }


  Future<void> loadProducts() async {
    isLoading(true);

    try {
      if (searchQuery.value.isEmpty &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < const Duration(seconds: 30) &&
          _cache.containsKey(selectedSort.value)) {
        products.value = _cache[selectedSort.value]!;
        return;
      }

      List<ProductModel> loadedProducts = [];

      if (searchQuery.value.isNotEmpty) {
isLoading(false);
        try {
          loadedProducts = await _repo.searchProducts(
            query: searchQuery.value,
            sortOption: selectedSort.value,
          );
        } catch (e) {
          debugPrint('Search failed: $e');
          loadedProducts = [];
        }
      } else {
        // REGULAR LOAD
        switch (selectedSort.value) {
          case 'priceLowToHigh':
            loadedProducts = await _repo.fetchProductsSortedByPrice(ascending: true);
            break;
          case 'priceHighToLow':
            loadedProducts = await _repo.fetchProductsSortedByPrice(ascending: false);
            break;
          case 'latest':
          default:
            loadedProducts = await _repo.getLatestProducts();
            break;
        }
        // isLoading(false);

        // Cache only for regular (non-search) loads
        _cache[selectedSort.value] = loadedProducts;
        _lastFetchTime = DateTime.now();
      }

      products.value = loadedProducts;
    } catch (e) {
      debugPrint('Load products error: $e');
      products.value = [];
      if (searchQuery.value.isEmpty) {
        kLoaders.errorSnackBar(title: 'Error', message: 'Failed to load products');
      }
    } finally {
      isLoading(false);
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
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

  Future<List<ProductModel>> fetchProductsFromService() async {
    await Future.delayed(Duration(seconds: 1));
    return filteredProducts;
  }
  Future<void> fetchAllProducts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      allProducts.assignAll(querySnapshot.docs.map((doc) =>
          ProductModel.fromSnapshot(doc)));
    } catch (e) {
      kLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
  Future<void> loadCategoryProducts(String category) async {
    try {
      isLoading(true);
      final productsByCategory = await _repo.fetchProductsByCategory(category);
      products.assignAll(productsByCategory);
    } catch (e) {
      debugPrint('Category load failed: $e');
      products.clear();
    } finally {
      isLoading(false);
    }
  }

  void clearCategoryFilters() {
    selectedCategory.value = '';
    categoryProducts.clear();
  }

  Future<void> refreshComments(String productId) async {
    try {
      isLoading(true);
      final comments = await _repo.getProductComments(productId);
      productComments.assignAll(comments);

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
  @override
  void onClose() {
    _searchDebounce.dispose();
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

  ///adding imgs
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
    List<XFile>? newImages,
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
      rethrow;
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
      final newUrls = await _uploadImages(picked, 'product_images/$uid');

      // Get current product data
      final currentProduct = selectedProduct.value;
      if (currentProduct == null) throw 'Product not loaded';

      final updatedImages = [
        currentProduct.productImages.first ?? '',
        ...(currentProduct.productImages.skip(1) ?? <String>[]),
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





