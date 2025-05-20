// lib/widgets/rounded_image_promotion.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RoundedImagePromotion extends StatelessWidget {
  final String img;
  final double width;
  final double height;
  final bool isNetworkImg;
  final BorderRadius borderRadius;

  const RoundedImagePromotion({
    super.key,
    required this.img,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.isNetworkImg=true
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child:isNetworkImg? CachedNetworkImage(imageUrl: img,  placeholder: (context, url) => const CircularProgressIndicator(),fit: BoxFit.cover,width: width,height: height,): Image.asset(img, width: width,height: height, fit: BoxFit.cover,),
      ),
    );
  }
}
