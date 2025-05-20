import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/constants/colorConstants.dart';
import '../../utils/constants/size.dart';
import '../../utils/theme/theme.dart';
import 'commonWidgets/shimmers/shimmerEffect.dart';

class VerticalTextWidget extends StatelessWidget {
  const VerticalTextWidget({
    super.key,
    required this.img,
    required this.title,

    this.onTap,
  });

  final String img, title;
  final VoidCallback? onTap;

  bool get _isNetwork => img.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: kSizes.mediumPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: kSizes.largeIcon*0.8,
              backgroundColor: kColorConstants.klAntiqueWhiteColor,
              child: ClipOval(
                child: _isNetwork
                    ? CachedNetworkImage(
                  imageUrl: img,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerEffect(width: 50, height: 50),
                  errorWidget: (_, __, ___) => const ImageIcon(
                    AssetImage('assets/icons/warning.png'),
                    color: kColorConstants.klErrorColor,
                  ),
                )
                : Image.asset(
                  img,
                  fit: BoxFit.cover,
                  width: kSizes.largeIcon * 2,
                  height: kSizes.largeIcon * 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: kAppTheme.lightTheme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
