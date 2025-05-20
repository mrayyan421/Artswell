import 'package:flutter/material.dart';
import '../../utils/theme/theme.dart';

class textWidgetRegistrationScreen extends StatelessWidget {
  const textWidgetRegistrationScreen({super.key, required this.text,required this.clr});
  final String text;
  final Color clr;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      // 'I have read and accept the',
      style: kAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
        color: clr,
        fontStyle: FontStyle.italic,
        fontFamily: 'assets/fonts/Poppins/Poppins-Thin',
        fontSize: 12
      ),
    );
  }
}
