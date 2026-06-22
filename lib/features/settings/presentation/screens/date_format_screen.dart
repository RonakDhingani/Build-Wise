import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_constants.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/date_formatter.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_option_tile.dart';

class DateFormatScreen extends ConsumerWidget {
  const DateFormatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final current = settings.valueOrNull?.dateFormat;
    final sample = DateTime(2026, 3, 9);

    return AppScaffold(
      appBar: const AppBarWidget(title: 'Date Format'),
      body: settings.when(
        loading: () => const AppLoadingWidget(),
        error: (_, _) =>
            const AppErrorState(message: 'Failed to load settings.'),
        data: (_) => ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          children: [
            SettingsCard(
              children: [
                for (final opt in AppConstants.dateFormatOptions)
                  SettingsOptionTile(
                    title: opt.label,
                    subtitle: DateFormatter.format(sample, pattern: opt.pattern),
                    selected: current == opt.pattern,
                    onTap: () => ref
                        .read(settingsNotifierProvider.notifier)
                        .updateDateFormat(opt.pattern),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
