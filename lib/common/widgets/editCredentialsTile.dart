import 'package:flutter/material.dart';

import '../../utils/theme/theme.dart';

class editCredentialsTile extends StatelessWidget {
  const editCredentialsTile({
    super.key,
    required this.title,
    required this.value,
    required this.imgPath,
    required this.onTap
  });
  final String title,value,imgPath;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
      Expanded(flex:3,child: Text(title,style: kAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: Colors.white),)),
      Expanded(flex:6,child: Text(value,style: kAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: Colors.white,fontStyle: FontStyle.italic)),),
      GestureDetector(onTap:onTap,child: Expanded(flex:1,child: Image.asset(imgPath,height: 35,),),),
    ],);
  }
}