import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size,
    this.color,
    this.tooltip,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;
  final String? tooltip;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? AppDimensions.iconMd;
    final iconColor = color ?? LightThemeColors.textSecondary;

    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        width: AppDimensions.minTouchTarget,
        height: AppDimensions.minTouchTarget,
        alignment: Alignment.center,
        decoration: backgroundColor != null
            ? BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              )
            : null,
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
