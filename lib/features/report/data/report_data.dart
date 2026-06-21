import '../../expense/domain/entities/expense_entity.dart';
import '../../material/domain/entities/material_entity.dart';
import '../../project/domain/entities/project_entity.dart';
import '../../stage/domain/entities/stage_entity.dart';

class ReportData {
  const ReportData({
    required this.project,
    required this.expenses,
    required this.categories,
    required this.stages,
    required this.materials,
    required this.generatedAt,
  });

  final ProjectEntity project;
  final List<ExpenseEntity> expenses;
  final List<ExpenseCategoryEntity> categories;
  final List<StageEntity> stages;
  final List<MaterialEntity> materials;
  final DateTime generatedAt;

  double get totalExpenses =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get totalMaterialCost =>
      materials.fold(0.0, (sum, m) => sum + m.totalCost);

  Map<int, double> get expensesByCategory {
    final map = <int, double>{};
    for (final e in expenses) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
    }
    return map;
  }

  int get completedStages =>
      stages.where((s) => s.status == StageStatus.completed).length;

  double get avgProgress => stages.isEmpty
      ? 0
      : stages.fold(0.0, (s, e) => s + e.progressPercent) / stages.length;
}
