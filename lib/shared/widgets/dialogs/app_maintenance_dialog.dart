import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../buttons/app_primary_button.dart';

/// Full-screen, non-dismissible maintenance gate. Blocks the app while
/// `maintenance_enabled` is true. [onRetry] re-fetches Remote Config and must
/// return true when maintenance is OVER (dialog then closes).
class AppMaintenanceDialog {
  AppMaintenanceDialog._();

  static bool _isVisible = false;
  static bool get isVisible => _isVisible;
  static BuildContext? _dialogCtx;

  /// Programmatically close (e.g. resume re-check found maintenance is over).
  static void dismiss() {
    if (_isVisible && _dialogCtx != null && _dialogCtx!.mounted) {
      Navigator.of(_dialogCtx!).pop();
    }
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required Future<bool> Function() onRetry,
  }) async {
    if (_isVisible) return;
    _isVisible = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (ctx) {
          _dialogCtx = ctx;
          return _MaintenanceBody(
            title: title,
            message: message,
            onRetry: onRetry,
          );
        },
      );
    } finally {
      _isVisible = false;
      _dialogCtx = null;
    }
  }
}

class _MaintenanceBody extends StatefulWidget {
  const _MaintenanceBody({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final Future<bool> Function() onRetry;

  @override
  State<_MaintenanceBody> createState() => _MaintenanceBodyState();
}

class _MaintenanceBodyState extends State<_MaintenanceBody> {
  bool _busy = false;

  Future<void> _retry() async {
    setState(() => _busy = true);
    final cleared = await widget.onRetry();
    if (!mounted) return;
    if (cleared && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog.fullscreen(
        backgroundColor: LightThemeColors.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.gold400.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    ),
                    child: const Icon(Icons.engineering_outlined,
                        size: 44, color: AppColors.gold400),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(widget.title,
                      style: AppTextStyles.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.message,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: LightThemeColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppPrimaryButton(
                    label: 'Retry',
                    icon: Icons.refresh_rounded,
                    isLoading: _busy,
                    width: 200,
                    onPressed: _busy ? null : _retry,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
