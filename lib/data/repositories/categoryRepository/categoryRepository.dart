import 'package:artswellfyp/features/shop/models/categoryModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../utils/helpers/firebaseStorageService.dart';

class CategoryRepository extends GetxController{

  static CategoryRepository get instance =>Get.find();

  //CategoryRepository Vars
  final _db=FirebaseFirestore.instance;

  //Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Categories').get();
      final list = snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
      return list;
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load categories. Please try again');
    }
  }
  //To upload dummy data
  /// Upload Categories to the Cloud Firebase
  Future<void> convertAssetImagesToStorageUrls() async {
    final storage = Get.find<KFirebaseStorageService>();
    final batch   = FirebaseFirestore.instance.batch();
    final snap    = await _db.collection('Categories').get();

    for (var doc in snap.docs) {
      final data         = doc.data();
      final localPath    = data['Image'] as String? ?? '';
      final isStillAsset = localPath.startsWith('assets/');

      if (!isStillAsset) continue; // already a URL, skip

      final imageBytes = await storage.getImageFromAssets(localPath);
      final imageUrl   = await storage.uploadImageData('Categories', imageBytes, doc.id,);// use doc.id or a safe slug for uniqueness);

      // stage the update
      batch.update(doc.reference, {'Image': imageUrl});
    }

    // commit all updates in one go
    await batch.commit();
  }


/*Future<void> uploadDummyData(List<CategoryModel> categories) async {
    try {
      // Upload all the Categories along with their Images
      final storage = Get.put(KFirebaseStorageService());

      // Loop through each category
      for (var category in categories) {
        // Get image data link from the local assets
        final file = await storage.getImageFromAssets(category.image);

        // Upload Image and Get its URL
        final url = await storage.uploadImageData('Categories', file, category.name);

        // Assign URL to Category.image attribute
        category.image = url;

        // Store Category in Firestore
        await _db.collection('Categories').doc(category.id).set(category.toJson());
      }
    } on FirebaseException catch (e) {
      throw FirebaseException(message:e.message,plugin: '');
    } on PlatformException catch (e) {
      throw PlatformException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }*/

  //Get subCategories
  //upload categories to firestore
}