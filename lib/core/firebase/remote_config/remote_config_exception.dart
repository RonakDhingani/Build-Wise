/// Raised by the Remote Config service/repository. Callers catch this and fall
/// back to cached/default values — Remote Config must never crash the app.
class RemoteConfigException implements Exception {
  const RemoteConfigException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'RemoteConfigException: $message${cause != null ? ' ($cause)' : ''}';
}
