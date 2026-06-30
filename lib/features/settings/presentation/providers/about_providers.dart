import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/remote_config/remote_config_provider.dart';
import '../../../../core/firebase/remote_config/version_checker.dart';
import '../../data/about_actions.dart';

/// Rate / Share / store actions for the About screen.
final aboutActionsProvider = Provider<AboutActions>((ref) {
  return AboutActions(ref.read(remoteConfigRepositoryProvider));
});

/// Live update status for the About card. Refreshes Remote Config then returns
/// the version decision (up to date / optional / forced).
final aboutUpdateProvider = FutureProvider.autoDispose<UpdateDecision>((ref) async {
  final repo = ref.read(remoteConfigRepositoryProvider);
  await repo.refresh(force: true);
  return repo.currentDecision();
});
