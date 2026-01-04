// =============================================================================
// CARD_EDITOR_SCREEN.DART
// =============================================================================
// Editor zum Erstellen und Bearbeiten von Visitenkarten
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../../../../shared/features/cards/domain/entities/card.dart' as domain;
import '../../../../shared/features/cards/domain/entities/social_links.dart';
import '../../../../shared/features/cards/data/dtos/card_dto.dart';
import '../providers/cards_provider.dart';

class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({
    super.key,
    this.cardId,
  });

  final String? cardId;

  bool get isEditing => cardId != null;

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _websiteController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Social Media Links
  final _linkedinController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _xingController = TextEditingController();

  bool _isPublic = true;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  domain.Card? _existingCard;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingCard();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _websiteController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _xingController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingCard() async {
    setState(() => _isLoading = true);

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.getCard(widget.cardId!);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        _existingCard = result.data;
        _populateForm(_existingCard!);
      } else {
        setState(() => _errorMessage = result.error);
      }
      setState(() => _isLoading = false);
    }
  }

  void _populateForm(domain.Card card) {
    _nameController.text = card.name;
    _titleController.text = card.title ?? '';
    _companyController.text = card.companyName ?? '';
    _emailController.text = card.email ?? '';
    _phoneController.text = card.phone ?? '';
    _mobileController.text = card.mobile ?? '';
    _websiteController.text = card.website ?? '';
    _streetController.text = card.street ?? '';
    _cityController.text = card.city ?? '';
    _postalCodeController.text = card.postalCode ?? '';
    _countryController.text = card.country ?? '';
    _isPublic = card.isPublic;

    // Social Links
    final linkedin = card.socialLinks.getLink(SocialPlatform.linkedin);
    if (linkedin != null) _linkedinController.text = linkedin.url;

    final instagram = card.socialLinks.getLink(SocialPlatform.instagram);
    if (instagram != null) _instagramController.text = instagram.url;

    final facebook = card.socialLinks.getLink(SocialPlatform.facebook);
    if (facebook != null) _facebookController.text = facebook.url;

    final xing = card.socialLinks.getLink(SocialPlatform.xing);
    if (xing != null) _xingController.text = xing.url;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final socialLinks = <String, String>{};
      if (_linkedinController.text.isNotEmpty) {
        socialLinks['linkedin'] = _linkedinController.text.trim();
      }
      if (_instagramController.text.isNotEmpty) {
        socialLinks['instagram'] = _instagramController.text.trim();
      }
      if (_facebookController.text.isNotEmpty) {
        socialLinks['facebook'] = _facebookController.text.trim();
      }
      if (_xingController.text.isNotEmpty) {
        socialLinks['xing'] = _xingController.text.trim();
      }

      bool success;

      if (widget.isEditing) {
        success = await ref.read(cardsProvider.notifier).updateCard(
              widget.cardId!,
              CardUpdateDto(
                name: _nameController.text.trim(),
                title: _titleController.text.trim().isEmpty
                    ? null
                    : _titleController.text.trim(),
                companyName: _companyController.text.trim().isEmpty
                    ? null
                    : _companyController.text.trim(),
                email: _emailController.text.trim().isEmpty
                    ? null
                    : _emailController.text.trim(),
                phone: _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
                mobile: _mobileController.text.trim().isEmpty
                    ? null
                    : _mobileController.text.trim(),
                website: _websiteController.text.trim().isEmpty
                    ? null
                    : _websiteController.text.trim(),
                street: _streetController.text.trim().isEmpty
                    ? null
                    : _streetController.text.trim(),
                city: _cityController.text.trim().isEmpty
                    ? null
                    : _cityController.text.trim(),
                postalCode: _postalCodeController.text.trim().isEmpty
                    ? null
                    : _postalCodeController.text.trim(),
                country: _countryController.text.trim().isEmpty
                    ? null
                    : _countryController.text.trim(),
                socialLinks: socialLinks.isEmpty ? null : socialLinks,
                isPublic: _isPublic,
              ),
            );
      } else {
        success = await ref.read(cardsProvider.notifier).createCard(
              CardCreateDto(
                name: _nameController.text.trim(),
                title: _titleController.text.trim().isEmpty
                    ? null
                    : _titleController.text.trim(),
                companyName: _companyController.text.trim().isEmpty
                    ? null
                    : _companyController.text.trim(),
                email: _emailController.text.trim().isEmpty
                    ? null
                    : _emailController.text.trim(),
                phone: _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
                mobile: _mobileController.text.trim().isEmpty
                    ? null
                    : _mobileController.text.trim(),
                website: _websiteController.text.trim().isEmpty
                    ? null
                    : _websiteController.text.trim(),
                street: _streetController.text.trim().isEmpty
                    ? null
                    : _streetController.text.trim(),
                city: _cityController.text.trim().isEmpty
                    ? null
                    : _cityController.text.trim(),
                postalCode: _postalCodeController.text.trim().isEmpty
                    ? null
                    : _postalCodeController.text.trim(),
                country: _countryController.text.trim().isEmpty
                    ? null
                    : _countryController.text.trim(),
                socialLinks: socialLinks.isEmpty ? null : socialLinks,
                isPublic: _isPublic,
              ),
            );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing
                  ? 'Karte aktualisiert'
                  : 'Karte erstellt'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/cards');
        } else {
          setState(() => _errorMessage = 'Fehler beim Speichern');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    if (!widget.isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Karte loeschen?'),
        content: const Text(
          'Diese Aktion kann nicht rueckgaengig gemacht werden.',
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

    if (confirmed == true) {
      setState(() => _isSaving = true);

      final success =
          await ref.read(cardsProvider.notifier).deleteCard(widget.cardId!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Karte geloescht'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/cards');
        } else {
          setState(() {
            _errorMessage = 'Fehler beim Loeschen';
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Karte bearbeiten' : 'Neue Karte'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/cards'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Karte bearbeiten' : 'Neue Karte'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/cards'),
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isSaving ? null : _handleDelete,
              color: AppColors.error,
              tooltip: 'Loeschen',
            ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Speichern'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_errorMessage!)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Basic Info Section
                _buildSectionHeader('Allgemeine Informationen'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Name *',
                  icon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte Namen eingeben';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _titleController,
                  label: 'Titel / Position',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _companyController,
                  label: 'Unternehmen',
                  icon: Icons.business_outlined,
                ),

                const SizedBox(height: 32),

                // Contact Info Section
                _buildSectionHeader('Kontaktdaten'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'E-Mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _phoneController,
                        label: 'Telefon',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _mobileController,
                        label: 'Mobil',
                        icon: Icons.smartphone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _websiteController,
                  label: 'Website',
                  icon: Icons.language_outlined,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 32),

                // Address Section
                _buildSectionHeader('Adresse'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _streetController,
                  label: 'Strasse',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'PLZ',
                        icon: Icons.pin_drop_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'Stadt',
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _countryController,
                  label: 'Land',
                  icon: Icons.flag_outlined,
                ),

                const SizedBox(height: 32),

                // Social Media Section
                _buildSectionHeader('Social Media'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _linkedinController,
                  label: 'LinkedIn URL',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _instagramController,
                  label: 'Instagram URL',
                  icon: Icons.camera_alt_outlined,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _facebookController,
                        label: 'Facebook URL',
                        icon: Icons.facebook_outlined,
                        keyboardType: TextInputType.url,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _xingController,
                        label: 'XING URL',
                        icon: Icons.work_outline,
                        keyboardType: TextInputType.url,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Settings Section
                _buildSectionHeader('Einstellungen'),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Oeffentlich sichtbar'),
                  subtitle: Text(
                    'Karte kann ueber Link geteilt werden',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.7),
                    ),
                  ),
                  value: _isPublic,
                  onChanged: (value) => setState(() => _isPublic = value),
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.textWhite.withValues(alpha: 0.5);
                  }),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary.withValues(alpha: 0.5);
                    }
                    return AppColors.backgroundDarker;
                  }),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
