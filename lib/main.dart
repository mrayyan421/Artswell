import 'package:artswellfyp/bindings/generalBindings.dart';
import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import 'package:artswellfyp/features/personalization/controllers/userController.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'data/repositories/categoryRepository/categoryRepository.dart';
import 'features/authentication/controllers/initialScreenControllers.dart';
import 'features/shop/controllers/productController.dart';
import 'firebase_options.dart';
import 'utils/theme/theme.dart';
import 'package:get/get.dart';

void main() async{
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value)=>Get.put(AuthenticationRepository()));
  Get.put(AppLandingController());
  final categoryRepo=Get.put(CategoryRepository());
  final userCtrl=Get.put(UserController());
  runApp(const EComApp());
  WidgetsBinding.instance.addPostFrameCallback((_){
    categoryRepo.convertAssetImagesToStorageUrls();
    userCtrl.toggleFavoriteProduct(ProductController().selectedProduct.value!.id);
  });}

class EComApp extends StatelessWidget {
  const EComApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: GeneralBindings(),
      themeMode: ThemeMode.system,
      theme: kAppTheme.lightTheme,
      // darkTheme: kAppTheme.darkTheme,
      // color: klPrimaryColor,
      home: const Scaffold(backgroundColor: kColorConstants.klAntiqueWhiteColor,body: Center(child: CircularProgressIndicator(color: kColorConstants.klSearchBarColor,),),),
      // LoginPage()
      // RegistrationPage()
    );
  }
}

