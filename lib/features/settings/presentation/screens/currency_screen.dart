import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_constants.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_spacing.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_option_tile.dart';

class CurrencyScreen extends ConsumerWidget {
  const CurrencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final current = settings.valueOrNull?.currencyCode;

    return AppScaffold(
      appBar: const AppBarWidget(title: 'Currency'),
      body: settings.when(
        loading: () => const AppLoadingWidget(),
        error: (_, _) =>
            const AppErrorState(message: 'Failed to load settings.'),
        data: (_) => ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          children: [
            SettingsCard(
              children: [
                for (final opt in AppConstants.currencyOptions)
                  SettingsOptionTile(
                    title: '${opt.symbol}  ${opt.label}',
                    subtitle: opt.code,
                    selected: current == opt.code,
                    onTap: () => ref
                        .read(settingsNotifierProvider.notifier)
                        .updateCurrency(opt.code, opt.symbol),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
