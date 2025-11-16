import 'package:flutter/material.dart';
import 'app_colors.dart';

class HoopsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double elevation;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const HoopsCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.elevation = 8,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: elevation,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

