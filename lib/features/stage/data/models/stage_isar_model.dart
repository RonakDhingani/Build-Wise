import 'package:isar/isar.dart';

part 'stage_isar_model.g.dart';

@Collection()
class StageModel {
  Id id = Isar.autoIncrement;

  @Index()
  late int projectId;

  late String name;
  late int orderIndex;

  @Enumerated(EnumType.name)
  late StageModelStatus status;

  DateTime? startDate;
  DateTime? endDate;

  @Index()
  late int progressPercent;

  String? notes;
  late bool isDefault;

  late DateTime createdAt;
  late DateTime updatedAt;
}

enum StageModelStatus { notStarted, inProgress, completed, onHold }
