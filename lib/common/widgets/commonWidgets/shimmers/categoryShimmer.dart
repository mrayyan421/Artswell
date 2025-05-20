import 'package:artswellfyp/common/widgets/commonWidgets/shimmers/shimmerEffect.dart';
import 'package:flutter/material.dart';
import 'package:artswellfyp/utils/constants/size.dart';

class kCategoryShimmer extends StatelessWidget {
  const kCategoryShimmer({
    super.key,
    this.itemCount = 6,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: kSizes.mediumPadding),
        itemBuilder: (_, __) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ShimmerEffect(width: 55, height: 55, radius: 55),
              SizedBox(height: kSizes.mediumPadding / 2),
              // Text
              ShimmerEffect(width: 55, height: 8),
            ],
          );
        },
      ),
    );
  }
}