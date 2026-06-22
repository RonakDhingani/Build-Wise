import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_option_tile.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final current = settings.valueOrNull?.theme ?? AppThemeMode.light;

    return AppScaffold(
      appBar: const AppBarWidget(title: 'Theme'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        children: [
          SettingsCard(
            children: [
              SettingsOptionTile(
                title: 'Light',
                subtitle: 'Default light appearance',
                selected: current == AppThemeMode.light,
                onTap: () => ref
                    .read(settingsNotifierProvider.notifier)
                    .updateTheme(AppThemeMode.light),
              ),
              const SettingsOptionTile(
                title: 'Dark',
                subtitle: 'Dark appearance',
                trailingBadge: 'Coming soon',
                selected: false,
                enabled: false,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal + AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.pageHorizontal,
              0,
            ),
            child: _ThemeNote(),
          ),
        ],
      ),
    );
  }
}

class _ThemeNote extends StatelessWidget {
  const _ThemeNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Dark mode is not available in this version. Light mode keeps BuildWise '
      'clear and easy to read on site.',
      style: AppTextStyles.bodySmall.copyWith(
        color: LightThemeColors.textTertiary,
        height: 1.4,
      ),
    );
  }
}
