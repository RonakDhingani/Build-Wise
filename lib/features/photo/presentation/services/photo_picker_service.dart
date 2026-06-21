import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../../constants/app_constants.dart';

class PhotoPickResult {
  const PhotoPickResult({
    required this.filePath,
    this.thumbnailPath,
    required this.takenAt,
  });

  final String filePath;
  final String? thumbnailPath;
  final DateTime takenAt;
}

class PhotoPickerService {
  const PhotoPickerService();

  static final _picker = ImagePicker();
  static const _uuid = Uuid();

  Future<PhotoPickResult?> pickFromCamera(int projectId) =>
      _pick(ImageSource.camera, projectId);

  Future<PhotoPickResult?> pickFromGallery(int projectId) =>
      _pick(ImageSource.gallery, projectId);

  Future<PhotoPickResult?> _pick(ImageSource source, int projectId) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        imageQuality: AppConstants.imageQuality,
      );
      if (xFile == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final photoDir =
          Directory('${appDir.path}/build_wise/$projectId/photos');
      final thumbDir =
          Directory('${appDir.path}/build_wise/$projectId/thumbs');

      await photoDir.create(recursive: true);
      await thumbDir.create(recursive: true);

      final fileName = '${_uuid.v4()}.jpg';
      final photoPath = '${photoDir.path}/$fileName';
      final thumbPath = '${thumbDir.path}/$fileName';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        xFile.path,
        photoPath,
        quality: AppConstants.imageQuality,
        minWidth: 1200,
        minHeight: 1200,
      );
      if (compressed == null) return null;

      await FlutterImageCompress.compressAndGetFile(
        xFile.path,
        thumbPath,
        quality: 60,
        minWidth: AppConstants.thumbnailSize,
        minHeight: AppConstants.thumbnailSize,
      );

      return PhotoPickResult(
        filePath: compressed.path,
        thumbnailPath: File(thumbPath).existsSync() ? thumbPath : null,
        takenAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}
