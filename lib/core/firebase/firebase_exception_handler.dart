import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Typed, user-friendly Firebase failure. Reusable across every Firestore
/// module — map any thrown error with [FirebaseExceptionHandler.map].
class FirebaseFailure implements Exception {
  const FirebaseFailure(this.message, [this.cause]);
  final String message;
  final Object? cause;
  @override
  String toString() => 'FirebaseFailure: $message';
}

/// Converts raw exceptions into friendly [FirebaseFailure]s. One place handles
/// no-internet, permission, timeout, Firebase and unknown errors so feature
/// repositories never duplicate this logic.
abstract class FirebaseExceptionHandler {
  static FirebaseFailure map(Object error) {
    if (error is FirebaseFailure) return error;

    if (error is SocketException) {
      return const FirebaseFailure(
          'No internet connection. Check your network and try again.', null);
    }
    if (error is TimeoutException) {
      return const FirebaseFailure('Request timed out. Please try again.', null);
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return FirebaseFailure(
              'You do not have permission to do this.', error);
        case 'unavailable':
        case 'network-request-failed':
          return FirebaseFailure(
              'Network unavailable. Please try again shortly.', error);
        default:
          return FirebaseFailure(
              error.message ?? 'A server error occurred. Please try again.',
              error);
      }
    }
    return FirebaseFailure('Something went wrong. Please try again.', error);
  }
}
