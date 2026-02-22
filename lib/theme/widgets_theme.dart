import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Carte élégante style Notion - Design minimaliste
class HoopsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double elevation;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final bool hasBorder;

  const HoopsCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12,
    this.elevation = 4,
    this.color,
    this.margin,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder
            ? Border.all(color: AppColors.borderDark, width: 1)
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: elevation,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Bouton style Notion - Élégant et subtil
class NotionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary;
  final EdgeInsetsGeometry? padding;

  const NotionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.isPrimary = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primaryBlue : AppColors.surfaceHover,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: DefaultTextStyle(
            style: TextStyle(
              color: isPrimary ? AppColors.textOnAccent : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Chip/Tag style Notion
class NotionTag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const NotionTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.tagGray,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
