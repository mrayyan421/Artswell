import 'package:artswellfyp/utils/device/deviceComponents.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/constants/colorConstants.dart';

class reviewProgressIndicator extends StatelessWidget {
  final String text;
  final double value;

  const reviewProgressIndicator({
    super.key,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          flex: 3,
          child: SizedBox(
            width: kDeviceComponents.screenWidth(context) * 0.8,
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: kColorConstants.kdGreyColor2,
              borderRadius: BorderRadius.circular(7),
              valueColor: const AlwaysStoppedAnimation<Color>(kColorConstants.klSearchBarColor),
            ),
          ),
        ),
      ],
    );
  }
}