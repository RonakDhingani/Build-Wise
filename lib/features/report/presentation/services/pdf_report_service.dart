import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../utils/date_formatter.dart';
import '../../../material/domain/entities/material_entity.dart';
import '../../data/report_data.dart';

abstract class PdfReportService {
  static const _primary = PdfColor.fromInt(0xFF1E4D8C);
  static const _white60 = PdfColor(1, 1, 1, 0.6);
  static const _success = PdfColor.fromInt(0xFF16A34A);
  static const _warning = PdfColor.fromInt(0xFFD97706);
  static const _error = PdfColor.fromInt(0xFFDC2626);
  static const _textPrimary = PdfColor.fromInt(0xFF1A1A2E);
  static const _textSecondary = PdfColor.fromInt(0xFF6B6B8A);
  static const _border = PdfColor.fromInt(0xFFE8E8F0);
  static const _bgLight = PdfColor.fromInt(0xFFF4F4F8);

  static Future<Uint8List> generate(ReportData data) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => _buildPageHeader(data),
      footer: (ctx) => _buildPageFooter(ctx, data),
      build: (ctx) => [
        _buildCoverSection(data),
        pw.SizedBox(height: 20),
        _buildBudgetSection(data),
        pw.SizedBox(height: 20),
        if (data.stages.isNotEmpty) ...[
          _buildStagesSection(data),
          pw.SizedBox(height: 20),
        ],
        if (data.expenses.isNotEmpty) ...[
          _buildExpensesSection(data),
          pw.SizedBox(height: 20),
        ],
        if (data.materials.isNotEmpty)
          _buildMaterialsSection(data),
      ],
    ));

    return doc.save();
  }

  static pw.Widget _buildPageHeader(ReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _border, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'BuildWise',
            style: pw.TextStyle(
              color: _primary,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            data.project.name,
            style: pw.TextStyle(color: _textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPageFooter(
      pw.Context ctx, ReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated ${DateFormatter.format(data.generatedAt)}',
            style: pw.TextStyle(color: _textSecondary, fontSize: 9),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(color: _textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCoverSection(ReportData data) {
    final project = data.project;
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PROJECT REPORT',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            project.name,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            project.location,
            style: pw.TextStyle(color: _white60, fontSize: 12),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _coverStat('Start Date',
                  DateFormatter.format(project.startDate)),
              pw.SizedBox(width: 24),
              if (project.expectedCompletionDate != null)
                _coverStat(
                  'Expected Completion',
                  DateFormatter.format(project.expectedCompletionDate!),
                ),
              pw.SizedBox(width: 24),
              _coverStat('Report Date',
                  DateFormatter.format(data.generatedAt)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _coverStat(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(color: _white60, fontSize: 9),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBudgetSection(ReportData data) {
    final project = data.project;
    final spentPct = project.spentPercent;
    final healthColor = spentPct >= 0.9
        ? _error
        : spentPct >= 0.75
            ? _warning
            : _success;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Budget Overview'),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _budgetStatCard('Total Budget', _formatAmount(project.budget),
                _primary),
            pw.SizedBox(width: 12),
            _budgetStatCard(
                'Total Spent', _formatAmount(project.totalSpent), healthColor),
            pw.SizedBox(width: 12),
            _budgetStatCard('Remaining', _formatAmount(project.remaining),
                project.remaining >= 0 ? _success : _error),
          ],
        ),
        pw.SizedBox(height: 10),
        _progressBar(spentPct, healthColor,
            label: '${(spentPct * 100).toStringAsFixed(1)}% of budget used'),
      ],
    );
  }

  static pw.Widget _budgetStatCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _border),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(color: _textSecondary, fontSize: 9)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildStagesSection(ReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle(
            'Stage Progress  (${data.completedStages}/${data.stages.length} completed)'),
        pw.SizedBox(height: 10),
        ...data.stages.map((stage) {
          final color = _stageColor(stage.status.name);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 140,
                  child: pw.Text(
                    stage.name,
                    style: pw.TextStyle(fontSize: 10, color: _textPrimary),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _progressBar(stage.progressPercent / 100, color),
                ),
                pw.SizedBox(width: 8),
                pw.SizedBox(
                  width: 32,
                  child: pw.Text(
                    '${stage.progressPercent}%',
                    style: pw.TextStyle(fontSize: 9, color: color),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(width: 8),
                _statusBadge(stage.status.name),
              ],
            ),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildExpensesSection(ReportData data) {
    final byCategory = data.expensesByCategory;
    final total = data.totalExpenses;

    final rows = byCategory.entries.map((entry) {
      final cat = data.categories.where((c) => c.id == entry.key).firstOrNull;
      final pct = total > 0 ? (entry.value / total * 100) : 0.0;
      return [
        cat?.name ?? 'Uncategorized',
        _formatAmount(entry.value),
        '${pct.toStringAsFixed(1)}%',
      ];
    }).toList()
      ..sort((a, b) => a[0].compareTo(b[0]));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Expenses by Category  -  Total: ${_formatAmount(total)}'),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: _border, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _bgLight),
              children: [
                _tableHeader('Category'),
                _tableHeader('Amount'),
                _tableHeader('%'),
              ],
            ),
            ...rows.map((row) => pw.TableRow(
                  children: row
                      .map((cell) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: pw.Text(cell,
                                style: pw.TextStyle(fontSize: 9)),
                          ))
                      .toList(),
                )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildMaterialsSection(ReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Materials (${data.materials.length} items)'),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: _border, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _bgLight),
              children: [
                _tableHeader('Material'),
                _tableHeader('Purchased'),
                _tableHeader('Used'),
                _tableHeader('Remaining'),
                _tableHeader('Total Cost'),
              ],
            ),
            ...data.materials.map((m) => pw.TableRow(
                  children: [
                    _tableCell(m.name),
                    _tableCell(
                        '${m.quantityPurchased.toStringAsFixed(m.quantityPurchased.truncateToDouble() == m.quantityPurchased ? 0 : 1)} ${m.unit.label}'),
                    _tableCell(
                        '${m.quantityUsed.toStringAsFixed(m.quantityUsed.truncateToDouble() == m.quantityUsed ? 0 : 1)} ${m.unit.label}'),
                    _tableCell(
                        '${m.remaining.toStringAsFixed(m.remaining.truncateToDouble() == m.remaining ? 0 : 1)} ${m.unit.label}'),
                    _tableCell(
                        m.totalCost > 0 ? _formatAmount(m.totalCost) : '-'),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String text) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(
            color: _textPrimary,
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 2, color: _primary, width: 40),
      ],
    );
  }

  static pw.Widget _progressBar(
    double fraction,
    PdfColor color, {
    String? label,
  }) {
    final clamped = fraction.clamp(0.0, 1.0);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: 8,
          decoration: pw.BoxDecoration(
            color: _bgLight,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: (clamped * 100).round(),
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    color: color,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                ),
              ),
              if (clamped < 1.0)
                pw.Expanded(
                  flex: 100 - (clamped * 100).round(),
                  child: pw.SizedBox(),
                ),
            ],
          ),
        ),
        if (label != null) ...[
          pw.SizedBox(height: 3),
          pw.Text(label,
              style: pw.TextStyle(color: _textSecondary, fontSize: 8)),
        ],
      ],
    );
  }

  static pw.Widget _statusBadge(String statusName) {
    final color = _stageColor(statusName);
    final label = switch (statusName) {
      'notStarted' => 'Not Started',
      'inProgress' => 'In Progress',
      'completed' => 'Completed',
      'onHold' => 'On Hold',
      _ => statusName,
    };
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: PdfColor(color.red, color.green, color.blue, 0.12),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(color: color, fontSize: 8),
      ),
    );
  }

  static PdfColor _stageColor(String statusName) => switch (statusName) {
        'notStarted' => const PdfColor.fromInt(0xFFB2B2C8),
        'inProgress' => _primary,
        'completed' => _success,
        'onHold' => _warning,
        _ => _textSecondary,
      };

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: _textPrimary,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9)),
    );
  }

  // PDF base font (Helvetica) lacks the ₹ glyph, so use the ASCII "Rs"
  // prefix in generated reports to avoid tofu boxes.
  static String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return 'Rs ${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return 'Rs ${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return 'Rs ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return 'Rs ${amount.toStringAsFixed(0)}';
  }
}
