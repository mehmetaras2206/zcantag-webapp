// =============================================================================
// TEAM_LIST_SCREEN.DART
// =============================================================================
// Team-Mitglieder Uebersicht
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/rbac/domain/entities/rbac.dart';
import '../../../presentation/layouts/admin_shell.dart';
import '../providers/rbac_provider.dart';
import '../widgets/team_dialog.dart';

class TeamListScreen extends ConsumerStatefulWidget {
  const TeamListScreen({super.key});

  @override
  ConsumerState<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends ConsumerState<TeamListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserRole? _filterRole;

  // TODO: Aus Auth-State laden
  static const String _companyId = 'mock-company-id';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(membersProvider.notifier).loadMembers(_companyId);
      ref.read(teamsProvider.notifier).loadTeams();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(membersProvider);
    final teamsState = ref.watch(teamsProvider);

    return AdminShell(
      currentRoute: '/admin/team',
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Team verwalten', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Mitarbeiter und Teams verwalten',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showTeamDialog(),
                      icon: const Icon(Icons.group_add),
                      label: const Text('Team erstellen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundDark,
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/admin/team/invite'),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Mitarbeiter einladen'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: AppColors.backgroundDarker,
              unselectedLabelColor: AppColors.textWhite.withValues(alpha: 0.7),
              tabs: const [
                Tab(text: 'Mitglieder'),
                Tab(text: 'Teams'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(membersState),
                _buildTeamsTab(teamsState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(MembersState state) {
    return switch (state) {
      MembersInitial() => const Center(child: CircularProgressIndicator()),
      MembersLoading() => const Center(child: CircularProgressIndicator()),
      MembersError(:final message) => _buildError(message, isMembers: true),
      MembersLoaded(:final members) => _buildMembersList(members),
    };
  }

  Widget _buildTeamsTab(TeamsState state) {
    return switch (state) {
      TeamsInitial() => const Center(child: CircularProgressIndicator()),
      TeamsLoading() => const Center(child: CircularProgressIndicator()),
      TeamsError(:final message) => _buildError(message, isMembers: false),
      TeamsLoaded(:final teams) => _buildTeamsList(teams),
    };
  }

  Widget _buildError(String message, {required bool isMembers}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Fehler beim Laden', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (isMembers) {
                ref
                    .read(membersProvider.notifier)
                    .loadMembers('mock-company-id');
              } else {
                ref.read(teamsProvider.notifier).loadTeams();
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(List<TeamMember> members) {
    // Filter anwenden
    var filteredMembers = members;
    if (_filterRole != null) {
      filteredMembers =
          members.where((m) => m.role == _filterRole).toList();
    }

    return Column(
      children: [
        // Filter-Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Alle'),
                const SizedBox(width: 8),
                ...UserRole.values.map((role) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(role, role.displayName),
                    )),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Liste
        Expanded(
          child: filteredMembers.isEmpty
              ? _buildEmptyMembers()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    return _MemberCard(
                      member: member,
                      onRoleChange: (newRole) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success = await ref
                            .read(membersProvider.notifier)
                            .updateRole(
                              'mock-company-id',
                              member.userId,
                              newRole,
                            );
                        if (mounted && !success) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Fehler beim Aendern der Rolle'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      onRemove: () => _showRemoveMemberDialog(member),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(UserRole? role, String label) {
    final isSelected = _filterRole == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.backgroundDarker,
      onSelected: (selected) {
        setState(() => _filterRole = selected ? role : null);
      },
    );
  }

  Widget _buildEmptyMembers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textWhite.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text('Keine Mitglieder gefunden', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            _filterRole != null
                ? 'Keine Mitglieder mit dieser Rolle'
                : 'Laden Sie Ihr Team ein',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
          ),
          if (_filterRole == null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/team/invite'),
              icon: const Icon(Icons.person_add),
              label: const Text('Mitarbeiter einladen'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamsList(List<Team> teams) {
    return teams.isEmpty
        ? _buildEmptyTeams()
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return _TeamCard(
                team: team,
                onEdit: () => _showTeamDialog(team: team),
                onDelete: () => _showDeleteTeamDialog(team),
              );
            },
          );
  }

  Widget _buildEmptyTeams() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: AppColors.textWhite.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text('Keine Teams', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'Erstellen Sie Teams fuer Ihre Organisation',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showTeamDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Team erstellen'),
          ),
        ],
      ),
    );
  }

  /// Zeigt den Team-Dialog (erstellen oder bearbeiten)
  Future<void> _showTeamDialog({Team? team}) async {
    final success = await TeamDialog.show(
      context,
      team: team,
      companyId: _companyId,
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            team != null
                ? 'Team erfolgreich aktualisiert'
                : 'Team erfolgreich erstellt',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _showRemoveMemberDialog(TeamMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mitglied entfernen'),
        content: Text(
          'Moechten Sie ${member.fullName} wirklich aus dem Team entfernen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(membersProvider.notifier)
          .removeMember('mock-company-id', member.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Mitglied erfolgreich entfernt'
                  : 'Fehler beim Entfernen',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteTeamDialog(Team team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Team loeschen'),
        content: Text(
          'Moechten Sie das Team "${team.name}" wirklich loeschen? '
          'Die Mitglieder werden nicht entfernt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Loeschen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await ref.read(teamsProvider.notifier).deleteTeam(team.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Team erfolgreich geloescht' : 'Fehler beim Loeschen',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }
}

// =============================================================================
// MEMBER CARD
// =============================================================================

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.onRoleChange,
    required this.onRemove,
  });

  final TeamMember member;
  final ValueChanged<UserRole> onRoleChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.backgroundDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              backgroundImage:
                  member.hasAvatar ? NetworkImage(member.avatarUrl!) : null,
              child: member.hasAvatar
                  ? null
                  : Text(
                      member.initials,
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.backgroundDarker,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: AppTextStyles.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.email,
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.7),
                    ),
                  ),
                  if (member.teamName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.group,
                          size: 14,
                          color: AppColors.textWhite.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.teamName!,
                          style: AppTextStyles.smallText.copyWith(
                            color: AppColors.textWhite.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 14,
                      color: AppColors.textWhite.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${member.cardCount}',
                      style: AppTextStyles.smallText,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.contacts,
                      size: 14,
                      color: AppColors.textWhite.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${member.contactCount}',
                      style: AppTextStyles.smallText,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 16),

            // Role Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(member.role).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRoleColor(member.role).withValues(alpha: 0.3),
                ),
              ),
              child: PopupMenuButton<UserRole>(
                initialValue: member.role,
                onSelected: onRoleChange,
                itemBuilder: (context) => UserRole.values.map((role) {
                  return PopupMenuItem<UserRole>(
                    value: role,
                    child: Row(
                      children: [
                        Icon(
                          _getRoleIcon(role),
                          size: 18,
                          color: _getRoleColor(role),
                        ),
                        const SizedBox(width: 8),
                        Text(role.displayName),
                      ],
                    ),
                  );
                }).toList(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRoleIcon(member.role),
                      size: 16,
                      color: _getRoleColor(member.role),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      member.role.displayName,
                      style: AppTextStyles.smallText.copyWith(
                        color: _getRoleColor(member.role),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: _getRoleColor(member.role),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Actions
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error.withValues(alpha: 0.7),
              onPressed: onRemove,
              tooltip: 'Entfernen',
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.orange;
      case UserRole.regionalleiter:
        return Colors.purple;
      case UserRole.filialleiter:
        return Colors.blue;
      case UserRole.teamleiter:
        return Colors.green;
      case UserRole.mitarbeiter:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.regionalleiter:
        return Icons.public;
      case UserRole.filialleiter:
        return Icons.store;
      case UserRole.teamleiter:
        return Icons.groups;
      case UserRole.mitarbeiter:
        return Icons.person;
    }
  }
}

// =============================================================================
// TEAM CARD
// =============================================================================

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.team,
    required this.onEdit,
    required this.onDelete,
  });

  final Team team;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.backgroundDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups, color: AppColors.primary),
            ),

            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    style: AppTextStyles.bodyRegular.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (team.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      team.description!,
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Member Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundDarker,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${team.memberCount} Mitglieder',
                    style: AppTextStyles.smallText,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Actions
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Bearbeiten',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error.withValues(alpha: 0.7),
              onPressed: onDelete,
              tooltip: 'Loeschen',
            ),
          ],
        ),
      ),
    );
  }
}
