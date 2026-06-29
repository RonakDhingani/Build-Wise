import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firestore_service.dart';

/// Single seam for accessing Firebase singletons. Keeping the instance behind a
/// provider lets every module share one [FirestoreService] and makes testing
/// (override with a fake) trivial.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// The reusable CRUD service — inject this anywhere Firestore is needed.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.read(firebaseFirestoreProvider));
});
