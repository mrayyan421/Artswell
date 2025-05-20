import 'package:flutter/material.dart';

import '../../../utils/theme/theme.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key, this.textColor,this.showAction=false, required this.title, this.btnTitle='View all',this.onPressed,
  });

  final Color? textColor;
  final bool showAction;
  final String title,btnTitle;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title,style: kAppTheme.lightTheme.textTheme.headlineSmall?.apply(color: textColor),maxLines: 1,overflow: TextOverflow.ellipsis),
      if(showAction)TextButton(onPressed: onPressed, child: Text(btnTitle))
    ],);
  }
}