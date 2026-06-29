/// Centralised Firebase Remote Config keys, default values and tuning.
/// Never hardcode a key name elsewhere — reference [RemoteConfigKeys].
abstract class RemoteConfigKeys {
  // Version control (single shared keys — one value for all platforms).
  static const String latestVersion = 'latest_version';
  static const String minRequiredVersion = 'min_required_version';

  // Update dialog content.
  static const String updateTitle = 'update_title';
  static const String updateMessage = 'update_message';
  static const String releaseNotes = 'release_notes';

  // Store URLs (platform-resolved in code).
  static const String androidStoreUrl = 'android_store_url';
  static const String iosStoreUrl = 'ios_store_url';

  // Maintenance.
  static const String maintenanceEnabled = 'maintenance_enabled';
  static const String maintenanceTitle = 'maintenance_title';
  static const String maintenanceMessage = 'maintenance_message';
}

/// In-app defaults used until the first successful fetch and as an offline
/// safety net. `0.0.0` versions guarantee no false update prompt when Remote
/// Config is unreachable.
abstract class RemoteConfigDefaults {
  static const Map<String, Object> values = {
    RemoteConfigKeys.latestVersion: '0.0.0',
    RemoteConfigKeys.minRequiredVersion: '0.0.0',
    RemoteConfigKeys.updateTitle: 'Update Available',
    RemoteConfigKeys.updateMessage:
        'A new version of BuildWise is available with improvements and fixes.',
    RemoteConfigKeys.releaseNotes: '',
    RemoteConfigKeys.androidStoreUrl: 'https://play.google.com/store/apps/details?id=com.mybusrouting&pcampaignid=web_share',
    RemoteConfigKeys.iosStoreUrl: '',
    RemoteConfigKeys.maintenanceEnabled: false,
    RemoteConfigKeys.maintenanceTitle: 'Under Maintenance',
    RemoteConfigKeys.maintenanceMessage:
        'BuildWise is briefly down for maintenance. Please try again shortly.',
  };
}

/// Fetch tuning. Debug uses a 0-interval so console changes appear instantly;
/// release throttles to protect quota. [appThrottle] is an extra app-side guard
/// so resume events don't spam fetches.
abstract class RemoteConfigTuning {
  static const Duration fetchTimeout = Duration(seconds: 30);
  // Instant reflect: 0 interval => every launch/resume fetches fresh values
  // (no 30-min release cache). Raise later (e.g. 5-15 min) if quota matters.
  static const Duration minFetchIntervalRelease = Duration.zero;
  static const Duration minFetchIntervalDebug = Duration.zero;

  /// Minimum gap between app-triggered refreshes (launch/resume).
  static const Duration appThrottle = Duration(minutes: 15);
}
