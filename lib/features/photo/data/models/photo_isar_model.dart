import 'package:isar/isar.dart';

part 'photo_isar_model.g.dart';

@Collection()
class PhotoModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int projectId;

  int? stageId;

  late String filePath;
  String? thumbnailPath;
  String? caption;

  late DateTime takenAt;
  late DateTime createdAt;
}
