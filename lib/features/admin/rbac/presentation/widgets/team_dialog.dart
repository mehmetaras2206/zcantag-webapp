// =============================================================================
// TEAM_DIALOG.DART
// =============================================================================
// Dialog fuer Team erstellen/bearbeiten
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/rbac/domain/entities/rbac.dart';
import '../../../../../shared/features/rbac/data/dtos/rbac_dto.dart';
import '../providers/rbac_provider.dart';

/// Dialog zum Erstellen oder Bearbeiten eines Teams
class TeamDialog extends ConsumerStatefulWidget {
  const TeamDialog({
    super.key,
    this.team,
    required this.companyId,
  });

  /// Zu bearbeitendes Team (null = neues Team erstellen)
  final Team? team;

  /// Company ID
  final String companyId;

  /// Zeigt den Dialog an und gibt true zurueck wenn erfolgreich
  static Future<bool?> show(
    BuildContext context, {
    Team? team,
    required String companyId,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => TeamDialog(
        team: team,
        companyId: companyId,
      ),
    );
  }

  @override
  ConsumerState<TeamDialog> createState() => _TeamDialogState();
}

class _TeamDialogState extends ConsumerState<TeamDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _selectedParentTeamId;
  String? _selectedLeaderId;
  bool _isLoading = false;

  bool get isEditing => widget.team != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.team?.description ?? '',
    );
    _selectedParentTeamId = widget.team?.parentTeamId;
    _selectedLeaderId = widget.team?.leaderId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success;
    if (isEditing) {
      // Update existing team
      success = await ref.read(teamsProvider.notifier).updateTeam(
            widget.team!.id,
            TeamUpdateDto(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
              parentTeamId: _selectedParentTeamId,
              leaderId: _selectedLeaderId,
            ),
          );
    } else {
      // Create new team
      success = await ref.read(teamsProvider.notifier).createTeam(
            TeamCreateDto(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim().isNotEmpty
                  ? _descriptionController.text.trim()
                  : null,
              companyId: widget.companyId,
              parentTeamId: _selectedParentTeamId,
              leaderId: _selectedLeaderId,
            ),
          );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Fehler beim Aktualisieren des Teams'
                  : 'Fehler beim Erstellen des Teams',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamsState = ref.watch(teamsProvider);
    final membersState = ref.watch(membersProvider);

    // Available teams for parent selection (exclude current team if editing)
    final availableTeams = teamsState is TeamsLoaded
        ? teamsState.teams
            .where((t) => !isEditing || t.id != widget.team!.id)
            .toList()
        : <Team>[];

    // Available members for leader selection
    final availableMembers =
        membersState is MembersLoaded ? membersState.members : <TeamMember>[];

    return AlertDialog(
      backgroundColor: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.group_add,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Team bearbeiten' : 'Neues Team erstellen',
            style: AppTextStyles.heading2,
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Name
              Text(
                'Teamname *',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'z.B. Vertrieb, Marketing, Support',
                  filled: true,
                  fillColor: AppColors.backgroundDarker,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte geben Sie einen Teamnamen ein';
                  }
                  if (value.trim().length < 2) {
                    return 'Der Name muss mindestens 2 Zeichen lang sein';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                'Beschreibung',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Kurze Beschreibung des Teams (optional)',
                  filled: true,
                  fillColor: AppColors.backgroundDarker,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                maxLines: 2,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 20),

              // Parent Team
              Text(
                'Uebergeordnetes Team',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _selectedParentTeamId,
                decoration: InputDecoration(
                  hintText: 'Kein uebergeordnetes Team',
                  filled: true,
                  fillColor: AppColors.backgroundDarker,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.account_tree_outlined),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Kein uebergeordnetes Team'),
                  ),
                  ...availableTeams.map((team) => DropdownMenuItem<String?>(
                        value: team.id,
                        child: Text(team.name),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedParentTeamId = value);
                },
              ),

              const SizedBox(height: 20),

              // Team Leader
              Text(
                'Teamleiter',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _selectedLeaderId,
                decoration: InputDecoration(
                  hintText: 'Keinen Teamleiter zuweisen',
                  filled: true,
                  fillColor: AppColors.backgroundDarker,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Keinen Teamleiter zuweisen'),
                  ),
                  ...availableMembers.map((member) => DropdownMenuItem<String?>(
                        value: member.userId,
                        child: Text(
                          '${member.fullName} (${member.role.displayName})',
                        ),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedLeaderId = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.backgroundDarker,
                  ),
                )
              : Text(isEditing ? 'Speichern' : 'Erstellen'),
        ),
      ],
    );
  }
}
