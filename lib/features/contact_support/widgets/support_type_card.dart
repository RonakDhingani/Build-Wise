import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

/// Tappable support-channel card (Support / Feature Request / Bug Report).
/// Tapping opens the email client — premium Material 3 styling.
class SupportTypeCard extends StatelessWidget {
  const SupportTypeCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightThemeColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: LightThemeColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimensions.avatarSm,
                height: AppDimensions.avatarSm,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(icon, color: iconColor, size: AppDimensions.iconSm),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: LightThemeColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.mail_outline_rounded,
                  color: LightThemeColors.textTertiary,
                  size: AppDimensions.iconMd),
            ],
          ),
        ),
      ),
    );
  }
}
