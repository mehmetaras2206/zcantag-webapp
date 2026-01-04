// =============================================================================
// EXPORT_SERVICE.DART
// =============================================================================
// Analytics Export Service - CSV, XLSX, PDF
// =============================================================================

// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'dart:html' as html;

import '../../../../../shared/features/analytics/domain/entities/analytics.dart';

/// Export Service fuer Analytics-Daten
class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  /// Exportiert Daten im angegebenen Format
  Future<void> exportAnalytics({
    required ExportFormat format,
    required List<CardAnalytics> data,
    required String filename,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    switch (format) {
      case ExportFormat.csv:
        await _exportCSV(data, filename, startDate, endDate);
        break;
      case ExportFormat.xlsx:
        await _exportXLSX(data, filename, startDate, endDate);
        break;
      case ExportFormat.pdf:
        await _exportPDF(data, filename, startDate, endDate);
        break;
    }
  }

  /// CSV Export
  Future<void> _exportCSV(
    List<CardAnalytics> data,
    String filename,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      'Karten-ID,Gesamt Views,Unique Views,Kontakte gespeichert,Email Klicks,Telefon Klicks,Website Klicks,Social Klicks,Conversion Rate,CTR',
    );

    // Daten
    for (final card in data) {
      buffer.writeln([
        card.cardId,
        card.totalViews,
        card.uniqueViews,
        card.contactsSaved,
        card.clicksEmail,
        card.clicksPhone,
        card.clicksWebsite,
        card.clicksSocial,
        '${(card.conversionRate * 100).toStringAsFixed(2)}%',
        '${(card.clickThroughRate * 100).toStringAsFixed(2)}%',
      ].join(','));
    }

    // Metadaten
    if (startDate != null && endDate != null) {
      buffer.writeln('');
      buffer.writeln(
          'Zeitraum: ${_formatDate(startDate)} - ${_formatDate(endDate)}');
    }
    buffer.writeln('Exportiert am: ${_formatDate(DateTime.now())}');

    _downloadFile(buffer.toString(), '$filename.csv', 'text/csv');
  }

  /// XLSX Export (Vereinfachte Version als CSV mit Excel-Trennzeichen)
  Future<void> _exportXLSX(
    List<CardAnalytics> data,
    String filename,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    // Fuer Web verwenden wir CSV mit Semikolon-Trennung fuer bessere Excel-Kompatibilitaet
    final buffer = StringBuffer();

    // BOM fuer UTF-8
    buffer.write('\uFEFF');

    // Header
    buffer.writeln(
      'Karten-ID;Gesamt Views;Unique Views;Kontakte gespeichert;Email Klicks;Telefon Klicks;Website Klicks;Social Klicks;Conversion Rate;CTR',
    );

    // Daten
    for (final card in data) {
      buffer.writeln([
        card.cardId,
        card.totalViews,
        card.uniqueViews,
        card.contactsSaved,
        card.clicksEmail,
        card.clicksPhone,
        card.clicksWebsite,
        card.clicksSocial,
        '${(card.conversionRate * 100).toStringAsFixed(2)}%',
        '${(card.clickThroughRate * 100).toStringAsFixed(2)}%',
      ].join(';'));
    }

    // Metadaten
    if (startDate != null && endDate != null) {
      buffer.writeln('');
      buffer.writeln(
          'Zeitraum;${_formatDate(startDate)} - ${_formatDate(endDate)}');
    }
    buffer.writeln('Exportiert am;${_formatDate(DateTime.now())}');

    _downloadFile(
      buffer.toString(),
      '$filename.xlsx',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  /// PDF Export (Generiert HTML, das als PDF gedruckt werden kann)
  Future<void> _exportPDF(
    List<CardAnalytics> data,
    String filename,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final htmlContent = StringBuffer();

    htmlContent.writeln('''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>$filename</title>
  <style>
    body { font-family: Arial, sans-serif; padding: 20px; }
    h1 { color: #333; margin-bottom: 5px; }
    h2 { color: #666; font-size: 14px; margin-top: 0; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #FFDE00; color: #333; }
    tr:nth-child(even) { background-color: #f9f9f9; }
    .footer { margin-top: 20px; font-size: 12px; color: #999; }
    .summary { background-color: #f0f0f0; padding: 15px; margin-top: 20px; border-radius: 5px; }
    .summary h3 { margin-top: 0; }
    @media print {
      body { padding: 0; }
      .no-print { display: none; }
    }
  </style>
</head>
<body>
  <h1>ZCANTAG Analytics Report</h1>
''');

    if (startDate != null && endDate != null) {
      htmlContent.writeln(
          '<h2>Zeitraum: ${_formatDate(startDate)} - ${_formatDate(endDate)}</h2>');
    }

    // Zusammenfassung
    final totalViews = data.fold<int>(0, (sum, c) => sum + c.totalViews);
    final totalContacts = data.fold<int>(0, (sum, c) => sum + c.contactsSaved);
    final avgConversion = data.isEmpty
        ? 0.0
        : data.map((c) => c.conversionRate).reduce((a, b) => a + b) /
            data.length;

    htmlContent.writeln('''
  <div class="summary">
    <h3>Zusammenfassung</h3>
    <p><strong>Anzahl Karten:</strong> ${data.length}</p>
    <p><strong>Gesamt Views:</strong> ${_formatNumber(totalViews)}</p>
    <p><strong>Gesamt Kontakte:</strong> ${_formatNumber(totalContacts)}</p>
    <p><strong>Durchschnittliche Conversion:</strong> ${(avgConversion * 100).toStringAsFixed(2)}%</p>
  </div>
''');

    // Tabelle
    htmlContent.writeln('''
  <table>
    <thead>
      <tr>
        <th>Karten-ID</th>
        <th>Views</th>
        <th>Unique Views</th>
        <th>Kontakte</th>
        <th>Email</th>
        <th>Telefon</th>
        <th>Website</th>
        <th>Social</th>
        <th>Conversion</th>
        <th>CTR</th>
      </tr>
    </thead>
    <tbody>
''');

    for (final card in data) {
      htmlContent.writeln('''
      <tr>
        <td>${card.cardId}</td>
        <td>${_formatNumber(card.totalViews)}</td>
        <td>${_formatNumber(card.uniqueViews)}</td>
        <td>${_formatNumber(card.contactsSaved)}</td>
        <td>${_formatNumber(card.clicksEmail)}</td>
        <td>${_formatNumber(card.clicksPhone)}</td>
        <td>${_formatNumber(card.clicksWebsite)}</td>
        <td>${_formatNumber(card.clicksSocial)}</td>
        <td>${(card.conversionRate * 100).toStringAsFixed(2)}%</td>
        <td>${(card.clickThroughRate * 100).toStringAsFixed(2)}%</td>
      </tr>
''');
    }

    htmlContent.writeln('''
    </tbody>
  </table>
  <div class="footer">
    <p>Exportiert am: ${_formatDate(DateTime.now())} | ZCANTAG Analytics</p>
  </div>
  <div class="no-print" style="margin-top: 20px;">
    <button onclick="window.print()">Als PDF drucken</button>
  </div>
</body>
</html>
''');

    // Oeffne in neuem Tab zum Drucken
    final blob = html.Blob([htmlContent.toString()], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
  }

  /// Datei-Download
  void _downloadFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}

/// Export Dialog Widget
class ExportDialogData {
  const ExportDialogData({
    required this.format,
    required this.startDate,
    required this.endDate,
    this.selectedCardIds,
    this.includeDetails = false,
  });

  final ExportFormat format;
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? selectedCardIds;
  final bool includeDetails;
}
