import 'package:flutter/material.dart';

import '../../../../constants/app_constants.dart';
import '../../../../constants/app_strings.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(title: 'About'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Container(
              width: AppDimensions.avatarLg + AppSpacing.lg,
              height: AppDimensions.avatarLg + AppSpacing.lg,
              decoration: BoxDecoration(
                color: LightThemeColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
              child: Icon(
                Icons.architecture_rounded,
                size: AppDimensions.iconLg,
                color: LightThemeColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(AppStrings.appName, style: AppTextStyles.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              AppStrings.tagline,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightThemeColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          _InfoRow(label: 'App Name', value: AppStrings.appName),
          _InfoRow(label: 'Version', value: AppConstants.appVersion),
          _InfoRow(label: 'Build Number', value: AppConstants.buildNumber),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightThemeColors.textSecondary,
            ),
          ),
          Text(value, style: AppTextStyles.titleSmall),
        ],
      ),
    );
  }
}
