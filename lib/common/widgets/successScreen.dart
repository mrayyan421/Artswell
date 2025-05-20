import 'package:artswellfyp/common/styles/spacingStyle.dart';
import 'package:artswellfyp/data/repositories/authenticationRepository/authenticationRepository.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:flutter/material.dart';

//TODO: screen for Success msg with lotte animation

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key,required this.subTitle,required this.btnText});
  final String subTitle,btnText;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(padding: kSpacingStyle.paddingWithAppBarHeight,scrollDirection: Axis.vertical,
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // crossAxisAlignment: CrossAxisAlignment,
          children: [Image.asset('assets/images/success.gif',width: 350,height: 350),
          Text(subTitle,textAlign: TextAlign.center,),
          const SizedBox(height: kSizes.mediumPadding,),
          SizedBox(width: double.infinity,child: ElevatedButton(onPressed: ()=>AuthenticationRepository.instance.screenRedirect(), child: Text(btnText,style: kAppTheme.lightTheme.textTheme.labelMedium,)),)],),),
    );
  }
}
