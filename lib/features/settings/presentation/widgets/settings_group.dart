import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

/// A titled group of settings rows rendered inside a single rounded card,
/// matching the grouped-card layout of the Settings screen.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal + AppSpacing.xs,
            0,
            AppSpacing.pageHorizontal,
            AppSpacing.md,
          ),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(
              color: LightThemeColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          decoration: BoxDecoration(
            color: LightThemeColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: LightThemeColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.huge + AppSpacing.sm,
                    color: LightThemeColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
