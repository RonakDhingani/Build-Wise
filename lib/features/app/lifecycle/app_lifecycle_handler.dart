import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app/version_store.dart';
import '../../../core/firebase/remote_config/remote_config_analytics.dart';
import '../../../core/firebase/remote_config/remote_config_logger.dart';
import '../../../core/firebase/remote_config/remote_config_provider.dart';
import '../../../core/firebase/remote_config/remote_config_repository.dart';
import '../../../core/firebase/remote_config/version_checker.dart';
import '../../../navigation/app_router.dart';
import '../../../shared/widgets/dialogs/app_maintenance_dialog.dart';
import '../../../shared/widgets/dialogs/app_update_dialog.dart';

/// Drives Remote Config update/maintenance checks on **startup** and every
/// **resume** — without blocking startup. Startup evaluates the cached config
/// instantly, then refreshes from the network in the background and re-evaluates
/// if values changed. Resume refreshes (throttled) then re-evaluates.
class AppLifecycleHandler extends ConsumerStatefulWidget {
  const AppLifecycleHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLifecycleHandler> createState() =>
      _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends ConsumerState<AppLifecycleHandler>
    with WidgetsBindingObserver {
  bool _initialized = false;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _run();
  }

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    RcLog.info('Check triggered', _initialized ? 'app resumed' : 'app startup');
    try {
      final repo = ref.read(remoteConfigRepositoryProvider);
      final analytics = ref.read(remoteConfigAnalyticsProvider);

      if (!_initialized) {
        // Persist installed version (captures the upgrade path for support).
        // ignore: unawaited_futures
        ref.read(versionStoreProvider).record();
        // Fast path — no network. Decide on cached/default values immediately.
        await repo.initialize();
        _initialized = true;
        _evaluate(repo, analytics, repo.currentDecision());
        // Then fetch fresh values in the background and re-evaluate.
        // ignore: unawaited_futures
        repo.refresh(force: true).then((changed) {
          if (changed && mounted) {
            _evaluate(repo, analytics, repo.currentDecision());
          }
        });
      } else {
        // Resume — force a refetch so published console changes apply
        // immediately. The Remote Config SDK's own minimumFetchInterval still
        // protects quota (0 in debug, 30 min in release).
        await repo.refresh(force: true);
        _evaluate(repo, analytics, repo.currentDecision());
      }
    } catch (e) {
      RcLog.error('Lifecycle check failed', e);
    } finally {
      _running = false;
    }
  }

  /// True once the app is past the splash route (so a dialog won't be torn
  /// down by the splash -> home navigation).
  bool _onRealScreen() {
    final path = appRouter.routerDelegate.currentConfiguration.uri.path;
    return path != AppRoutePaths.root;
  }

  /// Run [action] now if past splash, else once the next non-splash route lands.
  void _whenPastSplash(VoidCallback action) {
    if (_onRealScreen()) {
      action();
      return;
    }
    final delegate = appRouter.routerDelegate;
    void listener() {
      if (_onRealScreen()) {
        delegate.removeListener(listener);
        action();
      }
    }

    delegate.addListener(listener);
  }

  void _evaluate(
    RemoteConfigRepository repo,
    RemoteConfigAnalytics analytics,
    UpdateDecision decision,
  ) {
    // Defer until the splash screen has navigated away, otherwise the route
    // change closes the dialog the moment it appears.
    if (!_onRealScreen()) {
      _whenPastSplash(() => _evaluate(repo, analytics, decision));
      return;
    }

    // Close any stale dialog the latest config no longer warrants
    // (e.g. min lowered / maintenance turned off while app was backgrounded).
    if (!repo.isMaintenanceMode()) AppMaintenanceDialog.dismiss();
    if (!decision.shouldPrompt) AppUpdateDialog.dismiss();

    // Maintenance blocks everything.
    if (repo.isMaintenanceMode()) {
      final cfg = repo.getCurrentConfig();
      RcLog.info('Maintenance Enabled');
      analytics.maintenanceMode();
      _present((ctx) => AppMaintenanceDialog.show(
            ctx,
            title: cfg.maintenanceTitle,
            message: cfg.maintenanceMessage,
            onRetry: () async {
              await repo.refresh(force: true);
              return !repo.isMaintenanceMode();
            },
          ));
      return;
    }

    if (decision.shouldPrompt) {
      RcLog.success('Update Dialog Shown',
          decision.isForced ? 'FORCED' : 'optional');
      analytics.updateDialogShown(
          forced: decision.isForced, latest: decision.targetVersion);
      _present((ctx) => AppUpdateDialog.show(
            ctx,
            decision: decision,
            onUpdate: () {
              analytics.updateClicked(decision.targetVersion);
              repo.openStore();
            },
            onLater: () => analytics.updateLater(decision.targetVersion),
          ));
    } else {
      RcLog.success('Up to date — no dialog');
    }
  }

  /// Show on the next frame so the freshly-navigated route's overlay exists
  /// (showing mid-route-swap can drop the dialog).
  void _present(void Function(BuildContext ctx) show) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) show(ctx);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
