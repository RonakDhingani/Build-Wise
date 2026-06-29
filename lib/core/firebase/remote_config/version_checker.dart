import 'remote_config_model.dart';
import 'version_compare.dart';

/// Outcome of comparing the installed version against Remote Config.
enum UpdateStatus { upToDate, optional, forced }

/// Immutable result of an update check — everything the UI needs.
class UpdateDecision {
  const UpdateDecision({
    required this.status,
    required this.currentVersion,
    required this.config,
  });

  final UpdateStatus status;
  final String currentVersion;
  final RemoteConfigModel config;

  bool get shouldPrompt => status != UpdateStatus.upToDate;
  bool get isForced => status == UpdateStatus.forced;

  String get latestVersion => config.latestVersion;
  String get minRequiredVersion => config.minRequiredVersion;

  /// Version to aim users at. Falls back to min when `latest_version` is unset
  /// (default 0.0.0) — never display a meaningless 0.0.0.
  String get targetVersion =>
      VersionCompare.compare(config.latestVersion, config.minRequiredVersion) >= 0
          ? config.latestVersion
          : config.minRequiredVersion;

  factory UpdateDecision.upToDate(String current, RemoteConfigModel config) =>
      UpdateDecision(
        status: UpdateStatus.upToDate,
        currentVersion: current,
        config: config,
      );
}

/// Pure decision logic — version comparison only, NO boolean force flag:
///   installed < min            => forced
///   min <= installed < latest  => optional
///   installed >= latest        => up to date
class VersionChecker {
  const VersionChecker();

  UpdateDecision check({
    required String currentVersion,
    required RemoteConfigModel config,
  }) {
    if (VersionCompare.isOlder(currentVersion, config.minRequiredVersion)) {
      return UpdateDecision(
        status: UpdateStatus.forced,
        currentVersion: currentVersion,
        config: config,
      );
    }
    if (VersionCompare.isOlder(currentVersion, config.latestVersion)) {
      return UpdateDecision(
        status: UpdateStatus.optional,
        currentVersion: currentVersion,
        config: config,
      );
    }
    return UpdateDecision.upToDate(currentVersion, config);
  }
}
