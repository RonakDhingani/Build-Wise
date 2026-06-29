import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/result/result.dart';
import '../../../shared/widgets/index.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../models/support_request.dart';
import '../providers/contact_support_providers.dart';
import '../widgets/support_type_card.dart';

/// Native Contact Support screen (no WebView). Three cards open the email
/// client; the form submits to Firestore. Material 3, Build Wise styling.
class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  ConsumerState<ContactSupportScreen> createState() =>
      _ContactSupportScreenState();
}

class _ContactSupportScreenState
    extends ConsumerState<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  SupportRequestType _type = SupportRequestType.support;
  bool _sending = false;

  static const _typeItems = [
    DropdownMenuItem(value: SupportRequestType.support, child: Text('Support')),
    DropdownMenuItem(
        value: SupportRequestType.featureRequest,
        child: Text('Feature Request')),
    DropdownMenuItem(
        value: SupportRequestType.bugReport, child: Text('Bug Report')),
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _openEmail(SupportRequestType type) async {
    final ok =
        await ref.read(contactSupportRepositoryProvider).openEmailDraft(type);
    if (!ok && mounted) {
      _snack('Could not open your email app.', error: true);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);

    final result = await ref.read(contactSupportRepositoryProvider).submit(
          name: _name.text,
          email: _email.text,
          subject: _subject.text,
          message: _message.text,
          requestType: _type,
        );
    if (!mounted) return;
    setState(() => _sending = false);

    result.when(
      success: (_) {
        _snack(
            'Message sent successfully. Our team will review your request soon.');
        context.pop();
      },
      failure: (f) => _snack(f.message, error: true),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error500 : null,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppBarWidget(title: 'Contact Support'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          children: [
            Text('Reach us directly', style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SupportTypeCard(
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.violet,
              title: 'Support',
              subtitle: 'Get help using BuildWise',
              onTap: () => _openEmail(SupportRequestType.support),
            ),
            const SizedBox(height: AppSpacing.md),
            SupportTypeCard(
              icon: Icons.lightbulb_outline_rounded,
              iconColor: AppColors.gold400,
              title: 'Feature Request',
              subtitle: 'Suggest an improvement',
              onTap: () => _openEmail(SupportRequestType.featureRequest),
            ),
            const SizedBox(height: AppSpacing.md),
            SupportTypeCard(
              icon: Icons.bug_report_outlined,
              iconColor: AppColors.error500,
              title: 'Bug Report',
              subtitle: 'Tell us what went wrong',
              onTap: () => _openEmail(SupportRequestType.bugReport),
            ),

            const SizedBox(height: AppSpacing.xl),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('or send us a message',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: LightThemeColors.textTertiary)),
              ),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: AppSpacing.lg),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppDropdownField<SupportRequestType>(
                    label: 'Topic',
                    value: _type,
                    items: _typeItems,
                    onChanged: (v) =>
                        setState(() => _type = v ?? SupportRequestType.support),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Name',
                    controller: _name,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 120,
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Subject',
                    controller: _subject,
                    maxLength: 100,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Subject is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Message',
                    controller: _message,
                    maxLines: 5,
                    maxLength: 1000,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Message is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppPrimaryButton(
                    label: 'Send Message',
                    icon: Icons.send_rounded,
                    isLoading: _sending,
                    onPressed: _sending ? null : _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
