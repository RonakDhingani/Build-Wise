import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_exception_handler.dart';

/// Reusable, feature-agnostic Firestore CRUD. Every module talks to Firestore
/// through these generic methods — no feature-specific queries live here, and
/// no collection path is hardcoded (callers pass [FirestoreCollections] values).
///
/// All methods translate raw errors into [FirebaseFailure] via the shared
/// handler, so repositories get consistent, user-friendly failures.
class FirestoreService {
  FirestoreService(this._db);

  final FirebaseFirestore _db;

  /// Pre-generate a document id (so it can be embedded in the doc body on a
  /// single create — no client update needed, keeping write-only security).
  String newDocId(String collection) => _db.collection(collection).doc().id;

  /// Create a document. If [docId] is null, an auto id is generated. The
  /// generated/used id is returned. [serverTimestampField], when set, is
  /// stamped with `FieldValue.serverTimestamp()`.
  Future<String> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? docId,
    String? serverTimestampField,
  }) async {
    try {
      final ref = docId == null
          ? _db.collection(collection).doc()
          : _db.collection(collection).doc(docId);
      await ref.set({
        ...data,
        if (serverTimestampField != null)
          serverTimestampField: FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      throw FirebaseExceptionHandler.map(e);
    }
  }

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw FirebaseExceptionHandler.map(e);
    }
  }

  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      throw FirebaseExceptionHandler.map(e);
    }
  }

  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final snap = await _db.collection(collection).doc(docId).get();
      return snap.data();
    } catch (e) {
      throw FirebaseExceptionHandler.map(e);
    }
  }

  Future<List<Map<String, dynamic>>> getCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>>)?
        queryBuilder,
  }) async {
    try {
      final ref = _db.collection(collection);
      final query = queryBuilder?.call(ref) ?? ref;
      final snap = await query.get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      throw FirebaseExceptionHandler.map(e);
    }
  }

  /// Atomic multi-write. [operations] mutate the passed [WriteBatch].
  Future<void> batchWrite(
    void Function(WriteBatch batch, FirebaseFirestore db) operations,
  ) async {
    try {
      final batch = _db.batch();
      operations(batch, _db);
      await batch.commit();
    } catch (e) {
      throw FirebaseExceptionHandler.map(e);
    }
  }
}
