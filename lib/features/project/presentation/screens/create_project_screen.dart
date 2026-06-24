import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_strings.dart';
import '../../../../features/onboarding/presentation/walkthrough_controller.dart';
import '../../../../features/onboarding/presentation/walkthrough_step.dart';
import '../../../../navigation/app_router.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/validators.dart';
import '../../domain/entities/project_entity.dart';
import '../providers/project_providers.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _plotSizeCtrl = TextEditingController();
  final _builtUpCtrl = TextEditingController();
  final _floorsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _completionDate;
  bool _isSaving = false;
  bool _showOptional = false;

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
    return AppScaffold(
      appBar: AppBarWidget(title: AppStrings.createProject),
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
              hint: 'e.g. My Dream Home',
              controller: _nameCtrl,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              validator: Validators.required,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: AppStrings.projectLocation,
              hint: 'e.g. Ahmedabad, Gujarat',
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
            const SizedBox(height: AppSpacing.xxl),
            // Optional fields toggle
            GestureDetector(
              onTap: () => setState(() => _showOptional = !_showOptional),
              child: Row(
                children: [
                  Text(
                    _showOptional ? 'Hide optional details' : 'Add optional details',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: LightThemeColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    _showOptional
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: LightThemeColors.primary,
                    size: AppDimensions.iconSm,
                  ),
                ],
              ),
            ),
            if (_showOptional) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel('Optional Details'),
              const SizedBox(height: AppSpacing.md),
              AppDatePickerField(
                label: AppStrings.expectedCompletion,
                value: _completionDate,
                firstDate: _startDate,
                onChanged: (d) => setState(() => _completionDate = d),
              ),
              const SizedBox(height: AppSpacing.lg),
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
                validator: _floorsCtrl.text.isEmpty
                    ? null
                    : Validators.positiveInt,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: AppStrings.notes,
                hint: 'Any additional notes...',
                controller: _notesCtrl,
                maxLines: 3,
                maxLength: 1000,
              ),
            ],
            const SizedBox(height: AppSpacing.huge),
            AppPrimaryButton(
              label: AppStrings.createProject,
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final budget = double.tryParse(
            _budgetCtrl.text.replaceAll(RegExp(r'[^\d.]'), ''),
          ) ??
          0.0;

      final entity = ProjectEntity(
        id: 0,
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        plotSize: _plotSizeCtrl.text.trim().isEmpty
            ? null
            : _plotSizeCtrl.text.trim(),
        builtUpArea: _builtUpCtrl.text.trim().isEmpty
            ? null
            : _builtUpCtrl.text.trim(),
        numberOfFloors: int.tryParse(_floorsCtrl.text.trim()),
        budget: budget,
        startDate: _startDate,
        expectedCompletionDate: _completionDate,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        status: ProjectStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await ref
          .read(projectsNotifierProvider.notifier)
          .createProject(entity);

      if (!mounted) return;

      if (created != null) {
        // During the onboarding tour, open the new project's dashboard so the
        // walkthrough can resume there; otherwise return to the project list.
        final touring =
            ref.read(walkthroughControllerProvider) == WalkStep.createProject;
        if (touring) {
          context.goNamed(
            AppRouteNames.dashboard,
            pathParameters: {'id': created.id.toString()},
          );
        } else {
          context.goNamed(AppRouteNames.projects);
        }
      }
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
