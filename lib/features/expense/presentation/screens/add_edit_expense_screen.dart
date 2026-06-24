import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/validators.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expense_providers.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  const AddEditExpenseScreen({
    super.key,
    required this.projectId,
    this.expenseId,
  });

  final int projectId;
  final int? expenseId;

  bool get isEditing => expenseId != null;

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState
    extends ConsumerState<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _vendorCtrl = TextEditingController();

  DateTime _date = DateTime.now();
  int? _selectedCategoryId;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  int? _selectedStageId;
  bool _isSaving = false;

  ExpenseEntity? _existing;

  // Sentinel dropdown value for the "Add New Category" action. Real category
  // ids are auto-increment (>= 1), so -1 never collides.
  static const int _addNewCategoryValue = -1;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
    }
  }

  void _prefill() {
    final state =
        ref.read(expensesNotifierProvider(widget.projectId)).valueOrNull;
    if (state == null) return;
    final expense =
        state.expenses.where((e) => e.id == widget.expenseId).firstOrNull;
    if (expense == null) return;

    _existing = expense;
    _amountCtrl.text = expense.amount.toStringAsFixed(
        expense.amount.truncateToDouble() == expense.amount ? 0 : 2);
    _descCtrl.text = expense.description ?? '';
    _vendorCtrl.text = expense.vendorName ?? '';
    setState(() {
      _date = expense.date;
      _selectedCategoryId = expense.categoryId;
      _paymentMethod = expense.paymentMethod;
      _selectedStageId = expense.stageId;
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _vendorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final stagesAsync = ref.watch(stagesByProjectProvider(widget.projectId));

    return AppScaffold(
      appBar: AppBarWidget(
        title: widget.isEditing
            ? AppStrings.editExpenseTitle
            : AppStrings.addExpenseTitle,
      ),
      body: categoriesAsync.when(
        skipLoadingOnReload: true,
        loading: () => const AppLoadingWidget(),
        error: (_, __) => const AppErrorState(message: 'Failed to load categories.'),
        data: (categories) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.pageVertical,
            ),
            children: [
              // Amount
              AppCurrencyField(
                label: AppStrings.amount,
                controller: _amountCtrl,
                autofocus: !widget.isEditing,
                validator: Validators.positiveAmount,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category
              AppDropdownField<int>(
                label: AppStrings.category,
                value: _selectedCategoryId,
                hint: 'Select category',
                items: [
                  ...categories.map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      )),
                  DropdownMenuItem<int>(
                    value: _addNewCategoryValue,
                    child: Row(
                      children: [
                        Icon(Icons.add_rounded,
                            size: AppDimensions.iconSm,
                            color: LightThemeColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Add New Category',
                          style: TextStyle(
                            color: LightThemeColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v == _addNewCategoryValue) {
                    _showQuickAddCategory(categories);
                    return;
                  }
                  setState(() => _selectedCategoryId = v);
                },
                validator: (v) =>
                    v == null ? AppStrings.requiredField : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date
              AppDatePickerField(
                label: AppStrings.date,
                value: _date,
                lastDate: DateTime.now(),
                onChanged: (d) => setState(() => _date = d),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Payment type
              AppDropdownField<PaymentMethod>(
                label: AppStrings.paymentType,
                value: _paymentMethod,
                items: PaymentMethod.values
                    .map((m) => DropdownMenuItem<PaymentMethod>(
                          value: m,
                          child: Text(m.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _paymentMethod = v);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Vendor (optional)
              AppTextField(
                label: AppStrings.vendor,
                controller: _vendorCtrl,
                maxLength: 100,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description (optional)
              AppTextField(
                label: AppStrings.description,
                controller: _descCtrl,
                maxLines: 2,
                maxLength: 300,
              ),
              const SizedBox(height: AppSpacing.lg),

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
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
              ),

              const SizedBox(height: AppSpacing.xxl),
              AppPrimaryButton(
                label: widget.isEditing ? AppStrings.save : 'Add Expense',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _onSave,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick Add Category from the dropdown. Creates the category locally,
  /// refreshes the list, auto-selects it, and keeps the user on this screen.
  Future<void> _showQuickAddCategory(
    List<ExpenseCategoryEntity> existing,
  ) async {
    final name = await AppBottomSheet.show<String>(
      context,
      title: 'Add Expense Category',
      child: _AddCategorySheet(
        existingNames: existing.map((c) => c.name.toLowerCase().trim()).toSet(),
      ),
    );
    if (name == null || !mounted) return;

    final result =
        await ref.read(createCategoryUseCaseProvider).execute(name);
    if (!mounted) return;

    await result.when(
      success: (created) async {
        // Refresh the form dropdown and the Settings list from Isar.
        ref.invalidate(expenseCategoriesProvider);
        ref.invalidate(categoriesNotifierProvider);
        await ref.read(expenseCategoriesProvider.future);
        if (!mounted) return;
        setState(() => _selectedCategoryId = created.id);
      },
      failure: (f) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(f.message),
            backgroundColor: AppColors.error500,
          ),
        );
      },
    );
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) return;

    setState(() => _isSaving = true);

    try {
      final amount =
          double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^\d.]'), '')) ??
              0.0;

      if (widget.isEditing && _existing != null) {
        final updated = ExpenseEntity(
          id: _existing!.id,
          projectId: widget.projectId,
          stageId: _selectedStageId,
          categoryId: _selectedCategoryId!,
          amount: amount,
          date: _date,
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          vendorName: _vendorCtrl.text.trim().isEmpty
              ? null
              : _vendorCtrl.text.trim(),
          paymentMethod: _paymentMethod,
          billImagePath: _existing!.billImagePath,
          createdAt: _existing!.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref
            .read(expensesNotifierProvider(widget.projectId).notifier)
            .updateExpense(updated);
      } else {
        final entity = ExpenseEntity(
          id: 0,
          projectId: widget.projectId,
          stageId: _selectedStageId,
          categoryId: _selectedCategoryId!,
          amount: amount,
          date: _date,
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          vendorName: _vendorCtrl.text.trim().isEmpty
              ? null
              : _vendorCtrl.text.trim(),
          paymentMethod: _paymentMethod,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref
            .read(expensesNotifierProvider(widget.projectId).notifier)
            .addExpense(entity);
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

/// Quick Add Category bottom sheet. Collects + validates a name (non-empty,
/// non-duplicate) and returns the trimmed value via `Navigator.pop`.
class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet({required this.existingNames});

  /// Lower-cased, trimmed names of existing categories for duplicate checks.
  final Set<String> existingNames;

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Category name is required');
      return;
    }
    if (widget.existingNames.contains(name.toLowerCase())) {
      setState(() => _error = 'This category already exists');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Category Name',
            hint: 'e.g. Solar Panels',
            controller: _ctrl,
            autofocus: true,
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _save(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.error500, fontSize: 12),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  label: AppStrings.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppPrimaryButton(
                  label: AppStrings.save,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
