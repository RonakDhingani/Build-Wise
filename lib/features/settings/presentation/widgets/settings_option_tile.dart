import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

/// A single-select option row (radio-style) used by Currency, Date Format,
/// Theme, and Default Project screens. Shows a check when [selected].
class SettingsOptionTile extends StatelessWidget {
  const SettingsOptionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingBadge,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? trailingBadge;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? LightThemeColors.textPrimary
        : LightThemeColors.textTertiary;

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(color: color),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: LightThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    trailingBadge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: LightThemeColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: LightThemeColors.primary,
                  size: AppDimensions.iconSm,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: LightThemeColors.border,
                  size: AppDimensions.iconSm,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
