// =============================================================================
// SEGMENT_EDITOR.DART
// =============================================================================
// Segment Editor fuer erweiterte Push-Zielgruppen Auswahl
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';

/// Segment Condition Types
enum ConditionType {
  tag('tag', 'Hat Tag', Icons.label),
  noTag('no_tag', 'Hat Tag nicht', Icons.label_off),
  contactAge('contact_age', 'Kontaktalter', Icons.calendar_today),
  lastActivity('last_activity', 'Letzte Aktivitaet', Icons.access_time),
  cardSource('card_source', 'Visitenkarte', Icons.credit_card),
  customField('custom_field', 'Benutzerdefiniert', Icons.tune);

  const ConditionType(this.value, this.displayName, this.icon);
  final String value;
  final String displayName;
  final IconData icon;
}

/// Segment Operator
enum SegmentOperator {
  and('and', 'UND'),
  or('or', 'ODER');

  const SegmentOperator(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Segment Condition
class SegmentCondition {
  const SegmentCondition({
    required this.id,
    required this.type,
    required this.value,
    this.operator,
  });

  final String id;
  final ConditionType type;
  final String value;
  final String? operator;

  SegmentCondition copyWith({
    String? id,
    ConditionType? type,
    String? value,
    String? operator,
  }) {
    return SegmentCondition(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      operator: operator ?? this.operator,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'value': value,
      if (operator != null) 'operator': operator,
    };
  }
}

/// Segment Data
class SegmentData {
  const SegmentData({
    this.name,
    required this.conditions,
    required this.operator,
    this.estimatedCount,
  });

  final String? name;
  final List<SegmentCondition> conditions;
  final SegmentOperator operator;
  final int? estimatedCount;

  SegmentData copyWith({
    String? name,
    List<SegmentCondition>? conditions,
    SegmentOperator? operator,
    int? estimatedCount,
  }) {
    return SegmentData(
      name: name ?? this.name,
      conditions: conditions ?? this.conditions,
      operator: operator ?? this.operator,
      estimatedCount: estimatedCount ?? this.estimatedCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'operator': operator.value,
    };
  }
}

/// Segment Editor Widget
class SegmentEditor extends StatefulWidget {
  const SegmentEditor({
    super.key,
    required this.segment,
    required this.onChanged,
    this.availableTags = const [],
    this.availableCards = const [],
  });

  final SegmentData segment;
  final ValueChanged<SegmentData> onChanged;
  final List<String> availableTags;
  final List<CardOption> availableCards;

  @override
  State<SegmentEditor> createState() => _SegmentEditorState();
}

class _SegmentEditorState extends State<SegmentEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.filter_list, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('Segment definieren', style: AppTextStyles.heading3),
              const Spacer(),
              // Estimated count
              if (widget.segment.estimatedCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '~${widget.segment.estimatedCount} Kontakte',
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Operator Toggle
          Row(
            children: [
              Text(
                'Bedingungen verknuepfen mit:',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 12),
              ToggleButtons(
                isSelected: [
                  widget.segment.operator == SegmentOperator.and,
                  widget.segment.operator == SegmentOperator.or,
                ],
                onPressed: (index) {
                  widget.onChanged(widget.segment.copyWith(
                    operator:
                        index == 0 ? SegmentOperator.and : SegmentOperator.or,
                  ));
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: AppColors.backgroundDarker,
                fillColor: AppColors.primary,
                color: AppColors.textWhite,
                constraints: const BoxConstraints(minWidth: 60, minHeight: 32),
                children: const [
                  Text('UND'),
                  Text('ODER'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Conditions List
          ...widget.segment.conditions.asMap().entries.map((entry) {
            final index = entry.key;
            final condition = entry.value;
            return Column(
              children: [
                if (index > 0) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.segment.operator.displayName,
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _ConditionCard(
                  condition: condition,
                  availableTags: widget.availableTags,
                  availableCards: widget.availableCards,
                  canRemove: widget.segment.conditions.length > 1,
                  onChanged: (updated) {
                    final newConditions =
                        List<SegmentCondition>.from(widget.segment.conditions);
                    newConditions[index] = updated;
                    widget.onChanged(
                      widget.segment.copyWith(conditions: newConditions),
                    );
                  },
                  onRemove: () {
                    final newConditions =
                        List<SegmentCondition>.from(widget.segment.conditions);
                    newConditions.removeAt(index);
                    widget.onChanged(
                      widget.segment.copyWith(conditions: newConditions),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          }),

          // Add Condition Button
          Center(
            child: OutlinedButton.icon(
              onPressed: _addCondition,
              icon: const Icon(Icons.add),
              label: const Text('Bedingung hinzufuegen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addCondition() {
    final newConditions =
        List<SegmentCondition>.from(widget.segment.conditions);
    newConditions.add(SegmentCondition(
      id: 'condition_${DateTime.now().millisecondsSinceEpoch}',
      type: ConditionType.tag,
      value: '',
    ));
    widget.onChanged(widget.segment.copyWith(conditions: newConditions));
  }
}

/// Card Option for card source selection
class CardOption {
  const CardOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

/// Single Condition Card
class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.condition,
    required this.availableTags,
    required this.availableCards,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final SegmentCondition condition;
  final List<String> availableTags;
  final List<CardOption> availableCards;
  final bool canRemove;
  final ValueChanged<SegmentCondition> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Condition Type Dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<ConditionType>(
              value: condition.type,
              decoration: InputDecoration(
                labelText: 'Bedingung',
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: ConditionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 18),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) {
                  onChanged(condition.copyWith(type: type, value: ''));
                }
              },
            ),
          ),

          const SizedBox(width: 12),

          // Value Input (depends on condition type)
          Expanded(
            flex: 3,
            child: _buildValueInput(),
          ),

          if (canRemove) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.error,
              onPressed: onRemove,
              tooltip: 'Bedingung entfernen',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildValueInput() {
    switch (condition.type) {
      case ConditionType.tag:
      case ConditionType.noTag:
        return DropdownButtonFormField<String>(
          value: condition.value.isEmpty ? null : condition.value,
          decoration: InputDecoration(
            labelText: 'Tag auswaehlen',
            filled: true,
            fillColor: AppColors.backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: [
            const DropdownMenuItem(
              value: '',
              child: Text('Tag waehlen...'),
            ),
            ...availableTags.map((tag) {
              return DropdownMenuItem(
                value: tag,
                child: Text(tag),
              );
            }),
          ],
          onChanged: (value) {
            onChanged(condition.copyWith(value: value ?? ''));
          },
        );

      case ConditionType.contactAge:
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: condition.operator ?? 'gte',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'gte', child: Text('mindestens')),
                  DropdownMenuItem(value: 'lte', child: Text('hoechstens')),
                  DropdownMenuItem(value: 'eq', child: Text('genau')),
                ],
                onChanged: (op) {
                  onChanged(condition.copyWith(operator: op));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: condition.value,
                decoration: InputDecoration(
                  labelText: 'Tage',
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  onChanged(condition.copyWith(value: value));
                },
              ),
            ),
          ],
        );

      case ConditionType.lastActivity:
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: condition.operator ?? 'within',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'within', child: Text('innerhalb')),
                  DropdownMenuItem(value: 'not_within', child: Text('nicht innerhalb')),
                ],
                onChanged: (op) {
                  onChanged(condition.copyWith(operator: op));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: condition.value.isEmpty ? '7' : condition.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: '7', child: Text('7 Tage')),
                  DropdownMenuItem(value: '14', child: Text('14 Tage')),
                  DropdownMenuItem(value: '30', child: Text('30 Tage')),
                  DropdownMenuItem(value: '90', child: Text('90 Tage')),
                ],
                onChanged: (value) {
                  onChanged(condition.copyWith(value: value ?? '7'));
                },
              ),
            ),
          ],
        );

      case ConditionType.cardSource:
        return DropdownButtonFormField<String>(
          value: condition.value.isEmpty ? null : condition.value,
          decoration: InputDecoration(
            labelText: 'Visitenkarte auswaehlen',
            filled: true,
            fillColor: AppColors.backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: [
            const DropdownMenuItem(
              value: '',
              child: Text('Karte waehlen...'),
            ),
            ...availableCards.map((card) {
              return DropdownMenuItem(
                value: card.id,
                child: Text(card.name),
              );
            }),
          ],
          onChanged: (value) {
            onChanged(condition.copyWith(value: value ?? ''));
          },
        );

      case ConditionType.customField:
        return TextFormField(
          initialValue: condition.value,
          decoration: InputDecoration(
            labelText: 'Wert',
            hintText: 'field=value',
            filled: true,
            fillColor: AppColors.backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            onChanged(condition.copyWith(value: value));
          },
        );
    }
  }
}
