import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? solidColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? customShadow;
  final bool hasGlow;
  final Color glowColor;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.solidColor,
    this.borderRadius = 26.0,
    this.padding = const EdgeInsets.all(20.0),
    this.margin,
    this.onTap,
    this.border,
    this.customShadow,
    this.hasGlow = false,
    this.glowColor = AppColors.electricBlue,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: solidColor ?? (gradient == null ? AppColors.deepNavy : null),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: AppColors.borderLight,
              width: 1.0,
            ),
        boxShadow: customShadow ??
            [
              if (hasGlow)
                BoxShadow(
                  color: glowColor.withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
