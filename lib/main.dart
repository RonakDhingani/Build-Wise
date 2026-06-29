import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/isar_service.dart';
import 'features/app/lifecycle/app_lifecycle_handler.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'firebase_options.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'utils/currency_formatter.dart';
import 'utils/date_formatter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase init — guarded so the offline-first app still boots if the
  // platform config (google-services.json / GoogleService-Info.plist) is missing.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Analytics so Remote Config A/B experiments work (otherwise
    // Remote Config logs "Analytics SDK is not available").
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  await IsarService.init();
  runApp(
    const ProviderScope(
      child: AppLifecycleHandler(child: BuildWiseApp()),
    ),
  );
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
