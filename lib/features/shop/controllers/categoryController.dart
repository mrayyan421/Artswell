import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import 'package:artswellfyp/data/repositories/categoryRepository/categoryRepository.dart';
import 'package:artswellfyp/features/authentication/controllers/initialScreenControllers.dart';
import 'package:artswellfyp/features/shop/models/categoryModel.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController{
  ///vars
  static CategoryController get instance=> Get.find();
  final _cateoryRepository=Get.put(CategoryRepository());
  final isLoading=false.obs;
  RxList<CategoryModel>allCategories=<CategoryModel>[].obs;
  RxList<CategoryModel>featuredCategories=<CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }
  ///load category data
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      // ✅ Use your AuthenticationRepository
      final authRepo = AuthenticationRepository.instance;

      if (authRepo.authUser == null) {
        // Not logged in — you can redirect to login or return
        kLoaders.errorSnackBar(title: "Auth Error", message: "Please log in to view categories.");
        AppLandingController.instance.loginPageNavigation();
        // Get.offAll(() => const LoginPage()); // or Applanding() based on your flow
        return;
      }

      // 🔓 User is authenticated — proceed to fetch categories
      final categories = await _cateoryRepository.getAllCategories();

      allCategories.assignAll(categories);
      isLoading.value=false;
      featuredCategories.assignAll(
        allCategories.where((category) => category.isFeatured && category.parentId.isEmpty),
      );
    } catch (e) {
      print(e);
      kLoaders.errorSnackBar(title: 'Dang it...', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

}