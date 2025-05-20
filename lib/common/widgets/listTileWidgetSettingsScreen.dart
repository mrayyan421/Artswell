import 'package:artswellfyp/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class SettingsListTileWidget extends StatelessWidget {
  const SettingsListTileWidget({
    super.key,required this.precedingIcon,required this.title,required this.subtitle,this.trailing,this.onTap
  });
  final String precedingIcon;
  final String title,subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap:onTap,child: ListTile(leading: Image.asset(precedingIcon,height: 35,width: 35,),trailing: trailing,title: Text(title,style: kAppTheme.lightTheme.textTheme.titleSmall?.copyWith(fontSize: 15),),subtitle: Text(subtitle,style: kAppTheme.lightTheme.textTheme.bodySmall,),));
  }
}