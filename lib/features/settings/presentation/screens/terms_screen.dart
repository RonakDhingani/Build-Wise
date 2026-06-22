import 'package:flutter/material.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../widgets/legal_section.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(title: 'Terms & Conditions'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            'By using BuildWise you agree to the following terms.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightThemeColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const LegalSection(
            heading: 'Use of the App',
            body:
                'BuildWise is provided to help you track construction projects, '
                'expenses, and materials. You are responsible for the accuracy '
                'of the data you enter.',
          ),
          const LegalSection(
            heading: 'No Warranty',
            body:
                'The app is provided "as is" without warranties of any kind. '
                'Calculations and reports are aids, not professional financial '
                'or engineering advice.',
          ),
          const LegalSection(
            heading: 'Limitation of Liability',
            body:
                'We are not liable for any loss of data or damages arising from '
                'the use of this app. Keep your own backups of important data.',
          ),
        ],
      ),
    );
  }
}
