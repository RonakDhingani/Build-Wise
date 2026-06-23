import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../shared/widgets/index.dart';
import '../../domain/report_type.dart';
import '../providers/report_providers.dart';
import '../services/pdf_report_service.dart';

class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({
    super.key,
    required this.projectId,
    this.reportType = ReportType.full,
  });

  final int projectId;
  final ReportType reportType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reportDataProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(reportType.appBarTitle),
        centerTitle: false,
      ),
      body: async.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorState(
          message: 'Failed to generate report.',
          onRetry: () => ref.invalidate(reportDataProvider(projectId)),
        ),
        data: (reportData) => PdfPreview(
          build: (_) =>
              PdfReportService.generate(reportData, type: reportType),
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          pdfFileName:
              '${reportData.project.name.replaceAll(' ', '_')}_${reportType.fileSuffix}.pdf',
        ),
      ),
    );
  }
}
