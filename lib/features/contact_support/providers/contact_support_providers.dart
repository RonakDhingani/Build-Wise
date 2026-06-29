import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app/version_store.dart';
import '../../../core/firebase/firebase_service.dart';
import '../repository/contact_support_repository.dart';

/// Contact Support repository — reuses the shared FirestoreService + VersionStore.
final contactSupportRepositoryProvider =
    Provider<ContactSupportRepository>((ref) {
  return ContactSupportRepository(
    firestore: ref.read(firestoreServiceProvider),
    versionStore: ref.read(versionStoreProvider),
  );
});
