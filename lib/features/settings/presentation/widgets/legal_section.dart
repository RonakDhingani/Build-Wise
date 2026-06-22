import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

/// Heading + paragraph block used by the Privacy Policy and Terms screens.
class LegalSection extends StatelessWidget {
  const LegalSection({super.key, required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightThemeColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
