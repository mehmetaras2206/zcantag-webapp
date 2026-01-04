// =============================================================================
// INVITE_MEMBER_SCREEN.DART
// =============================================================================
// Mitarbeiter einladen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/rbac/domain/entities/rbac.dart';
import '../../../presentation/layouts/admin_shell.dart';
import '../providers/rbac_provider.dart';

class InviteMemberScreen extends ConsumerStatefulWidget {
  const InviteMemberScreen({super.key});

  @override
  ConsumerState<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends ConsumerState<InviteMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  UserRole _selectedRole = UserRole.mitarbeiter;
  String? _selectedTeamId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Teams laden fuer Dropdown
    Future.microtask(() {
      ref.read(teamsProvider.notifier).loadTeams();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _inviteMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(membersProvider.notifier).inviteMember(
          'mock-company-id', // TODO: Aus Auth laden
          _emailController.text.trim(),
          _selectedRole,
          teamId: _selectedTeamId,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Einladung erfolgreich versendet'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/admin/team');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Versenden der Einladung'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamsState = ref.watch(teamsProvider);

    return AdminShell(
      currentRoute: '/admin/team',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/admin/team'),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mitarbeiter einladen', style: AppTextStyles.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Senden Sie eine Einladung per E-Mail',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Form
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    _buildSection(
                      title: 'E-Mail-Adresse',
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'mitarbeiter@firma.de',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: AppColors.backgroundDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.textWhite.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bitte E-Mail-Adresse eingeben';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Bitte gueltige E-Mail-Adresse eingeben';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Role Selection
                    _buildSection(
                      title: 'Rolle zuweisen',
                      child: Column(
                        children: UserRole.values.map((role) {
                          return _RoleOption(
                            role: role,
                            isSelected: _selectedRole == role,
                            onSelect: () => setState(() => _selectedRole = role),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Team Selection
                    _buildSection(
                      title: 'Team zuweisen (optional)',
                      child: _buildTeamDropdown(teamsState),
                    ),

                    const SizedBox(height: 32),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wie funktioniert die Einladung?',
                                  style: AppTextStyles.bodyRegular.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Der Mitarbeiter erhaelt eine E-Mail mit einem '
                                  'Einladungslink. Nach der Registrierung wird er '
                                  'automatisch Ihrem Team hinzugefuegt.',
                                  style: AppTextStyles.smallText.copyWith(
                                    color:
                                        AppColors.textWhite.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Actions
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go('/admin/team'),
                          child: const Text('Abbrechen'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _inviteMember,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.backgroundDarker,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(_isLoading
                                ? 'Wird gesendet...'
                                : 'Einladung senden'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTeamDropdown(TeamsState state) {
    final teams = state is TeamsLoaded ? state.teams : <Team>[];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textWhite.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButtonFormField<String?>(
        initialValue: _selectedTeamId,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.groups_outlined),
        ),
        hint: const Text('Kein Team'),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Kein Team'),
          ),
          ...teams.map((team) => DropdownMenuItem<String?>(
                value: team.id,
                child: Text(team.name),
              )),
        ],
        onChanged: (value) => setState(() => _selectedTeamId = value),
      ),
    );
  }
}

// =============================================================================
// ROLE OPTION WIDGET
// =============================================================================

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.role,
    required this.isSelected,
    required this.onSelect,
  });

  final UserRole role;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(role);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? roleColor.withValues(alpha: 0.1)
            : AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? roleColor
                    : AppColors.textWhite.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Radio
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? roleColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? roleColor
                          : AppColors.textWhite.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getRoleIcon(role),
                    color: roleColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.displayName,
                        style: AppTextStyles.bodyRegular.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? roleColor : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.description,
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
