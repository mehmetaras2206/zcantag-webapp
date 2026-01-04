// =============================================================================
// EXPORT_DIALOG.DART
// =============================================================================
// Export Dialog fuer Analytics-Daten
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/analytics/domain/entities/analytics.dart';
import '../../services/export_service.dart';

/// Export Dialog
class ExportDialog extends StatefulWidget {
  const ExportDialog({
    super.key,
    this.availableCards = const [],
  });

  final List<({String id, String name})> availableCards;

  static Future<ExportDialogData?> show(
    BuildContext context, {
    List<({String id, String name})> availableCards = const [],
  }) {
    return showDialog<ExportDialogData>(
      context: context,
      builder: (context) => ExportDialog(availableCards: availableCards),
    );
  }

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final List<String> _selectedCardIds = [];
  bool _includeDetails = false;
  bool _selectAllCards = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.download, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daten exportieren', style: AppTextStyles.heading3),
                      const SizedBox(height: 4),
                      Text(
                        'Analytics-Daten als Datei herunterladen',
                        style: AppTextStyles.smallText.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Format-Auswahl
            Text(
              'Export-Format',
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _FormatButton(
                  format: ExportFormat.csv,
                  isSelected: _selectedFormat == ExportFormat.csv,
                  onTap: () => setState(() => _selectedFormat = ExportFormat.csv),
                  icon: Icons.table_chart,
                  label: 'CSV',
                  description: 'Tabellenformat',
                ),
                const SizedBox(width: 12),
                _FormatButton(
                  format: ExportFormat.xlsx,
                  isSelected: _selectedFormat == ExportFormat.xlsx,
                  onTap: () => setState(() => _selectedFormat = ExportFormat.xlsx),
                  icon: Icons.grid_on,
                  label: 'Excel',
                  description: 'Microsoft Excel',
                  isPremium: true,
                ),
                const SizedBox(width: 12),
                _FormatButton(
                  format: ExportFormat.pdf,
                  isSelected: _selectedFormat == ExportFormat.pdf,
                  onTap: () => setState(() => _selectedFormat = ExportFormat.pdf),
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  description: 'Druckbericht',
                  isPremium: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Zeitraum
            Text(
              'Zeitraum',
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Von',
                    date: _startDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: _endDate,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary,
                              surface: AppColors.backgroundDark,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward, color: Colors.white54),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateField(
                    label: 'Bis',
                    date: _endDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary,
                              surface: AppColors.backgroundDark,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Schnellauswahl
            Wrap(
              spacing: 8,
              children: [
                _QuickDateChip(
                  label: '7 Tage',
                  onTap: () => setState(() {
                    _endDate = DateTime.now();
                    _startDate = _endDate.subtract(const Duration(days: 7));
                  }),
                ),
                _QuickDateChip(
                  label: '30 Tage',
                  onTap: () => setState(() {
                    _endDate = DateTime.now();
                    _startDate = _endDate.subtract(const Duration(days: 30));
                  }),
                ),
                _QuickDateChip(
                  label: '90 Tage',
                  onTap: () => setState(() {
                    _endDate = DateTime.now();
                    _startDate = _endDate.subtract(const Duration(days: 90));
                  }),
                ),
                _QuickDateChip(
                  label: 'Dieses Jahr',
                  onTap: () => setState(() {
                    _endDate = DateTime.now();
                    _startDate = DateTime(_endDate.year, 1, 1);
                  }),
                ),
              ],
            ),

            // Karten-Auswahl (wenn verfuegbar)
            if (widget.availableCards.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Karten',
                    style: AppTextStyles.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectAllCards = !_selectAllCards;
                        if (_selectAllCards) {
                          _selectedCardIds.clear();
                        }
                      });
                    },
                    child: Text(
                      _selectAllCards ? 'Auswahl anpassen' : 'Alle auswaehlen',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              if (!_selectAllCards) ...[
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDarker,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: widget.availableCards.length,
                    itemBuilder: (context, index) {
                      final card = widget.availableCards[index];
                      final isSelected = _selectedCardIds.contains(card.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedCardIds.add(card.id);
                            } else {
                              _selectedCardIds.remove(card.id);
                            }
                          });
                        },
                        title: Text(
                          card.name,
                          style: AppTextStyles.smallText,
                        ),
                        activeColor: AppColors.primary,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Alle ${widget.availableCards.length} Karten werden exportiert',
                    style: AppTextStyles.smallText.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
            ],

            const SizedBox(height: 24),

            // Details Option
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundDarker,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _includeDetails,
                    onChanged: (value) =>
                        setState(() => _includeDetails = value ?? false),
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detaillierte Daten einschliessen',
                          style: AppTextStyles.bodyRegular,
                        ),
                        Text(
                          'Tagesgenaue Aufschluesselung, Geraete- und Standortdaten',
                          style: AppTextStyles.smallText.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Abbrechen',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(ExportDialogData(
                      format: _selectedFormat,
                      startDate: _startDate,
                      endDate: _endDate,
                      selectedCardIds:
                          _selectAllCards ? null : List.from(_selectedCardIds),
                      includeDetails: _includeDetails,
                    ));
                  },
                  icon: const Icon(Icons.download, color: Colors.black),
                  label: const Text(
                    'Exportieren',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.format,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.description,
    this.isPremium = false,
  });

  final ExportFormat format;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final String description;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.backgroundDarker,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected ? AppColors.primary : Colors.white70,
                  ),
                  if (isPremium)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodyRegular.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.smallText.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundDarker,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.smallText.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                  style: AppTextStyles.bodyRegular,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDateChip extends StatelessWidget {
  const _QuickDateChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.backgroundDarker,
      labelStyle: AppTextStyles.smallText,
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    );
  }
}
