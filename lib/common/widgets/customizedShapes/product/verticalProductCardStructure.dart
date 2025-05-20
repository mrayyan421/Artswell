import 'package:flutter/material.dart';

import '../../../../utils/constants/colorConstants.dart';
import '../../../../utils/constants/size.dart';
import '../../../../utils/theme/theme.dart';
import '../../commonWidgets/roundedImagePromotion.dart';

class VerticalFlutterCard extends StatelessWidget {
  const VerticalFlutterCard({
    super.key,
    this.isBidding = true,
    required this.labelText,
    required this.productImagePath,
    required this.priceText
  });

  final bool isBidding;
  final String labelText;
  final String productImagePath;
  final int priceText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(kSizes.smallestPadding),
              color: kColorConstants.klProductContainerBgColor,
              child: RoundedImagePromotion(
                img: productImagePath,
                width: kSizes.promotionImageWidth,
                height: kSizes.promotionImageHeight,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Positioned(
              top: 10,
              right: 2,
              child: isBidding
                  ? Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(225, 138, 1, 0.5),
                  borderRadius: BorderRadius.circular(kSizes.mediumPadding),
                ),
                child: Text(
                  'Biddable',
                  style: kAppTheme.lightTheme.textTheme.bodySmall,
                ),
              )
                  : const SizedBox.shrink(),
            ),
            Positioned(
              top: -1,
              left: -1,
              child: GestureDetector(
                child: const ImageIcon(AssetImage('assets/icons/favorite.png')),
                onTap: () {
                  // Call a private method to download colored favorite icon
                },
              ),
            ),
          ],
        ),
        Text(labelText), // Insert variable for this text
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Price:', style: kAppTheme.lightTheme.textTheme.titleMedium),
                Text(
                  'PKR $priceText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kAppTheme.lightTheme.textTheme.bodyMedium,
                ), // Insert final variable for this text as well
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Rating:', style: kAppTheme.lightTheme.textTheme.titleMedium),
                Row(
                  children: [for(int i=0;i<3;i++)
                        const ImageIcon(AssetImage('assets/icons/ratingIconUnColored.png'),),
                  ]
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}