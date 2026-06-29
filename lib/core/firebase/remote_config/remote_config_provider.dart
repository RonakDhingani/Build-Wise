import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_config_analytics.dart';
import 'remote_config_repository.dart';
import 'remote_config_service.dart';
import 'version_checker.dart';

/// Raw Firebase singletons.
final firebaseRemoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  return FirebaseRemoteConfig.instance;
});

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

/// Reusable service wrapper.
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(ref.read(firebaseRemoteConfigProvider));
});

/// Pure version-decision logic (injectable for tests).
final versionCheckerProvider = Provider<VersionChecker>((ref) {
  return const VersionChecker();
});

/// Analytics for the update/maintenance flow.
final remoteConfigAnalyticsProvider = Provider<RemoteConfigAnalytics>((ref) {
  return RemoteConfigAnalytics(ref.read(firebaseAnalyticsProvider));
});

/// Repository — single entry point for UI/lifecycle code.
final remoteConfigRepositoryProvider = Provider<RemoteConfigRepository>((ref) {
  return RemoteConfigRepository(
    service: ref.read(remoteConfigServiceProvider),
    checker: ref.read(versionCheckerProvider),
  );
});
