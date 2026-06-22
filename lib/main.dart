import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/isar_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'utils/currency_formatter.dart';
import 'utils/date_formatter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init();
  runApp(const ProviderScope(child: BuildWiseApp()));
}

class BuildWiseApp extends ConsumerWidget {
  const BuildWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Apply currency/date-format settings app-wide. Watching here rebuilds the
    // whole app (so every screen re-formats) whenever the user changes them.
    final settings = ref.watch(settingsNotifierProvider).valueOrNull;
    if (settings != null) {
      CurrencyFormatter.symbol = settings.currencySymbol;
      DateFormatter.pattern = settings.dateFormat;
    }

    return MaterialApp.router(
      title: 'BuildWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
