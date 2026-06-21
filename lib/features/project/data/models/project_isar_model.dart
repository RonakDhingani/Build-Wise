import 'package:isar/isar.dart';

part 'project_isar_model.g.dart';

@Collection()
class ProjectModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  late String location;
  String? plotSize;
  String? builtUpArea;
  int? numberOfFloors;

  @Index()
  late double budget;

  late DateTime startDate;
  DateTime? expectedCompletionDate;
  String? notes;
  String? coverImagePath;

  @Enumerated(EnumType.name)
  late ProjectModelStatus status;

  late DateTime createdAt;
  late DateTime updatedAt;
}

enum ProjectModelStatus { active, archived }
