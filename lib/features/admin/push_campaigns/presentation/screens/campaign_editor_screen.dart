// =============================================================================
// CAMPAIGN_EDITOR_SCREEN.DART
// =============================================================================
// Screen zum Erstellen/Bearbeiten einer Push-Kampagne
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/push_campaigns/domain/entities/push_campaign.dart';
import '../../../presentation/layouts/admin_shell.dart';
import '../providers/push_campaign_provider.dart';
import '../widgets/ab_test_editor.dart';
import '../widgets/segment_editor.dart';

class CampaignEditorScreen extends ConsumerStatefulWidget {
  const CampaignEditorScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  ConsumerState<CampaignEditorScreen> createState() =>
      _CampaignEditorScreenState();
}

class _CampaignEditorScreenState extends ConsumerState<CampaignEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _actionUrlController = TextEditingController();

  TargetType _targetType = TargetType.all;
  List<String> _selectedTags = [];
  DateTime? _scheduledAt;
  bool _isScheduled = false;
  bool _isSaving = false;

  // A/B Test State
  bool _isABTestEnabled = false;
  List<ABTestVariantData> _abTestVariants = [
    ABTestVariantData(id: 'variant_0', title: '', body: '', percentage: 50),
    ABTestVariantData(id: 'variant_1', title: '', body: '', percentage: 50),
  ];

  // Segment State
  SegmentData _segment = SegmentData(
    conditions: [
      SegmentCondition(
        id: 'condition_0',
        type: ConditionType.tag,
        value: '',
      ),
    ],
    operator: SegmentOperator.and,
  );

  bool get isEditing => widget.campaignId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      Future.microtask(() {
        ref
            .read(campaignDetailProvider.notifier)
            .loadCampaign(widget.campaignId!);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    _actionUrlController.dispose();
    super.dispose();
  }

  void _loadCampaignData(PushCampaign campaign) {
    _titleController.text = campaign.title;
    _bodyController.text = campaign.body;
    _imageUrlController.text = campaign.imageUrl ?? '';
    _actionUrlController.text = campaign.actionUrl ?? '';
    _targetType = campaign.targetAudience.type;
    _selectedTags = campaign.targetAudience.tags ?? [];
    _scheduledAt = campaign.scheduledAt;
    _isScheduled = campaign.scheduledAt != null;

    // A/B Test Data
    _isABTestEnabled = campaign.isABTest;
    if (campaign.abTestVariants != null && campaign.abTestVariants!.isNotEmpty) {
      _abTestVariants = campaign.abTestVariants!
          .map((v) => ABTestVariantData.fromEntity(v))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch campaign detail state when editing
    if (isEditing) {
      final detailState = ref.watch(campaignDetailProvider);
      if (detailState is CampaignDetailLoaded) {
        // Load data once
        if (_titleController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadCampaignData(detailState.campaign);
            setState(() {});
          });
        }
      }
    }

    return AdminShell(
      currentRoute: '/admin/campaigns',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/admin/campaigns'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Kampagne bearbeiten' : 'Neue Kampagne',
                    style: AppTextStyles.heading1,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Content & Preview
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildForm()),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _buildPreview()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildForm(),
                      const SizedBox(height: 24),
                      _buildPreview(),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Actions
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inhalt', style: AppTextStyles.heading3),
          const SizedBox(height: 16),

          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titel',
              hintText: 'Titel der Benachrichtigung',
              prefixIcon: Icon(Icons.title),
            ),
            maxLength: 50,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie einen Titel ein';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Body
          TextFormField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: 'Nachricht',
              hintText: 'Ihre Nachricht an die Empfaenger',
              prefixIcon: Icon(Icons.message),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 200,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie eine Nachricht ein';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Image URL (optional)
          TextFormField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: 'Bild-URL (optional)',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.image),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 16),

          // Action URL (optional)
          TextFormField(
            controller: _actionUrlController,
            decoration: const InputDecoration(
              labelText: 'Link bei Klick (optional)',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.link),
            ),
          ),

          const SizedBox(height: 32),

          // Target Audience
          Text('Zielgruppe', style: AppTextStyles.heading3),
          const SizedBox(height: 16),

          _buildTargetTypeSelector(),

          if (_targetType == TargetType.tags) ...[
            const SizedBox(height: 16),
            _buildTagsSelector(),
          ],

          if (_targetType == TargetType.segment) ...[
            const SizedBox(height: 16),
            SegmentEditor(
              segment: _segment,
              onChanged: (segment) {
                setState(() => _segment = segment);
              },
              availableTags: const ['VIP', 'Neu', 'Premium', 'Newsletter', 'Event'],
              availableCards: const [],
            ),
          ],

          const SizedBox(height: 32),

          // Scheduling
          Text('Zeitplanung', style: AppTextStyles.heading3),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Kampagne planen'),
            subtitle: Text(
              _isScheduled ? 'Wird zum geplanten Zeitpunkt gesendet' : 'Sofort senden',
            ),
            value: _isScheduled,
            onChanged: (value) {
              setState(() {
                _isScheduled = value;
                if (value && _scheduledAt == null) {
                  _scheduledAt =
                      DateTime.now().add(const Duration(hours: 1));
                }
              });
            },
          ),

          if (_isScheduled) ...[
            const SizedBox(height: 16),
            _buildDateTimePicker(),
          ],

          const SizedBox(height: 32),

          // A/B Test (Enterprise)
          ABTestEditor(
            isEnabled: _isABTestEnabled,
            onEnabledChanged: (enabled) {
              setState(() => _isABTestEnabled = enabled);
            },
            variants: _abTestVariants,
            onVariantsChanged: (variants) {
              setState(() => _abTestVariants = variants);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTargetTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TargetType.values.map((type) {
        final isSelected = _targetType == type;
        return ChoiceChip(
          label: Text(type.displayName),
          selected: isSelected,
          onSelected: (_) {
            setState(() => _targetType = type);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTagsSelector() {
    // Simplified tag selector for demo
    final availableTags = ['VIP', 'Neu', 'Premium', 'Newsletter', 'Event'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTags.add(tag);
              } else {
                _selectedTags.remove(tag);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateTimePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _scheduledAt ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );

        if (date != null && mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? DateTime.now()),
          );

          if (time != null) {
            setState(() {
              _scheduledAt = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
      child: Container(
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
            const Icon(Icons.calendar_today),
            const SizedBox(width: 12),
            Text(
              _scheduledAt != null
                  ? '${_scheduledAt!.day}.${_scheduledAt!.month}.${_scheduledAt!.year} um ${_scheduledAt!.hour}:${_scheduledAt!.minute.toString().padLeft(2, '0')} Uhr'
                  : 'Datum und Uhrzeit waehlen',
            ),
            const Spacer(),
            const Icon(Icons.edit),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vorschau', style: AppTextStyles.heading3),
          const SizedBox(height: 16),

          // Phone frame
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // Status bar placeholder
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDarker,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 16),

                // Notification
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Z',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _titleController.text.isEmpty
                                  ? 'Titel'
                                  : _titleController.text,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _bodyController.text.isEmpty
                                  ? 'Ihre Nachricht erscheint hier...'
                                  : _bodyController.text,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Image preview
                      if (_imageUrlController.text.isNotEmpty)
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 24),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Character count
          Text(
            'Titel: ${_titleController.text.length}/50 Zeichen',
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.5),
            ),
          ),
          Text(
            'Nachricht: ${_bodyController.text.length}/200 Zeichen',
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => context.go('/admin/campaigns'),
          child: const Text('Abbrechen'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveDraft,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.backgroundDarker,
          ),
          child: const Text('Als Entwurf speichern'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveAndSend,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDark,
          ),
          child: Text(_isScheduled ? 'Planen' : 'Speichern & Senden'),
        ),
      ],
    );
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final request = CreateCampaignRequest(
      title: _titleController.text,
      body: _bodyController.text,
      imageUrl:
          _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      actionUrl:
          _actionUrlController.text.isEmpty ? null : _actionUrlController.text,
      targetAudience: TargetAudience(
        type: _targetType,
        tags: _targetType == TargetType.tags ? _selectedTags : null,
      ),
      scheduledAt: _isScheduled ? _scheduledAt : null,
      abTestVariants: _isABTestEnabled
          ? _abTestVariants.map((v) => v.toEntity()).toList()
          : null,
    );

    final campaign =
        await ref.read(campaignsProvider.notifier).createCampaign(request);

    setState(() => _isSaving = false);

    if (campaign != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kampagne gespeichert')),
      );
      context.go('/admin/campaigns');
    }
  }

  Future<void> _saveAndSend() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isScheduled ? 'Kampagne planen?' : 'Kampagne senden?'),
        content: Text(_isScheduled
            ? 'Die Kampagne wird zum geplanten Zeitpunkt gesendet.'
            : 'Die Kampagne wird sofort an alle Empfaenger gesendet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(_isScheduled ? 'Planen' : 'Senden'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    final request = CreateCampaignRequest(
      title: _titleController.text,
      body: _bodyController.text,
      imageUrl:
          _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      actionUrl:
          _actionUrlController.text.isEmpty ? null : _actionUrlController.text,
      targetAudience: TargetAudience(
        type: _targetType,
        tags: _targetType == TargetType.tags ? _selectedTags : null,
      ),
      scheduledAt: _isScheduled ? _scheduledAt : null,
      abTestVariants: _isABTestEnabled
          ? _abTestVariants.map((v) => v.toEntity()).toList()
          : null,
    );

    final campaign =
        await ref.read(campaignsProvider.notifier).createCampaign(request);

    if (campaign != null && !_isScheduled) {
      await ref.read(campaignsProvider.notifier).sendCampaign(campaign.id);
    }

    setState(() => _isSaving = false);

    if (campaign != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isScheduled
              ? 'Kampagne geplant'
              : 'Kampagne wird gesendet...'),
        ),
      );
      context.go('/admin/campaigns');
    }
  }
}
