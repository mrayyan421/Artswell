import 'package:artswellfyp/bottomNavBar.dart';
import 'package:artswellfyp/features/authentication/screens/appLanding.dart';
import 'package:artswellfyp/features/authentication/screens/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../features/authentication/screens/registration/emailVerification.dart';

//TODO: Authentication repo for handling user authentication data

class AuthenticationRepository extends GetxController{
  static AuthenticationRepository get instance=>Get.find();
  final deviceStorage=GetStorage();
  final _auth=FirebaseAuth.instance;
  User? get authUser=>_auth.currentUser;//to get current authenticated user
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    screenRedirect();
  }
  //func for check if first time opening
  void screenRedirect() async {
    final user=_auth.currentUser;
    if(kDebugMode){//to test app in debug mode
      print('debugModeGetX');
      print(deviceStorage.read('isFirstTime'));
    }
    if(user!=null){
      if(user.emailVerified){
        Get.offAll(()=> const NavigationMenu());
      }else{
        Get.offAll(()=>VerifyEmail(email: _auth.currentUser?.email,));
      }
    }else{
      // Access local storage to check if the user is opening the app for the first time
      deviceStorage.writeIfNull('isFirstTime', true); // Set default value if not already set
      // Read the value and decide the screen to redirect to
      if (deviceStorage.read('isFirstTime') != true) {
        Get.offAll(() => const LoginPage()); // Show onboarding screen
      } else {
        Get.offAll(() => const Applanding()); // Show login screen
      }
    }
  }

  //  //func for user login with email pwd
  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FormatException {
      throw const FormatException();
    } on PlatformException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

//func to login with google
  Future<UserCredential> loginWithGoogle(String email, String password) async {
    try {
      final GoogleSignInAccount? googleAccount=await GoogleSignIn().signIn();//authenticationFlow
      final GoogleSignInAuthentication? googleAuth=await googleAccount?.authentication;//fetch auth details from the above request
      final credentials=GoogleAuthProvider.credential(//creating credentials
        accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
      );
     return await _auth.signInWithCredential(credentials);//return UserCredentials after sign in
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } on FormatException {
      throw const FormatException();
    } on PlatformException catch (e) {
      throw FirebaseAuthException(code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  //func for user registration with email pwd
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Exception handling logic
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already registered. Please use a different email.');
        case 'invalid-email':
          throw Exception('The email address is not valid. Please provide a valid email.');
        case 'weak-password':
          throw Exception('The password is too weak. Please choose a stronger password.');
        default:
          throw Exception('An error occurred: ${e.message}');
      }
    } on PlatformException catch (e) {
      throw Exception('Platform error: ${e.message}');
    }
  }
//func for sending verification email
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } on FormatException {
      throw const FormatException();
    } on PlatformException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  //func to logout
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginPage());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during logout');
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        code: e.code,
        message: e.message,
      );
    } on FormatException {
      throw const FormatException('Invalid format encountered');
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Platform-specific error occurred');
    } catch (e) {
      throw Exception('Something went wrong. Please try again: $e');
    }
  }

//func for reseting email
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception("The email address is invalid.");
      } else if (e.code == 'user-not-found') {
        throw Exception("No user found with this email.");
      } else {
        throw Exception(e.message);
      }
    } on PlatformException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}