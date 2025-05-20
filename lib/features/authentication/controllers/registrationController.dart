import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import 'package:artswellfyp/data/repositories/userRepository/userRepository.dart';
import 'package:artswellfyp/features/authentication/models/userModels/userModel.dart';
import 'package:artswellfyp/utils/helpers/fullScreenLoader.dart';
import 'package:artswellfyp/utils/http/networkManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/widgets/successScreen.dart';

class RegistrationController extends GetxController {
 static RegistrationController get instance => Get.find();
 // RegistrationController vars
 final fullName = TextEditingController(); // For fullname input
 final email = TextEditingController(); // For email input
 final password = TextEditingController(); // For password input
 final confirmPassword = TextEditingController(); // For confirm password input
 final phoneNumber = TextEditingController(); // For phone number input
 GlobalKey<FormState> registrationFormKey = GlobalKey<FormState>(); // Form validation key
 var userType = Rxn<String>(); //default=null,true=customer,false=seller
 var isTermsAccepted = false.obs; // Observable to track checkbox value

 // func to check matching passwords
 bool isPasswordMatching() {
  if (password.text != confirmPassword.text) {
   kLoaders.errorSnackBar(
    title: 'Password Mismatch',
    message: 'Passwords do not match. Please try again.',
   );
   return false; // Return false if passwords don't match
  }
  return true; // Return true if passwords match
 }
 // Function to check if the checkbox is checked
 bool isCheckboxChecked() {
  if (!isTermsAccepted.value) {
   kLoaders.errorSnackBar(
    title: 'Terms & Conditions',
    message: 'You must accept the Terms & Conditions to proceed.',
   );
   return false; // Return false if checkbox is not checked
  }
  return true; // Return true if checkbox is checked
 }

 // Registration method
 Future<void> register() async {
  bool isFormSubmitted = false; // Flag to track successful submission

  try {
   // Check if any user button is selected
   if (userType.value == null) {
    kLoaders.errorSnackBar(
     title: 'User Type Error',
     message: 'Please select whether you are registering as a Customer or a Seller.',
    );
    return; // Stop execution if no button is selected
   }

   // Validate form fields
   if (!registrationFormKey.currentState!.validate()) {
    kLoaders.errorSnackBar(
     title: 'Form Error',
     message: 'Please fill all required fields.',
    );
    return;
   }

   // Check if passwords match
   if (!isPasswordMatching()) return; // Stop execution if mismatch

   // Check if the checkbox is checked
   if (!isCheckboxChecked()) return; // Stop execution if not checked

   // Check internet connectivity
   final isConnected = await NetworkManager.instance.isConnected();
   if (!isConnected) {
    kLoaders.errorSnackBar(
     title: 'No Internet',
     message: 'Please check your connection.',
    );
    return;
   }

   // Show loading dialog
   FFullScreenLoader.openLoadingDialog(
    'Processing details',
    'assets/images/processing.gif',
   );

   isFormSubmitted = true;

   // Register user with email and password
   final userCredentials = await AuthenticationRepository().registerWithEmailAndPassword(email.text.trim(), password.text.trim());

   // Create user model
   final user = UserModel(
    uid: userCredentials.user!.uid,
    fullName: fullName.text.trim(),
    email: email.text.trim(),
    role: userType.string,
    createdAt: DateTime.now(),
   );

   // Save user record
   final userRepository = Get.put(UserRepository());
   await userRepository.saveUserRecord(user);

   // Hide the loading dialog
   FFullScreenLoader.hideLoading();

   // Navigate to the SuccessScreen
   Get.off(() => const SuccessScreen(
    subTitle: 'A verification email has been sent to your email address. Please verify your email to continue.',
    btnText: 'Continue',
   ));

  } catch (e) {
   kLoaders.errorSnackBar(
    title: 'Error',
    message: e.toString(),
   );
   FFullScreenLoader.hideLoading();
   final currentUser=FirebaseAuth.instance.currentUser;
   if(currentUser!=null){
   try{
    await UserRepository.instance.deleteUser(currentUser.uid);//delete user acct if registration fails
   }catch(e){
    kLoaders.errorSnackBar(title: 'Error',message: 'Failed to clear data. Kindly Contact Support');
   }
  }
   final userCredentials=await AuthenticationRepository().registerWithEmailAndPassword(email.text.trim(), password.text.trim());
   final user=UserModel(uid:userCredentials.user!.uid,fullName: fullName.text.trim(), email: email.text.trim(), role: userType.string, createdAt: DateTime.now());
   final userRepository=Get.put(UserRepository());
   await userRepository.saveUserRecord(user);
  }
 }
}
