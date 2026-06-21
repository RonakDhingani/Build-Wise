enum ProjectStatus { active, archived }

class ProjectEntity {
  const ProjectEntity({
    required this.id,
    required this.name,
    required this.location,
    this.plotSize,
    this.builtUpArea,
    this.numberOfFloors,
    required this.budget,
    required this.startDate,
    this.expectedCompletionDate,
    this.notes,
    this.coverImagePath,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.totalSpent = 0.0,
    this.completionPercentage = 0.0,
  });

  final int id;
  final String name;
  final String location;
  final String? plotSize;
  final String? builtUpArea;
  final int? numberOfFloors;
  final double budget;
  final DateTime startDate;
  final DateTime? expectedCompletionDate;
  final String? notes;
  final String? coverImagePath;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed — populated by repository from linked records
  final double totalSpent;
  final double completionPercentage;

  double get remaining => budget - totalSpent;
  double get spentPercent => budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;

  ProjectEntity copyWith({
    int? id,
    String? name,
    String? location,
    String? plotSize,
    String? builtUpArea,
    int? numberOfFloors,
    double? budget,
    DateTime? startDate,
    DateTime? expectedCompletionDate,
    String? notes,
    String? coverImagePath,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalSpent,
    double? completionPercentage,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      plotSize: plotSize ?? this.plotSize,
      builtUpArea: builtUpArea ?? this.builtUpArea,
      numberOfFloors: numberOfFloors ?? this.numberOfFloors,
      budget: budget ?? this.budget,
      startDate: startDate ?? this.startDate,
      expectedCompletionDate: expectedCompletionDate ?? this.expectedCompletionDate,
      notes: notes ?? this.notes,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalSpent: totalSpent ?? this.totalSpent,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
