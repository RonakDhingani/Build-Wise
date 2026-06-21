import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../shared/widgets/index.dart';
import '../providers/report_providers.dart';
import '../services/pdf_report_service.dart';

class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reportDataProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        centerTitle: false,
      ),
      body: async.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorState(
          message: 'Failed to generate report.',
          onRetry: () => ref.invalidate(reportDataProvider(projectId)),
        ),
        data: (reportData) => PdfPreview(
          build: (_) => PdfReportService.generate(reportData),
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          pdfFileName:
              '${reportData.project.name.replaceAll(' ', '_')}_Report.pdf',
        ),
      ),
    );
  }
}
