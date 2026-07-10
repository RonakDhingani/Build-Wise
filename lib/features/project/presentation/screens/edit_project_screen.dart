import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/validators.dart';
import '../../domain/entities/project_entity.dart';
import '../actions/project_actions.dart';
import '../providers/project_providers.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final int projectId;
  const EditProjectScreen({super.key, required this.projectId});

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _plotSizeCtrl = TextEditingController();
  final _builtUpCtrl = TextEditingController();
  final _floorsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _startDate;
  DateTime? _completionDate;
  ProjectEntity? _original;
  bool _isSaving = false;
  bool _isLoading = true;
  String? _loadError;
  // Duplicate-name error surfaced inline under the name field; cleared as the
  // user edits the name.
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    final useCase = ref.read(getProjectByIdUseCaseProvider);
    final result = await useCase.execute(widget.projectId);
    result.when(
      success: (p) {
        if (!mounted) return;
        setState(() {
          _original = p;
          _nameCtrl.text = p.name;
          _locationCtrl.text = p.location;
          _budgetCtrl.text = p.budget.toStringAsFixed(0);
          _plotSizeCtrl.text = p.plotSize ?? '';
          _builtUpCtrl.text = p.builtUpArea ?? '';
          _floorsCtrl.text = p.numberOfFloors?.toString() ?? '';
          _notesCtrl.text = p.notes ?? '';
          _startDate = p.startDate;
          _completionDate = p.expectedCompletionDate;
          _isLoading = false;
        });
      },
      failure: (f) {
        if (!mounted) return;
        setState(() {
          _loadError = f.message;
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _budgetCtrl.dispose();
    _plotSizeCtrl.dispose();
    _builtUpCtrl.dispose();
    _floorsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(body: AppLoadingWidget());
    }
    if (_loadError != null) {
      return AppScaffold(
        body: AppErrorState(
          message: _loadError!,
          onRetry: () {
            setState(() {
              _isLoading = true;
              _loadError = null;
            });
            _loadProject();
          },
        ),
      );
    }

    return AppScaffold(
      appBar: AppBarWidget(
        title: AppStrings.editProject,
        actions: [
          IconButton(
            icon: Icon(
              _original?.status == ProjectStatus.archived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
            tooltip: _original?.status == ProjectStatus.archived
                ? 'Unarchive'
                : 'Archive',
            onPressed: _onArchive,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error500),
            tooltip: 'Delete',
            onPressed: _onDelete,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageVertical,
          ),
          children: [
            _SectionLabel('Project Details'),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: AppStrings.projectName,
              controller: _nameCtrl,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                final base = Validators.required(v);
                if (base != null) return base;
                return _nameError;
              },
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: AppStrings.projectLocation,
              controller: _locationCtrl,
              maxLength: 200,
              textCapitalization: TextCapitalization.words,
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCurrencyField(
              label: AppStrings.projectBudget,
              controller: _budgetCtrl,
              validator: Validators.positiveAmount,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDatePickerField(
              label: AppStrings.startDate,
              value: _startDate,
              onChanged: (d) => setState(() => _startDate = d),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDatePickerField(
              label: AppStrings.expectedCompletion,
              value: _completionDate,
              firstDate: _startDate,
              onChanged: (d) => setState(() => _completionDate = d),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Optional Details'),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: AppStrings.plotSize,
              hint: 'e.g. 2400 sqft',
              controller: _plotSizeCtrl,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: AppStrings.builtUpArea,
              hint: 'e.g. 1800 sqft',
              controller: _builtUpCtrl,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: AppStrings.numberOfFloors,
              hint: 'e.g. 2',
              controller: _floorsCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: AppStrings.notes,
              controller: _notesCtrl,
              maxLines: 3,
              maxLength: 1000,
            ),
            const SizedBox(height: AppSpacing.huge),
            AppPrimaryButton(
              label: AppStrings.save,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _onSave,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    // Clear any stale duplicate error before re-validating.
    _nameError = null;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_original == null || _startDate == null) return;

    // Block duplicate names (case-insensitive), ignoring this same project.
    final name = _nameCtrl.text.trim();
    if (ref
        .read(projectsNotifierProvider.notifier)
        .nameExists(name, excludeId: widget.projectId)) {
      setState(() => _nameError = AppStrings.projectNameExists);
      _formKey.currentState?.validate();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final budget = double.tryParse(
            _budgetCtrl.text.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          _original!.budget;

      final updated = _original!.copyWith(
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        budget: budget,
        startDate: _startDate,
        expectedCompletionDate: _completionDate,
        plotSize: _plotSizeCtrl.text.trim().isEmpty
            ? null
            : _plotSizeCtrl.text.trim(),
        builtUpArea: _builtUpCtrl.text.trim().isEmpty
            ? null
            : _builtUpCtrl.text.trim(),
        numberOfFloors: int.tryParse(_floorsCtrl.text.trim()),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        updatedAt: DateTime.now(),
      );

      await ref.read(projectsNotifierProvider.notifier).updateProject(updated);

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

  Future<void> _onArchive() async {
    if (_original == null) return;
    final confirmed = await ProjectActions.archive(context, ref, _original!);
    // Leave the edit form for this project once it's archived.
    if (confirmed && mounted) context.pop();
  }

  Future<void> _onDelete() async {
    if (_original == null) return;
    // The edit form is bound to this project, so deleting it always abandons the
    // context. Passing its own id triggers the "active project deleted" flow:
    // ProjectActions returns to the Project Listing and clears the default.
    await ProjectActions.delete(
      context,
      _original!,
      activeProjectId: widget.projectId,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(
        color: LightThemeColors.textSecondary,
      ),
    );
  }
}
