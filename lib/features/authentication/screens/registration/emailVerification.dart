import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import 'package:artswellfyp/features/authentication/controllers/verifyEmailController.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/theme/theme.dart';

class VerifyEmail extends StatelessWidget {
  const VerifyEmail({super.key,this.email});
  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller=Get.put(VerifyEmailController());
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,automaticallyImplyLeading: false,actions: [Padding(
        padding: const EdgeInsets.only(right: kSizes.largePadding),
        child: IconButton(onPressed: ()=>AuthenticationRepository.instance.logout(), icon: Image.asset('assets/icons/close.png')),
      )],),
      body: SingleChildScrollView(scrollDirection: Axis.vertical,child: Padding(padding:const EdgeInsets.all(kSizes.largePadding),child: Column(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: <Widget>[
      Image.asset('assets/images/emailSent.gif',width: kDeviceComponents.screenWidth(context)*0.85,),
      Text('Verify your email address...',style: kAppTheme.lightTheme.textTheme.titleLarge,),
        const SizedBox(height: kSizes.largePadding,),
      Text(email??'',textAlign:TextAlign.center,style: kAppTheme.lightTheme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w200,fontSize: 20,fontStyle: FontStyle.italic),),
      const SizedBox(height: kSizes.largePadding,),
      Text('Brilliant! Lets get your email checked & verified to start your seemless ECommerce journey.',style: kAppTheme.lightTheme.textTheme.bodySmall,textAlign: TextAlign.center,),
      SizedBox(height: kDeviceComponents.screenHeight(context)*0.1,),
      SizedBox(width: double.infinity,child: ElevatedButton(onPressed: ()=>controller.manuallyCheckVerifiedEmail()/*AppLandingController.instance.successPageNavigation()*/, child: const Text('Continue'),),),
      SizedBox(width: double.infinity,child: TextButton(onPressed: ()=>controller.sendEmailVerification(), child: const Text('Resend email'),),)
              ],),),),
      );
  }
}
