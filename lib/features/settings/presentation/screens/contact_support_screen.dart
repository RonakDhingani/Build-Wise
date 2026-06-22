import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../constants/app_constants.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(title: 'Contact Support'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: AppDimensions.avatarLg,
              height: AppDimensions.avatarLg,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
              child: const Icon(
                Icons.headset_mic_outlined,
                size: AppDimensions.iconLg,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text('We\'re here to help', style: AppTextStyles.titleLarge),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              'Email our support team and we\'ll get back to you.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: LightThemeColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: LightThemeColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: LightThemeColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, color: LightThemeColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email Support', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        AppConstants.supportEmail,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: LightThemeColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'Copy Email Address',
            icon: Icons.copy_rounded,
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: AppConstants.supportEmail),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Email address copied.')),
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
