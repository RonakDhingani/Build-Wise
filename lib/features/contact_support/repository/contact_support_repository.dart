import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app/version_store.dart';
import '../../../core/error/failure.dart';
import '../../../core/firebase/firebase_constants.dart';
import '../../../core/firebase/firebase_exception_handler.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../core/result/result.dart';
import '../models/email_template.dart';
import '../models/support_request.dart';

/// Contact Support data layer. Reuses the generic [FirestoreService] for the
/// write and the shared [SupportEmailTemplate] for email drafts — no Firestore
/// path or email body is duplicated here.
class ContactSupportRepository {
  ContactSupportRepository({
    required FirestoreService firestore,
    required VersionStore versionStore,
  })  : _firestore = firestore,
        _versionStore = versionStore;

  final FirestoreService _firestore;
  final VersionStore _versionStore;

  /// Open the email client with a prefilled draft for [type] (used by the
  /// three cards — same behaviour/templates as the website).
  Future<bool> openEmailDraft(SupportRequestType type, {String? body}) async {
    try {
      return await launchUrl(
        SupportEmailTemplate.mailto(type, body: body),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// Submit the form to Firestore. Auto-attaches version path + device meta,
  /// server timestamp, and `status: Pending`. Never throws — returns Result.
  Future<Result<String>> submit({
    required String name,
    required String email,
    required String subject,
    required String message,
    required SupportRequestType requestType,
  }) async {
    try {
      await _versionStore.ensureLoaded();
      final meta = await _device();

      final request = SupportRequest(
        name: name.trim(),
        email: email.trim(),
        subject: subject.trim(),
        message: message.trim(),
        requestType: requestType,
        appOldVersion: _versionStore.previousVersion,
        currentVersion: _versionStore.currentVersion,
        platform: meta.platform,
        deviceType: meta.deviceType,
      );

      // Pre-generate id so requestId lives in the doc on a single create.
      final id = _firestore.newDocId(FirestoreCollections.supportRequests);
      await _firestore.createDocument(
        collection: FirestoreCollections.supportRequests,
        docId: id,
        data: {SupportRequestFields.requestId: id, ...request.toMap()},
        serverTimestampField: SupportRequestFields.createdAt,
      );
      return Success(id);
    } on FirebaseFailure catch (e) {
      return Failure(DatabaseFailure(e.message));
    } catch (e) {
      final f = FirebaseExceptionHandler.map(e);
      return Failure(DatabaseFailure(f.message));
    }
  }

  Future<({String platform, String deviceType})> _device() async {
    var platform = 'unknown';
    var deviceType = 'unknown';
    try {
      final di = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await di.androidInfo;
        platform = 'Android';
        deviceType = '${a.manufacturer} ${a.model}';
      } else if (Platform.isIOS) {
        final i = await di.iosInfo;
        platform = 'iOS';
        deviceType = i.utsname.machine;
      }
    } catch (_) {/* keep unknowns */}
    return (platform: platform, deviceType: deviceType);
  }
}
