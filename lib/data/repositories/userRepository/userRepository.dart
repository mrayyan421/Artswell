import 'dart:io';

import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import 'package:artswellfyp/data/repositories/productRepository/productRepository.dart';
import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:artswellfyp/features/authentication/models/userModels/userModel.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/widgets/loaders/basicLoaders.dart';
import '../../../features/authentication/screens/login/login.dart';
import '../../../features/personalization/models/addressModel.dart';
import '../../../features/shop/models/orderModel.dart';

//TODO: this class is for handling user data
// Repository class for user-related operations.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage=FirebaseStorage.instance;

  Future<List<OrderModel>> getUserCartItems(String userId) async {
    try {
      final snapshot = await _db.collection("Users").doc(userId).collection("cart").where("status", isEqualTo: "Pending").orderBy("orderDate", descending: true).get();

      return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error fetching cart items: $e');
      rethrow;
    }
  }
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final snapshot = await _db.collection("Users").doc(userId).collection("addresses").orderBy("createdAt", descending: true).get();

      return snapshot.docs.map((doc) => AddressModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching addresses: $e');
      rethrow;
    }
  }
  Future<UserModel> getUserWithOrders(String userId) async {
    try {
      final doc = await _db.collection('Users').doc(userId).get();
      if (!doc.exists) throw 'User not found';
      return UserModel.fromSnapshot(doc);
    } on FirebaseException catch (e) {
      throw 'Firestore error: ${e.message}';
    } catch (e) {
      throw 'Failed to fetch user: $e';
    }
  }
  // Function to save user data to Firestore.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      final userRef = _db.collection("Users").doc(user.uid);

      // 1. Create main user document
      await userRef.set(user.toJson());

      // 2. Create all subcollections
      await userRef.collection("cart").doc("initial").set({
        'initialized': true,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      });

      final addressDoc = userRef.collection("addresses").doc("initial");
      if (!(await addressDoc.get()).exists) {
        await addressDoc.set(AddressModel(
          id: 'initial_${user.uid}',
          userId: user.uid,
          name: user.fullName.isNotEmpty ? user.fullName : 'User',
          phoneNumber: user.phoneNumber ?? '',
          address: '',
          postalCode: '',
          state: '',
          city: '',
          country: '',
          isDefault: true,
          createdAt: Timestamp.now(),
        ).toJson());
      }

      // 3. Create orders subcollection
      await userRef.collection("orders").doc("initial").set({
        'initialized': true,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'status': 'ready',
        'orderCount': 0,
      });

      // 4. NEW: Create seller_stories subcollection for sellers
      if (user.role == 'Seller') {
        await userRef.collection("seller_stories").doc(user.uid).set({
          'userId': user.uid,
          'shopName': user.shopName ?? 'ArtsWell',
          'successStory': '',
          'remarks': '',
          'shopDetails': '',
          'profileImageUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('User document with all subcollections created successfully');
    } catch (e) {
      print('Error creating user record: $e');
      rethrow;
    }
  }
  //get user details
  Future<UserModel> fetchUserDetails() async {
    try {
      // Fetch document from Firestore
      final documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(AuthenticationRepository.instance.authUser?.uid).get();
      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw FirebaseException(code: e.code, plugin: '',message: e.message);
    } on FormatException catch (_) {
      throw const FormatException('Invalid data format');
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code, message: e.message);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  /// Updates user data in the Firestore collection 'Users'.
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db.collection("Users").doc(updatedUser.uid).update(updatedUser.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    } on FormatException catch (_) {
      throw Exception();
    } on PlatformException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  /// Updates a single field/fields in a user doc in 'Users' collection.
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db.collection("Users").doc(AuthenticationRepository.instance.authUser?.uid).update(json);
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    } on FormatException catch (_) {
      throw Exception();
    } on PlatformException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Something went wrong. Please try again');
    }
  }
  // Function to delete user account and Firestore record
  Future<void> deleteUser(String userId) async {
    try {
      // Delete the user's Firestore record
      await _db.collection("Users").doc(userId).delete();

      // Delete the user's account from Firebase Authentication
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      } else {
        throw Exception('No user is currently signed in.');
      }
      // Optionally, redirect/notify the user
      Get.offAll(() => const LoginPage());
      kLoaders.successSnackBar(
          title: 'Account Deleted', message: 'Your account has been successfully deleted.');
      Get.to(const LoginPage(),duration: const Duration(seconds: 2),transition: Transition.leftToRightWithFade);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            'This operation is sensitive and requires recent authentication. Please log in again.');
      }
      throw Exception(e.message ?? 'An error occurred while deleting the account.');
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firestore error occurred while deleting the account.');
    } catch (e) {
      throw Exception('Something went wrong while deleting the account: $e');
    }
  }
  Future<String> getShopName(String sellerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerId)
        .get();
    return doc['shopName'] ?? 'ArtsWell'; // Default fallback
  }
  ///func to upload img to fb
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
    try {
      await ProductRepository.instance.ensureSeller();

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
          data['primaryImageIndex'] = 0;
        }
      }

      debugPrint('Updating product $id with data: $data');

      await _db.collection('products').doc(id).update(data);
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  ///for ordersPlaced array
  Future<void> addSaleToSeller(String sellerId, String amountString) async {
    try {
      // 1. Validate inputs
      if (sellerId.isEmpty) throw 'Invalid seller ID';
      if (double.tryParse(amountString) == null) throw 'Invalid amount format';

      // 2. Use transaction for data consistency
      await _db.runTransaction((transaction) async {
        final sellerRef = _db.collection('Users').doc(sellerId);
        final doc = await transaction.get(sellerRef);

        if (!doc.exists) throw 'Seller not found';

        // 3. Update sales data
        transaction.update(sellerRef, {
          'ordersPlaced': FieldValue.arrayUnion([amountString]),
          'totalSales': FieldValue.increment(double.parse(amountString)),
          'lastSale': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw 'Firestore error: ${e.code}';
    } catch (e) {
      throw 'Failed to update sales: ${e.toString()}';
    }
  }

  Future<List<double>> getSellerSales(String sellerId) async {
    try {
      final doc = await _db.collection('Users').doc(sellerId).get();
      final amounts = List<String>.from(doc['ordersPlaced'] ?? []);
      return amounts.map((a) => double.parse(a)).toList();
    } catch (e) {
      throw 'Failed to fetch sales: ${e.toString()}';
    }
  }
  /// Upload any Image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw (e.code);
    } on FormatException catch (_) {
      throw const FormatException();
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}