import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'remote_config_constants.dart';
import 'remote_config_exception.dart';
import 'remote_config_logger.dart';
import 'remote_config_model.dart';

/// Thin, reusable wrapper around [FirebaseRemoteConfig]. Owns settings, defaults,
/// fetch/activate and maps raw values into a typed [RemoteConfigModel].
/// No UI, no business decisions — those live in the repository / checker.
class RemoteConfigService {
  RemoteConfigService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: RemoteConfigTuning.fetchTimeout,
          minimumFetchInterval: kDebugMode
              ? RemoteConfigTuning.minFetchIntervalDebug
              : RemoteConfigTuning.minFetchIntervalRelease,
        ),
      );
      await _remoteConfig.setDefaults(RemoteConfigDefaults.values);
      RcLog.success('Initialization Success');
    } catch (e) {
      RcLog.error('Initialization Failed', e);
      throw RemoteConfigException('Failed to initialize Remote Config', e);
    }
  }

  /// Fetch + activate. Returns true if new values were activated.
  Future<bool> fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      RcLog.success('Fetch Success', 'activated=$activated');
      return activated;
    } catch (e) {
      RcLog.error('Fetch Failed', e);
      throw RemoteConfigException('Failed to fetch Remote Config', e);
    }
  }

  /// Typed snapshot of the currently active values.
  RemoteConfigModel getModel() {
    if (kDebugMode) _logSources();
    String s(String k) => _remoteConfig.getString(k);
    bool b(String k) => _remoteConfig.getBool(k);

    return RemoteConfigModel(
      latestVersion: s(RemoteConfigKeys.latestVersion),
      minRequiredVersion: s(RemoteConfigKeys.minRequiredVersion),
      updateTitle: s(RemoteConfigKeys.updateTitle),
      updateMessage: s(RemoteConfigKeys.updateMessage),
      releaseNotes: s(RemoteConfigKeys.releaseNotes),
      androidStoreUrl: s(RemoteConfigKeys.androidStoreUrl),
      iosStoreUrl: s(RemoteConfigKeys.iosStoreUrl),
      maintenanceEnabled: b(RemoteConfigKeys.maintenanceEnabled),
      maintenanceTitle: s(RemoteConfigKeys.maintenanceTitle),
      maintenanceMessage: s(RemoteConfigKeys.maintenanceMessage),
    );
  }

  // ---- Generic accessors for future feature flags (no model change needed) --
  bool getBool(String key) => _remoteConfig.getBool(key);
  String getString(String key) => _remoteConfig.getString(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);

  /// Debug-only: print every default key's value + source (remote/default/static).
  void _logSources() {
    for (final key in RemoteConfigDefaults.values.keys) {
      final v = _remoteConfig.getValue(key);
      RcLog.info('value', '$key="${v.asString()}" (${v.source.name})');
    }
  }
}
