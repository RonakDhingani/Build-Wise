import '../../../core/firebase/firebase_constants.dart';

/// Type of support intake. `wire` is the exact string stored in Firestore and
/// used in email subjects (kept identical to the website for parity).
enum SupportRequestType {
  support('Support'),
  featureRequest('Feature Request'),
  bugReport('Bug Report');

  const SupportRequestType(this.wire);
  final String wire;

  String get label => wire;
}

/// Lifecycle status of a request. Default is [pending].
enum SupportRequestStatus {
  pending('Pending'),
  inProgress('In Progress'),
  resolved('Resolved'),
  closed('Closed');

  const SupportRequestStatus(this.wire);
  final String wire;
}

/// A support submission. `requestId` and `createdAt` (serverTimestamp) are set
/// by the service on write, so they are not constructor inputs.
class SupportRequest {
  const SupportRequest({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.requestType,
    required this.appOldVersion,
    required this.currentVersion,
    required this.platform,
    required this.deviceType,
  });

  final String name;
  final String email;
  final String subject;
  final String message;
  final SupportRequestType requestType;
  final String appOldVersion;
  final String currentVersion;
  final String platform;
  final String deviceType;

  /// Firestore payload (keys centralised in [SupportRequestFields]).
  /// `requestId` + `createdAt` are added by the service. `status` is NOT written
  /// by the client — it is set server-side/admin (write-only security).
  Map<String, dynamic> toMap() => {
        SupportRequestFields.name: name,
        SupportRequestFields.email: email,
        SupportRequestFields.subject: subject,
        SupportRequestFields.message: message,
        SupportRequestFields.requestType: requestType.wire,
        SupportRequestFields.appOldVersion: appOldVersion,
        SupportRequestFields.currentVersion: currentVersion,
        SupportRequestFields.platform: platform,
        SupportRequestFields.deviceType: deviceType,
      };
}
