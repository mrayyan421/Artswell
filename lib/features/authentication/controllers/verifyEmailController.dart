import 'dart:async';

import 'package:artswellfyp/common/widgets/loaders/basicLoaders.dart';
import 'package:artswellfyp/common/widgets/successScreen.dart';
import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// TODO: Controller for email verification component

class VerifyEmailController extends GetxController{
  static VerifyEmailController get instance=>Get.find();
  @override
  void onInit() {
    // TODO: implement onInit for sending email when redirected to VerifyEmail()
    sendEmailVerification();
    autoRedirect();
    super.onInit();
  }
  //send email verification link
  sendEmailVerification()async{
    try{
      await AuthenticationRepository.instance.sendEmailVerification();
      kLoaders.successSnackBar(title: 'Email Sent',message: 'Check your mail and verify...');
    }catch(e){
      kLoaders.errorSnackBar(title: 'Dang it',message: e.toString());
    }
  }
  //func for redirecting automatically
  autoRedirect(){
    Timer.periodic(const Duration(seconds: 1), (timer)async{//keep calling func after interval of 1sec
      await FirebaseAuth.instance.currentUser?.reload();
      final user=FirebaseAuth.instance.currentUser;
      if(user?.emailVerified??false){
        timer.cancel();//if email verified timer stops. else email not verified, timer keeps on running repeatedly
        Get.offAll(const SuccessScreen(subTitle: 'Congatulations! Email Registered', btnText: 'Get Started with ArtsWell...'));
      }
    });
  }
  //func for checking if the email is verified or not
  manuallyCheckVerifiedEmail(){
    final currentUser= FirebaseAuth.instance.currentUser;
    if(currentUser!=null && currentUser.emailVerified){
      Get.offAll(const SuccessScreen(subTitle: 'Congatulations! Email Registered', btnText: 'Get Started by logging in...'));
    }
  }
}