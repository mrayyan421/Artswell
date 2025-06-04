
import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/data/repositories/userRepository/userRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../authentication/models/userModels/userModel.dart';

class UserController extends GetxController {
  // Singleton instance
  static UserController get instance => Get.find();
  // Rx<UserModel> user=UserModel.empty().obs;
  final userRepository=Get.put(UserRepository());
  // var for loader when credentials being fetched
  final profileLoading=false.obs;
  // Rx<UserModel?> to hold the current user's data reactively
  Rx<UserModel> user = UserModel.empty().obs;
  //Rx<String> type of list to keep track of ids and display on fav screen
  final RxList<String> favoriteProductIds = <String>[].obs;
  final _db=FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }
  //func to get user data
  Future<void> fetchUserRecord() async {
    try{
      profileLoading.value=true;
      final user=await userRepository.fetchUserDetails();
      this.user(user);
      // profileLoading.value=false;
    }catch(e){
      user(UserModel.empty());
    }finally{
      profileLoading.value=false;
    }
  }
  /// Save user Record from any Registration provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      await fetchUserRecord(); // func called to update recent data
      if (userCredentials != null) {

        // Map Data to UserModel
        final user = UserModel(
          uid: userCredentials.user!.uid,
          fullName: userCredentials.user!.displayName??'',
          email: userCredentials.user!.email ?? '',
          phoneNumber: userCredentials.user!.phoneNumber ?? '',
          profilePic: userCredentials.user!.photoURL ?? '',
          role: 'Seller', createdAt: DateTime.now(),shopName: '',
        );


        // Save user data to the Firestore Database
        await userRepository.saveUserRecord(user);
        await fetchUserRecord();
      }
    } catch (e) {
      print('Error saving user record: $e');
      kLoaders.warningSnackBar(
        title: 'Data not saved',
        message: 'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }
  /// Favorite Products Function
  Future<void> toggleFavoriteProduct(String productId) async {
    try {
      if (user.value.uid.isEmpty) return;

      final currentFavorites = List<String>.from(user.value.favoriteProductIds);
      final isFavorite = currentFavorites.contains(productId);

      if (isFavorite) {
        currentFavorites.remove(productId);
      } else {
        currentFavorites.add(productId);
      }

      // Update local user
      user.value = UserModel(
        uid: user.value.uid,
        fullName: user.value.fullName,
        email: user.value.email,
        role: user.value.role,
        phoneNumber: user.value.phoneNumber,
        profilePic: user.value.profilePic,
        createdAt: user.value.createdAt,
        favoriteProductIds: currentFavorites,
        orderIds: user.value.orderIds,
        ordersPlaced: user.value.ordersPlaced
      );

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.value.uid)
          .update({
        'favoriteProductIds': currentFavorites,
      });

      kLoaders.successSnackBar(
        title: isFavorite ? 'Removed from favorites' : 'Added to favorites',
        message: isFavorite
            ? 'Product removed from your favorites'
            : 'Product added to your favorites',
      );
    } catch (e) {
      kLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update favorites: ${e.toString()}',
      );
    }
  }

  bool isProductFavorite(String productId) {
    return user.value.favoriteProductIds.contains(productId);
  }

  Future<List<String>> getFavoriteProductIds() async {
    await fetchUserRecord();
    return user.value.favoriteProductIds;
  }
  Future<void> fetchFavoriteProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        favoriteProductIds.value = List<String>.from(doc.data()?['favoriteProductIds'] ?? []);
      }
    }
  }

  uploadUserDP() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxHeight: 512, maxWidth: 512);
      if (image != null) {
        // Upload Image
        final imageUrl = await userRepository.uploadImage('Users/images/Profile/', image);
        // Update User Image Record
        Map<String, dynamic> json = {'profilePictureUrl': imageUrl};
        await userRepository.updateSingleField(json);

        user.value.profilePic=imageUrl;
       kLoaders.successSnackBar(title: 'Success!',message: 'Image uploaded');
      }
      }catch (e) {
      kLoaders.errorSnackBar(title: 'Snap', message: 'Something went wrong: $e');
    }
  }
}
