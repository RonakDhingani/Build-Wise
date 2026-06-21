import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_strings.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/validators.dart';
import '../../domain/entities/stage_entity.dart';
import '../providers/stage_providers.dart';

class AddEditStageScreen extends ConsumerStatefulWidget {
  const AddEditStageScreen({
    super.key,
    required this.projectId,
    this.stageId,
  });

  final int projectId;
  final int? stageId;

  bool get isEditing => stageId != null;

  @override
  ConsumerState<AddEditStageScreen> createState() => _AddEditStageScreenState();
}

class _AddEditStageScreenState extends ConsumerState<AddEditStageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  StageStatus _status = StageStatus.notStarted;
  DateTime? _startDate;
  DateTime? _endDate;
  int _progress = 0;
  bool _isSaving = false;

  StageEntity? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
    }
  }

  void _prefill() {
    final stagesState =
        ref.read(stagesNotifierProvider(widget.projectId)).valueOrNull;
    if (stagesState == null) return;
    final stage = stagesState.stages
        .where((s) => s.id == widget.stageId)
        .firstOrNull;
    if (stage == null) return;

    _existing = stage;
    _nameCtrl.text = stage.name;
    _notesCtrl.text = stage.notes ?? '';
    setState(() {
      _status = stage.status;
      _startDate = stage.startDate;
      _endDate = stage.endDate;
      _progress = stage.progressPercent;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        title: widget.isEditing
            ? AppStrings.editStageTitle
            : AppStrings.addStageTitle,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.pageVertical,
          ),
          children: [
            // Stage name
            AppTextField(
              label: AppStrings.stageName,
              controller: _nameCtrl,
              autofocus: !widget.isEditing,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              validator: Validators.required,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Status
            AppDropdownField<StageStatus>(
              label: AppStrings.stageStatus,
              value: _status,
              items: StageStatus.values
                  .map((s) => DropdownMenuItem<StageStatus>(
                        value: s,
                        child: Text(s.label),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Progress
            _ProgressField(
              value: _progress,
              onChanged: (v) => setState(() => _progress = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Start date
            AppDatePickerField(
              label: 'Start Date (Optional)',
              value: _startDate,
              onChanged: (d) => setState(() => _startDate = d),
            ),
            const SizedBox(height: AppSpacing.lg),

            // End date
            AppDatePickerField(
              label: 'End Date (Optional)',
              value: _endDate,
              firstDate: _startDate,
              onChanged: (d) => setState(() => _endDate = d),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notes
            AppTextField(
              label: AppStrings.notes,
              controller: _notesCtrl,
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: AppSpacing.xxl),

            AppPrimaryButton(
              label: widget.isEditing ? AppStrings.save : AppStrings.addStage,
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
      if (widget.isEditing && _existing != null) {
        final updated = StageEntity(
          id: _existing!.id,
          projectId: widget.projectId,
          name: _nameCtrl.text.trim(),
          orderIndex: _existing!.orderIndex,
          status: _status,
          startDate: _startDate,
          endDate: _endDate,
          progressPercent: _progress,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          isDefault: _existing!.isDefault,
          createdAt: _existing!.createdAt,
          updatedAt: DateTime.now(),
        );
        await ref
            .read(stagesNotifierProvider(widget.projectId).notifier)
            .updateStage(updated);
      } else {
        final entity = StageEntity(
          id: 0,
          projectId: widget.projectId,
          name: _nameCtrl.text.trim(),
          orderIndex: 0,
          status: _status,
          startDate: _startDate,
          endDate: _endDate,
          progressPercent: _progress,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await ref
            .read(stagesNotifierProvider(widget.projectId).notifier)
            .addStage(entity);
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

class _ProgressField extends StatelessWidget {
  const _ProgressField({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.progress, style: AppTextStyles.labelMedium),
            Text('$value%', style: AppTextStyles.labelMedium.copyWith(
              color: LightThemeColors.primary,
            )),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: LightThemeColors.primary,
            inactiveColor: AppColors.neutral200,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}

extension on StageStatus {
  String get label => switch (this) {
        StageStatus.notStarted => 'Not Started',
        StageStatus.inProgress => 'In Progress',
        StageStatus.completed => 'Completed',
        StageStatus.onHold => 'On Hold',
      };
}
