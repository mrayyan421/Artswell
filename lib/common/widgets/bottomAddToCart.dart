import 'package:flutter/material.dart';

class kCircularItem extends StatefulWidget {
  final IconData icon;
  final double? sidm;
  final double? height;
  final double size;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;

  const kCircularItem({
    super.key,
    required this.icon,
    this.sidm,
    this.height,
    this.size = 10,
    this.onPressed,
    this.color,
    this.backgroundColor,
  });

  @override
  _kCircularItemState createState() => _kCircularItemState();
}

class _kCircularItemState extends State<kCircularItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.sidm,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color.fromRGBO(0, 0, 0, 0.9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
        onPressed: widget.onPressed,
        icon: Icon(
          widget.icon,
          color: widget.color ?? const Color.fromRGBO(255, 255, 255, 0.9),
          size: widget.size,
        ),
      ),
    );
  }
}