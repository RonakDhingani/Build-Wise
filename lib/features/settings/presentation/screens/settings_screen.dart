import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_constants.dart';
import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../onboarding/presentation/walkthrough_controller.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return AppScaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            const _Header(),
            const SizedBox(height: AppSpacing.xl),

            // 1. Project Management
            SettingsGroup(
              title: 'Project Management',
              children: [
                SettingsTile(
                  icon: Icons.folder_outlined,
                  iconColor: LightThemeColors.primary,
                  title: 'Manage Projects',
                  subtitle: 'View, edit, archive or delete projects',
                  onTap: () => _go(context, AppRouteNames.manageProjects),
                ),
                SettingsTile(
                  icon: Icons.home_outlined,
                  iconColor: AppColors.navy400,
                  title: 'Default Project',
                  subtitle: 'Select project to open on app launch',
                  onTap: () => _go(context, AppRouteNames.defaultProject),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // 2. Categories & Masters
            SettingsGroup(
              title: 'Categories & Masters',
              children: [
                SettingsTile(
                  icon: Icons.local_offer_outlined,
                  iconColor: AppColors.violet,
                  title: 'Expense Categories',
                  subtitle: 'Add, edit, delete or reorder categories',
                  onTap: () => _go(context, AppRouteNames.expenseCategories),
                ),
                SettingsTile(
                  icon: Icons.inventory_2_outlined,
                  iconColor: AppColors.success500,
                  title: 'Material Master List',
                  subtitle: 'Manage materials used in your project',
                  onTap: () => _comingSoon(context, 'Material Master List'),
                ),
                SettingsTile(
                  icon: Icons.layers_outlined,
                  iconColor: AppColors.gold400,
                  title: 'Construction Stages',
                  subtitle: 'Add, edit, delete or reorder stages',
                  onTap: () => _comingSoon(context, 'Construction Stages'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // 3. Data Management
            SettingsGroup(
              title: 'Data Management',
              children: [
                SettingsTile(
                  icon: Icons.backup_outlined,
                  iconColor: AppColors.navy400,
                  title: 'Backup & Restore',
                  subtitle: 'Export, import and restore your data offline',
                  onTap: () => _go(context, AppRouteNames.dataManagement),
                ),
                SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  iconColor: AppColors.error500,
                  title: 'Reset Application',
                  subtitle: 'Clear all data and reset the app',
                  onTap: () => _comingSoon(context, 'Reset Application'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // 4. Preferences
            SettingsGroup(
              title: 'Preferences',
              children: [
                SettingsTile(
                  icon: Icons.currency_rupee_rounded,
                  iconColor: AppColors.gold400,
                  title: 'Currency',
                  subtitle: 'Set your preferred currency',
                  trailingValue: settings.valueOrNull?.currencyCode,
                  onTap: () => _go(context, AppRouteNames.currency),
                ),
                SettingsTile(
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.navy400,
                  title: 'Date Format',
                  subtitle: 'Choose your preferred date format',
                  trailingValue: _dateFormatLabel(settings.valueOrNull),
                  onTap: () => _go(context, AppRouteNames.dateFormat),
                ),
                SettingsTile(
                  icon: Icons.palette_outlined,
                  iconColor: AppColors.violet,
                  title: 'Theme',
                  subtitle: 'App theme and appearance',
                  trailingValue: _themeLabel(settings.valueOrNull),
                  onTap: () => _go(context, AppRouteNames.theme),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // 5. Help
            SettingsGroup(
              title: 'Help',
              children: [
                SettingsTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.info500,
                  title: 'Replay App Tour',
                  subtitle: 'See the onboarding walkthrough again',
                  onTap: () => ref
                      .read(walkthroughControllerProvider.notifier)
                      .beginReplay(projectId),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // 6. Support & Information
            SettingsGroup(
              title: 'Support & Information',
              children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.info500,
                  title: 'About BuildWise',
                  subtitle: 'App version and information',
                  onTap: () => _go(context, AppRouteNames.about),
                ),
                SettingsTile(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.success500,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () => _go(context, AppRouteNames.privacyPolicy),
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.gold400,
                  title: 'Terms & Conditions',
                  subtitle: 'Read our terms and conditions',
                  onTap: () => _go(context, AppRouteNames.terms),
                ),
                SettingsTile(
                  icon: Icons.headset_mic_outlined,
                  iconColor: AppColors.violet,
                  title: 'Contact Support',
                  subtitle: 'Get help or contact our support team',
                  onTap: () => _go(context, AppRouteNames.contactSupport),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String routeName) {
    context.pushNamed(
      routeName,
      pathParameters: {'id': projectId.toString()},
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is coming in a future update.')),
      );
  }

  String? _dateFormatLabel(AppSettingsEntity? s) {
    if (s == null) return null;
    for (final opt in AppConstants.dateFormatOptions) {
      if (opt.pattern == s.dateFormat) return opt.label;
    }
    return s.dateFormat;
  }

  String? _themeLabel(AppSettingsEntity? s) {
    if (s == null) return null;
    return s.theme == AppThemeMode.light ? 'Light' : 'Dark';
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal + AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.pageHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Manage your project and app settings',
            style: AppTextStyles.bodyMedium.copyWith(
              color: LightThemeColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
