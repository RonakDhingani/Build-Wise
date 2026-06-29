import 'dart:io';

import 'package:flutter/foundation.dart';

/// Strongly typed, null-safe snapshot of the Remote Config values BuildWise
/// uses today. Pure data object (no Firebase import) so it stays reusable and
/// testable.
///
/// Future feature flags don't need new fields here — read them generically via
/// the repository's `getBool`/`getString`. Known, frequently-used values stay
/// typed for safety.
class RemoteConfigModel {
  const RemoteConfigModel({
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.updateTitle,
    required this.updateMessage,
    required this.releaseNotes,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    required this.maintenanceEnabled,
    required this.maintenanceTitle,
    required this.maintenanceMessage,
  });

  final String latestVersion;
  final String minRequiredVersion;
  final String updateTitle;
  final String updateMessage;
  final String releaseNotes;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final bool maintenanceEnabled;
  final String maintenanceTitle;
  final String maintenanceMessage;

  /// Safe empty config — before first fetch and on total failure.
  factory RemoteConfigModel.fallback() => const RemoteConfigModel(
        latestVersion: '0.0.0',
        minRequiredVersion: '0.0.0',
        updateTitle: 'Update Available',
        updateMessage: 'A new version of BuildWise is available.',
        releaseNotes: '',
        androidStoreUrl: '',
        iosStoreUrl: '',
        maintenanceEnabled: false,
        maintenanceTitle: 'Under Maintenance',
        maintenanceMessage: 'BuildWise is briefly down for maintenance.',
      );

  /// Platform-resolved store URL.
  String get storeUrl {
    if (kIsWeb) return androidStoreUrl;
    return Platform.isIOS ? iosStoreUrl : androidStoreUrl;
  }

  bool get hasStoreUrl => storeUrl.trim().isNotEmpty;

  /// `release_notes` is authored as bullet/newline text; expose a clean list
  /// (strips leading bullet glyphs).
  List<String> get releaseNoteLines => releaseNotes
      .split('\n')
      .map((l) => l.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim())
      .where((l) => l.isNotEmpty)
      .toList(growable: false);
}
