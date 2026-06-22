import 'package:flutter/material.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../widgets/legal_section.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(title: 'Privacy Policy'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            'BuildWise stores all of your data locally on your device. We do '
            'not collect, transmit, or share any personal information.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightThemeColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const LegalSection(
            heading: 'Data Storage',
            body:
                'Your projects, expenses, materials, and settings are saved '
                'only on this device using an on-device database. Uninstalling '
                'the app permanently removes this data.',
          ),
          const LegalSection(
            heading: 'No Data Collection',
            body:
                'BuildWise has no user accounts, no analytics, and no network '
                'sync in this version. Nothing leaves your device unless you '
                'explicitly export and share a backup file.',
          ),
          const LegalSection(
            heading: 'Your Control',
            body:
                'You can edit or delete any record at any time. Resetting the '
                'application clears all stored data.',
          ),
        ],
      ),
    );
  }
}
