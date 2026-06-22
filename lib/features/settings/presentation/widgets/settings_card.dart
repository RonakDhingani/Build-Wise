import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

/// A rounded surface card that stacks [children] with full-width dividers
/// between them. Used to host option lists (Currency, Date Format, Theme,
/// Default Project).
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children, this.margin});

  final List<Widget> children;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
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
              Divider(height: 1, color: LightThemeColors.border),
          ],
        ],
      ),
    );
  }
}
