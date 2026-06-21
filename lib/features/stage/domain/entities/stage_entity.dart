enum StageStatus { notStarted, inProgress, completed, onHold }

class StageEntity {
  const StageEntity({
    required this.id,
    required this.projectId,
    required this.name,
    required this.orderIndex,
    required this.status,
    this.startDate,
    this.endDate,
    required this.progressPercent,
    this.notes,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int projectId;
  final String name;
  final int orderIndex;
  final StageStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int progressPercent;
  final String? notes;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  StageEntity copyWith({
    int? id,
    int? projectId,
    String? name,
    int? orderIndex,
    StageStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? progressPercent,
    String? notes,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StageEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      progressPercent: progressPercent ?? this.progressPercent,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
