//TODO: Resusable class
import 'package:flutter/material.dart';
import 'package:artswellfyp/common/widgets/commonWidgets/titleText.dart';
import 'package:artswellfyp/utils/constants/size.dart';
import 'package:artswellfyp/utils/constants/colorConstants.dart';

import '../../../../common/widgets/circularContainer.dart';

class kBillingPaymentsSection extends StatelessWidget {
  final String selectedPaymentMethod;
  final String selectedPaymentIcon;
  final VoidCallback onChanged;

  const kBillingPaymentsSection({
    super.key,
    required this.selectedPaymentMethod,
    required this.selectedPaymentIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeading(
          title: 'Payment Method',
          showAction: true,
          btnTitle: 'Change',
          onPressed: onChanged,
        ),
        const SizedBox(height: kSizes.mediumPadding / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            kCircularContainer(
              width: 60,
              height: 35,
              backgroundColor: kColorConstants.klSearchBarColor,
              padding: const EdgeInsets.all(kSizes.smallPadding),
              showBorder: true,
              child: Image.asset(selectedPaymentIcon, fit: BoxFit.contain),
            ),
            const SizedBox(width: kSizes.mediumPadding / 2),
            Text(
              selectedPaymentMethod,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}