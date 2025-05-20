import 'package:artswellfyp/common/widgets/commonWidgets/shimmers/shimmerEffect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  const CircularImage({
    super.key,
    this.width = 56,
    this.height = 56,
    this.overlayColor,
    this.backgroundColor,
    required this.image,
    this.fit = BoxFit.cover,
    this.padding = 8,
    this.isNetworkImage = false,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(180),
      ),
      child: Center(
        child: isNetworkImage?CachedNetworkImage(fit:fit,color: overlayColor,imageUrl: image,progressIndicatorBuilder: (context,url,downloadProgress)=>const ShimmerEffect(width: 55, height: 55),errorWidget: (context,url,error)=>const ImageIcon(AssetImage('ecomfinal/assets/icons/warning.png')),):
        Image(
          fit: fit,
          image: AssetImage(image) as ImageProvider,
          color: overlayColor,
        ),
      ),
    );
  }
}