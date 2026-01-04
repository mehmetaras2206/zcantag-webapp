// =============================================================================
// AB_TEST_EDITOR.DART
// =============================================================================
// A/B Test Varianten Editor fuer Push-Kampagnen (Enterprise)
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/push_campaigns/domain/entities/push_campaign.dart';

/// A/B Test Editor Widget
class ABTestEditor extends StatefulWidget {
  const ABTestEditor({
    super.key,
    required this.isEnabled,
    required this.onEnabledChanged,
    required this.variants,
    required this.onVariantsChanged,
    this.maxVariants = 4,
  });

  /// Ist A/B-Test aktiviert
  final bool isEnabled;

  /// Callback wenn aktiviert/deaktiviert
  final ValueChanged<bool> onEnabledChanged;

  /// Aktuelle Varianten
  final List<ABTestVariantData> variants;

  /// Callback wenn Varianten geaendert
  final ValueChanged<List<ABTestVariantData>> onVariantsChanged;

  /// Maximale Anzahl Varianten
  final int maxVariants;

  @override
  State<ABTestEditor> createState() => _ABTestEditorState();
}

class _ABTestEditorState extends State<ABTestEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isEnabled
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('A/B-Test', style: AppTextStyles.heading3),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ENTERPRISE',
                            style: AppTextStyles.smallText.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Testen Sie verschiedene Nachrichtenvarianten',
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.isEnabled,
                onChanged: widget.onEnabledChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),

          if (widget.isEnabled) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Varianten-Liste
            ...widget.variants.asMap().entries.map((entry) {
              final index = entry.key;
              final variant = entry.value;
              return _VariantCard(
                variant: variant,
                index: index,
                isRemovable: widget.variants.length > 2,
                onChanged: (updated) {
                  final updatedList = List<ABTestVariantData>.from(widget.variants);
                  updatedList[index] = updated;
                  widget.onVariantsChanged(updatedList);
                },
                onRemove: () {
                  final updatedList = List<ABTestVariantData>.from(widget.variants);
                  updatedList.removeAt(index);
                  _rebalancePercentages(updatedList);
                  widget.onVariantsChanged(updatedList);
                },
              );
            }),

            // Variante hinzufuegen Button
            if (widget.variants.length < widget.maxVariants) ...[
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _addVariant,
                  icon: const Icon(Icons.add),
                  label: Text('Variante ${_getVariantLetter(widget.variants.length)} hinzufuegen'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Verteilungs-Anzeige
            _buildDistributionIndicator(),

            const SizedBox(height: 16),

            // Info-Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Jede Variante wird an den angegebenen Prozentsatz der Zielgruppe gesendet. Nach dem Test koennen Sie die beste Variante analysieren.',
                      style: AppTextStyles.smallText.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addVariant() {
    final newVariants = List<ABTestVariantData>.from(widget.variants);
    newVariants.add(ABTestVariantData(
      id: 'variant_${newVariants.length}',
      title: '',
      body: '',
      percentage: 0,
    ));
    _rebalancePercentages(newVariants);
    widget.onVariantsChanged(newVariants);
  }

  void _rebalancePercentages(List<ABTestVariantData> variants) {
    if (variants.isEmpty) return;
    final equalShare = 100 ~/ variants.length;
    final remainder = 100 % variants.length;

    for (var i = 0; i < variants.length; i++) {
      variants[i] = variants[i].copyWith(
        percentage: equalShare + (i < remainder ? 1 : 0),
      );
    }
  }

  String _getVariantLetter(int index) {
    return String.fromCharCode('A'.codeUnitAt(0) + index);
  }

  Widget _buildDistributionIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verteilung',
          style: AppTextStyles.smallText.copyWith(
            color: AppColors.textWhite.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: widget.variants.asMap().entries.map((entry) {
              final variant = entry.value;
              return Expanded(
                flex: variant.percentage,
                child: Container(
                  height: 24,
                  color: _getVariantColor(entry.key),
                  child: Center(
                    child: Text(
                      '${_getVariantLetter(entry.key)}: ${variant.percentage}%',
                      style: AppTextStyles.smallText.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getVariantColor(int index) {
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];
    return colors[index % colors.length];
  }
}

/// Varianten-Daten
class ABTestVariantData {
  const ABTestVariantData({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.percentage,
  });

  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final int percentage;

  ABTestVariantData copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    int? percentage,
  }) {
    return ABTestVariantData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      percentage: percentage ?? this.percentage,
    );
  }

  ABTestVariant toEntity() {
    return ABTestVariant(
      variantId: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      percentage: percentage,
    );
  }

  static ABTestVariantData fromEntity(ABTestVariant entity) {
    return ABTestVariantData(
      id: entity.variantId,
      title: entity.title,
      body: entity.body,
      imageUrl: entity.imageUrl,
      percentage: entity.percentage,
    );
  }
}

/// Einzelne Varianten-Karte
class _VariantCard extends StatefulWidget {
  const _VariantCard({
    required this.variant,
    required this.index,
    required this.isRemovable,
    required this.onChanged,
    required this.onRemove,
  });

  final ABTestVariantData variant;
  final int index;
  final bool isRemovable;
  final ValueChanged<ABTestVariantData> onChanged;
  final VoidCallback onRemove;

  @override
  State<_VariantCard> createState() => _VariantCardState();
}

class _VariantCardState extends State<_VariantCard> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.variant.title);
    _bodyController = TextEditingController(text: widget.variant.body);
    _imageUrlController = TextEditingController(text: widget.variant.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  String _getVariantLetter() {
    return String.fromCharCode('A'.codeUnitAt(0) + widget.index);
  }

  Color _getVariantColor() {
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];
    return colors[widget.index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getVariantColor().withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getVariantColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _getVariantLetter(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Variante ${_getVariantLetter()}',
                style: AppTextStyles.bodyRegular.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Prozentsatz-Slider
              SizedBox(
                width: 120,
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Slider(
                        value: widget.variant.percentage.toDouble(),
                        min: 10,
                        max: 90,
                        divisions: 8,
                        activeColor: _getVariantColor(),
                        onChanged: (value) {
                          widget.onChanged(
                            widget.variant.copyWith(percentage: value.round()),
                          );
                        },
                      ),
                    ),
                    Text(
                      '${widget.variant.percentage}%',
                      style: AppTextStyles.smallText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isRemovable)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.error,
                  onPressed: widget.onRemove,
                  tooltip: 'Variante entfernen',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Titel
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Titel',
              hintText: 'Titel fuer Variante ${_getVariantLetter()}',
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.title, size: 20),
              isDense: true,
            ),
            onChanged: (value) {
              widget.onChanged(widget.variant.copyWith(title: value));
            },
          ),

          const SizedBox(height: 12),

          // Body
          TextFormField(
            controller: _bodyController,
            decoration: InputDecoration(
              labelText: 'Nachricht',
              hintText: 'Nachricht fuer Variante ${_getVariantLetter()}',
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.message, size: 20),
              alignLabelWithHint: true,
              isDense: true,
            ),
            maxLines: 2,
            onChanged: (value) {
              widget.onChanged(widget.variant.copyWith(body: value));
            },
          ),

          const SizedBox(height: 12),

          // Image URL (optional)
          TextFormField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              labelText: 'Bild-URL (optional)',
              hintText: 'https://...',
              filled: true,
              fillColor: AppColors.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.image, size: 20),
              isDense: true,
            ),
            onChanged: (value) {
              widget.onChanged(
                widget.variant.copyWith(imageUrl: value.isEmpty ? null : value),
              );
            },
          ),
        ],
      ),
    );
  }
}
