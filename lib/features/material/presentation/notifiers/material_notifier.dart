import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result/result.dart';
import '../../../project/presentation/providers/project_providers.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/material_providers.dart';

enum MaterialSortOrder { nameAsc, nameDesc, purchaseDateDesc, purchaseDateAsc }

class MaterialsState {
  const MaterialsState({
    required this.materials,
    this.searchQuery = '',
    this.sortOrder = MaterialSortOrder.purchaseDateDesc,
  });

  final List<MaterialEntity> materials;
  final String searchQuery;
  final MaterialSortOrder sortOrder;

  int get count => materials.length;
  double get totalCost => materials.fold(0.0, (s, m) => s + m.totalCost);
  int get lowStockCount => materials.where((m) => m.isLowStock).length;

  List<MaterialEntity> get filtered {
    var list = [...materials];

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((m) {
        return m.name.toLowerCase().contains(q) ||
            (m.vendorName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    switch (sortOrder) {
      case MaterialSortOrder.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
      case MaterialSortOrder.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
      case MaterialSortOrder.purchaseDateDesc:
        list.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      case MaterialSortOrder.purchaseDateAsc:
        list.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
    }

    return list;
  }

  MaterialsState copyWith({
    List<MaterialEntity>? materials,
    String? searchQuery,
    MaterialSortOrder? sortOrder,
  }) {
    return MaterialsState(
      materials: materials ?? this.materials,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class MaterialsNotifier extends FamilyAsyncNotifier<MaterialsState, int> {
  @override
  Future<MaterialsState> build(int arg) async {
    return _load(arg);
  }

  Future<MaterialsState> _load(int projectId) async {
    final useCase = ref.read(getMaterialsUseCaseProvider);
    final result = await useCase.execute(projectId);
    final materials = result.when(
      success: (data) => data,
      failure: (f) => throw Exception(f.message),
    );
    return MaterialsState(materials: materials);
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    final newState = await _load(arg);
    state = AsyncData(newState.copyWith(
      searchQuery: current?.searchQuery ?? '',
      sortOrder: current?.sortOrder ?? MaterialSortOrder.purchaseDateDesc,
    ));
  }

  Future<void> addMaterial(MaterialEntity entity) async {
    final useCase = ref.read(createMaterialUseCaseProvider);
    final result = await useCase.execute(entity);
    result.when(
      success: (created) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            materials: [created, ...s.materials],
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  Future<void> updateMaterial(MaterialEntity entity) async {
    final useCase = ref.read(updateMaterialUseCaseProvider);
    final result = await useCase.execute(entity);
    result.when(
      success: (updated) {
        state.whenData((s) {
          final list = List<MaterialEntity>.from(s.materials);
          final idx = list.indexWhere((m) => m.id == updated.id);
          if (idx >= 0) list[idx] = updated;
          state = AsyncData(s.copyWith(materials: list));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  Future<void> deleteMaterial(int id) async {
    final useCase = ref.read(deleteMaterialUseCaseProvider);
    final result = await useCase.execute(id);
    result.when(
      success: (_) {
        state.whenData((s) {
          state = AsyncData(s.copyWith(
            materials: s.materials.where((m) => m.id != id).toList(),
          ));
        });
      },
      failure: (f) => throw Exception(f.message),
    );
    ref.read(projectsNotifierProvider.notifier).refresh();
  }

  void updateSearch(String query) {
    state.whenData((s) => state = AsyncData(s.copyWith(searchQuery: query)));
  }

  void setSortOrder(MaterialSortOrder order) {
    state.whenData((s) => state = AsyncData(s.copyWith(sortOrder: order)));
  }
}
