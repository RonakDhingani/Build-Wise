import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_strings.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/validators.dart';
import '../../../expense/presentation/providers/expense_providers.dart';
import '../../domain/entities/material_entity.dart';
import '../providers/material_providers.dart';

class AddEditMaterialScreen extends ConsumerStatefulWidget {
  const AddEditMaterialScreen({
    super.key,
    required this.projectId,
    this.materialId,
  });

  final int projectId;
  final int? materialId;

  bool get isEditing => materialId != null;

  @override
  ConsumerState<AddEditMaterialScreen> createState() =>
      _AddEditMaterialScreenState();
}

class _AddEditMaterialScreenState
    extends ConsumerState<AddEditMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyPurchasedCtrl = TextEditingController();
  final _qtyUsedCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  MaterialUnit _unit = MaterialUnit.pieces;
  DateTime _purchaseDate = DateTime.now();
  int? _selectedStageId;
  bool _isSaving = false;

  MaterialEntity? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
    }
  }

  void _prefill() {
    final state =
        ref.read(materialsNotifierProvider(widget.projectId)).valueOrNull;
    if (state == null) return;
    final material = state.materials
        .where((m) => m.id == widget.materialId)
        .firstOrNull;
    if (material == null) return;

    _existing = material;
    _nameCtrl.text = material.name;
    _qtyPurchasedCtrl.text = material.quantityPurchased.toStringAsFixed(
        material.quantityPurchased.truncateToDouble() ==
                material.quantityPurchased
            ? 0
            : 2);
    _qtyUsedCtrl.text = material.quantityUsed.toStringAsFixed(
        material.quantityUsed.truncateToDouble() == material.quantityUsed
            ? 0
            : 2);
    if (material.costPerUnit != null) {
      _costCtrl.text = material.costPerUnit!.toStringAsFixed(2);
    }
    _vendorCtrl.text = material.vendorName ?? '';
    _notesCtrl.text = material.notes ?? '';
    setState(() {
      _unit = material.unit;
      _purchaseDate = material.purchaseDate;
      _selectedStageId = material.stageId;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyPurchasedCtrl.dispose();
    _qtyUsedCtrl.dispose();
    _costCtrl.dispose();
    _vendorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stagesAsync = ref.watch(stagesByProjectProvider(widget.projectId));

    return AppScaffold(
      appBar: AppBarWidget(
        title: widget.isEditing
            ? AppStrings.editMaterialTitle
            : AppStrings.addMaterialTitle,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          children: [
            // Name
            AppTextField(
              label: AppStrings.materialName,
              controller: _nameCtrl,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              validator: Validators.required,
              autofocus: !widget.isEditing,
            ),
            const SizedBox(height: 16),

            // Unit
            AppDropdownField<MaterialUnit>(
              label: AppStrings.unit,
              value: _unit,
              items: MaterialUnit.values
                  .map((u) => DropdownMenuItem<MaterialUnit>(
                        value: u,
                        child: Text(u.label),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _unit = v);
              },
            ),
            const SizedBox(height: 16),

            // Qty purchased
            TextFormField(
              controller: _qtyPurchasedCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
              ],
              validator: Validators.nonNegativeAmount,
              decoration: InputDecoration(
                labelText: AppStrings.quantityPurchased,
                suffixText: _unit.label,
              ),
            ),
            const SizedBox(height: 16),

            // Qty used
            TextFormField(
              controller: _qtyUsedCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
              ],
              validator: Validators.nonNegativeAmount,
              decoration: InputDecoration(
                labelText: AppStrings.quantityUsed,
                suffixText: _unit.label,
              ),
            ),
            const SizedBox(height: 16),

            // Cost per unit (optional)
            AppCurrencyField(
              label: AppStrings.costPerUnit,
              controller: _costCtrl,
            ),
            const SizedBox(height: 16),

            // Purchase date
            AppDatePickerField(
              label: 'Purchase Date',
              value: _purchaseDate,
              lastDate: DateTime.now(),
              onChanged: (d) => setState(() => _purchaseDate = d),
            ),
            const SizedBox(height: 16),

            // Vendor (optional)
            AppTextField(
              label: AppStrings.vendor,
              controller: _vendorCtrl,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Notes (optional)
            AppTextField(
              label: AppStrings.notes,
              controller: _notesCtrl,
              maxLines: 2,
              maxLength: 300,
            ),
            const SizedBox(height: 16),

            // Stage link (optional)
            stagesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (stages) => stages.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        AppDropdownField<int?>(
                          label: AppStrings.stageLink,
                          value: _selectedStageId,
                          hint: 'None',
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('None'),
                            ),
                            ...stages.map((s) => DropdownMenuItem<int?>(
                                  value: s.id,
                                  child: Text(s.name),
                                )),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedStageId = v),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
            ),

            const SizedBox(height: 24),
            AppPrimaryButton(
              label: widget.isEditing ? AppStrings.save : 'Add Material',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _onSave,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      final qtyPurchased =
          double.tryParse(_qtyPurchasedCtrl.text.trim()) ?? 0.0;
      final qtyUsed = double.tryParse(_qtyUsedCtrl.text.trim()) ?? 0.0;
      final costPerUnit = _costCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(
              _costCtrl.text.replaceAll(RegExp(r'[^\d.]'), ''));

      if (widget.isEditing && _existing != null) {
        final updated = MaterialEntity(
          id: _existing!.id,
          projectId: widget.projectId,
          stageId: _selectedStageId,
          name: _nameCtrl.text.trim(),
          unit: _unit,
          quantityPurchased: qtyPurchased,
          quantityUsed: qtyUsed,
          costPerUnit: costPerUnit,
          vendorName: _vendorCtrl.text.trim().isEmpty
              ? null
              : _vendorCtrl.text.trim(),
          purchaseDate: _purchaseDate,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          isDefault: _existing!.isDefault,
          createdAt: _existing!.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref
            .read(materialsNotifierProvider(widget.projectId).notifier)
            .updateMaterial(updated);
      } else {
        final entity = MaterialEntity(
          id: 0,
          projectId: widget.projectId,
          stageId: _selectedStageId,
          name: _nameCtrl.text.trim(),
          unit: _unit,
          quantityPurchased: qtyPurchased,
          quantityUsed: qtyUsed,
          costPerUnit: costPerUnit,
          vendorName: _vendorCtrl.text.trim().isEmpty
              ? null
              : _vendorCtrl.text.trim(),
          purchaseDate: _purchaseDate,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref
            .read(materialsNotifierProvider(widget.projectId).notifier)
            .addMaterial(entity);
      }

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.saveError),
          backgroundColor: AppColors.error500,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
