import 'package:flutter/material.dart';

/// Card personalizado y reutilizable
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? shadowColor;

  const CustomCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.gradient,
    this.elevation,
    this.onTap,
    this.borderRadius,
    this.border,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(16);
    
    // Determine effective background
    // If gradient is present, color is ignored by BoxDecoration usually, but we can have fallback.
    // If neither, use cardTheme color or white.
    final effectiveColor = color ?? (gradient == null ? theme.cardTheme.color ?? Colors.white : null);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveColor,
        gradient: gradient,
        borderRadius: radius,
        border: border ?? Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
        boxShadow: elevation != 0 
           ? [
              BoxShadow(
                color: (shadowColor ?? Colors.black).withValues(alpha: 0.05 * (elevation ?? 2)),
                blurRadius: (elevation ?? 2) * 4,
                offset: Offset(0, (elevation ?? 2) * 2),
              )
             ]
           : [],
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      );
    }

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: content,
    );
  }
}

