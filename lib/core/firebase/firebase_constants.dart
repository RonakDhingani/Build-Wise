/// Centralised Firestore collection names + document field keys.
/// Never hardcode a path or key elsewhere — reference these.
abstract class FirestoreCollections {
  static const String supportRequests = 'support_requests';
  // Future modules reuse the same layer, e.g.:
  // static const String appFeedback = 'app_feedback';
  // static const String featureVotes = 'feature_votes';
}

/// Field keys for the `support_requests` documents.
abstract class SupportRequestFields {
  static const String requestId = 'requestId';
  static const String name = 'name';
  static const String email = 'email';
  static const String subject = 'subject';
  static const String message = 'message';
  static const String requestType = 'requestType';
  static const String status = 'status';
  static const String appOldVersion = 'appOldVersion';
  static const String currentVersion = 'currentVersion';
  static const String platform = 'platform';
  static const String deviceType = 'deviceType';
  static const String createdAt = 'createdAt';
}
