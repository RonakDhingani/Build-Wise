import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/result/result.dart';
import '../../../expense/domain/entities/expense_entity.dart';
import '../../../expense/presentation/notifiers/expense_notifier.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../../../project/domain/entities/project_entity.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../../stage/data/models/stage_isar_model.dart';
import '../../../stage/presentation/providers/stage_providers.dart';

class StageProgress {
  const StageProgress({
    required this.id,
    required this.name,
    required this.progressPercent,
    required this.orderIndex,
    required this.status,
  });

  final int id;
  final String name;
  final int progressPercent;
  final int orderIndex;
  final StageModelStatus status;

  bool get isCompleted => status == StageModelStatus.completed;
  bool get isInProgress => status == StageModelStatus.inProgress;
}

class DashboardData {
  const DashboardData({
    required this.project,
    required this.recentExpenses,
    required this.categories,
    required this.stages,
  });

  final ProjectEntity project;
  final List<ExpenseEntity> recentExpenses;
  final List<ExpenseCategoryEntity> categories;
  final List<StageProgress> stages;
}

final dashboardProvider =
    FutureProvider.family<DashboardData, int>((ref, projectId) async {
  ref.watch(expensesNotifierProvider(projectId));
  ref.watch(stagesNotifierProvider(projectId));

  final projectUseCase = ref.read(getProjectByIdUseCaseProvider);
  final expensesUseCase = ref.read(getExpensesUseCaseProvider);
  final categoriesUseCase = ref.read(getCategoriesUseCaseProvider);
  final isar = ref.read(isarProvider);

  final projectFuture = projectUseCase.execute(projectId);
  final expensesFuture = expensesUseCase.execute(projectId);
  final categoriesFuture = categoriesUseCase.execute();
  final stagesFuture = isar.stageModels
      .where()
      .projectIdEqualTo(projectId)
      .findAll();

  final projectResult = await projectFuture;
  final expensesResult = await expensesFuture;
  final categoriesResult = await categoriesFuture;
  final stageModels = await stagesFuture;

  final project = projectResult.when(
    success: (p) => p,
    failure: (f) => throw Exception(f.message),
  );
  final allExpenses = expensesResult.when(
    success: (e) => e,
    failure: (_) => <ExpenseEntity>[],
  );
  final categories = categoriesResult.when(
    success: (c) => c,
    failure: (_) => <ExpenseCategoryEntity>[],
  );

  stageModels.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final stages = stageModels
      .map((m) => StageProgress(
            id: m.id,
            name: m.name,
            progressPercent: m.progressPercent,
            orderIndex: m.orderIndex,
            status: m.status,
          ))
      .toList();

  final recentExpenses = allExpenses.take(5).toList();

  return DashboardData(
    project: project,
    recentExpenses: recentExpenses,
    categories: categories,
    stages: stages,
  );
});
