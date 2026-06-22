import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'app_primary_button.dart';

/// Full-width primary action pinned to the bottom of a screen, with a top
/// divider and bottom safe-area padding. Used for "+ Add Expense" etc.
class AppBottomButton extends StatelessWidget {
  const AppBottomButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.md,
          AppSpacing.pageHorizontal,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: LightThemeColors.surface,
          border: Border(top: BorderSide(color: LightThemeColors.border)),
        ),
        child: AppPrimaryButton(label: label, onPressed: onPressed),
      ),
    );
  }
}
