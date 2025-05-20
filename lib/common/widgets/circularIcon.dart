import 'package:flutter/material.dart';
import '../../utils/constants/colorConstants.dart';
import '../../utils/constants/size.dart';

class kCircularIcon extends StatelessWidget {
  const kCircularIcon({
    super.key,
    required this.icon,
    this.width,
    this.height,
    this.size = kSizes.largeIcon,
    this.color,
    this.onPressed,
    this.backgroundColor,
    this.isFavorite = false, // Receive state from parent instead of managing it
  });

  final double? width, height, size;
  final String icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final bool isFavorite; // Parent manages favorite state

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor != null
            ? const Color.fromRGBO(0, 0, 0, 0.9)
            : const Color.fromRGBO(255, 255, 255, 0.9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: ImageIcon(
          AssetImage(icon),
          color: isFavorite ? Colors.red : color ?? kColorConstants.klAntiqueWhiteColor,
          size: size,
        ),
      ),
    );
  }
}