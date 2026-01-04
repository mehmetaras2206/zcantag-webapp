// =============================================================================
// COMPANY_PROFILE_SCREEN.DART
// =============================================================================
// Unternehmensprofil bearbeiten
// =============================================================================

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/company/domain/entities/company.dart';
import '../../../../../shared/features/company/data/dtos/company_dto.dart';
import '../../../presentation/layouts/admin_shell.dart';
import '../providers/company_provider.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _industryController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // TODO: Company ID aus Auth laden
    Future.microtask(() {
      // Mock Company ID - in Production aus Auth State holen
      ref.read(companyProvider.notifier).loadCompany('mock-company-id');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _descriptionController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  void _populateForm(Company company) {
    _nameController.text = company.name;
    _displayNameController.text = company.displayName;
    _emailController.text = company.email ?? '';
    _phoneController.text = company.phone ?? '';
    _websiteController.text = company.websiteUrl ?? '';
    _addressController.text = company.address ?? '';
    _cityController.text = company.city ?? '';
    _postalCodeController.text = company.postalCode ?? '';
    _countryController.text = company.country ?? '';
    _descriptionController.text = company.description ?? '';
    _industryController.text = company.industry ?? '';
  }

  bool _isUploadingLogo = false;

  Future<void> _handleLogoUpload() async {
    final companyState = ref.read(companyProvider);
    if (companyState is! CompanyLoaded) return;

    // Create file input
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files.first;
      final reader = html.FileReader();

      setState(() => _isUploadingLogo = true);

      reader.onLoadEnd.listen((event) async {
        try {
          final result = reader.result;
          if (result is Uint8List) {
            final success = await ref
                .read(companyProvider.notifier)
                .uploadLogo(companyState.company.id, result.toList(), file.name);

            if (mounted) {
              setState(() => _isUploadingLogo = false);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logo erfolgreich hochgeladen'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fehler beim Hochladen des Logos'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isUploadingLogo = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fehler: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      });

      reader.readAsArrayBuffer(file);
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final companyState = ref.read(companyProvider);
    if (companyState is! CompanyLoaded) return;

    final updateData = CompanyUpdateDto(
      name: _nameController.text,
      displayName: _displayNameController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      websiteUrl:
          _websiteController.text.isEmpty ? null : _websiteController.text,
      address:
          _addressController.text.isEmpty ? null : _addressController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      postalCode:
          _postalCodeController.text.isEmpty ? null : _postalCodeController.text,
      country:
          _countryController.text.isEmpty ? null : _countryController.text,
      description:
          _descriptionController.text.isEmpty ? null : _descriptionController.text,
      industry:
          _industryController.text.isEmpty ? null : _industryController.text,
    );

    final success = await ref
        .read(companyProvider.notifier)
        .updateCompany(companyState.company.id, updateData);

    if (mounted) {
      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil erfolgreich aktualisiert'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Speichern'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyState = ref.watch(companyProvider);

    // Populate form wenn Daten geladen
    if (companyState is CompanyLoaded && !_isEditing) {
      _populateForm(companyState.company);
    }

    return AdminShell(
      currentRoute: '/admin/company',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unternehmensprofil', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Verwalten Sie die Unternehmensdaten',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                if (companyState is CompanyLoaded)
                  _isEditing
                      ? Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() => _isEditing = false);
                                _populateForm(companyState.company);
                              },
                              child: const Text('Abbrechen'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _saveChanges,
                              icon: const Icon(Icons.save),
                              label: const Text('Speichern'),
                            ),
                          ],
                        )
                      : ElevatedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit),
                          label: const Text('Bearbeiten'),
                        ),
              ],
            ),

            const SizedBox(height: 32),

            // Content
            _buildContent(companyState),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CompanyState state) {
    return switch (state) {
      CompanyInitial() => const Center(child: CircularProgressIndicator()),
      CompanyLoading() => const Center(child: CircularProgressIndicator()),
      CompanyError(:final message) => _buildError(message),
      CompanyLoaded(:final company) => _buildForm(company),
      CompanyUpdating(:final company) => _buildForm(company, isUpdating: true),
    };
  }

  Widget _buildError(String message) {
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
              ref
                  .read(companyProvider.notifier)
                  .loadCompany('mock-company-id');
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Company company, {bool isUpdating = false}) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Plan Badge
          _buildPlanBadge(company),

          const SizedBox(height: 24),

          // Logo Section
          _buildLogoSection(company),

          const SizedBox(height: 32),

          // Form Sections
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBasicInfoSection()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildContactSection()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildContactSection(),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          _buildAddressSection(),

          const SizedBox(height: 24),

          _buildDescriptionSection(),

          if (isUpdating) ...[
            const SizedBox(height: 24),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanBadge(Company company) {
    final planColor = switch (company.planType) {
      PlanType.free => Colors.grey,
      PlanType.basic => Colors.blue,
      PlanType.premium => Colors.purple,
      PlanType.enterprise => Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: planColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: planColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, color: planColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aktueller Plan',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
              Text(
                company.planType.displayName,
                style: AppTextStyles.heading3.copyWith(color: planColor),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundDarker,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.people, size: 16, color: planColor),
                const SizedBox(width: 6),
                Text(
                  '${company.memberCount} Mitglieder',
                  style: AppTextStyles.smallText,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundDarker,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card, size: 16, color: planColor),
                const SizedBox(width: 6),
                Text(
                  '${company.cardCount} Karten',
                  style: AppTextStyles.smallText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(Company company) {
    return _buildSection(
      title: 'Logo',
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.backgroundDarker,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.textWhite.withValues(alpha: 0.1),
              ),
            ),
            child: company.hasLogo
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      company.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.business,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.business,
                    size: 48,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(width: 24),
          if (_isEditing)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploadingLogo ? null : _handleLogoUpload,
                  icon: _isUploadingLogo
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.backgroundDarker,
                          ),
                        )
                      : const Icon(Icons.upload),
                  label: Text(_isUploadingLogo ? 'Wird hochgeladen...' : 'Logo hochladen'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Empfohlen: 512x512px, PNG oder JPG',
                  style: AppTextStyles.smallText.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.5),
                  ),
                ),
              ],
            )
          else
            Text(
              company.hasLogo ? 'Logo vorhanden' : 'Kein Logo hochgeladen',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basis-Informationen',
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Firmenname',
            validator: (v) => v?.isEmpty ?? true ? 'Pflichtfeld' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _displayNameController,
            label: 'Anzeigename',
            hint: 'Wird auf Visitenkarten angezeigt',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _industryController,
            label: 'Branche',
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: 'Kontaktdaten',
      child: Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'E-Mail',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Telefon',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _websiteController,
            label: 'Website',
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return _buildSection(
      title: 'Adresse',
      child: Column(
        children: [
          _buildTextField(
            controller: _addressController,
            label: 'Strasse & Hausnummer',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'PLZ',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _cityController,
                  label: 'Stadt',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _countryController,
            label: 'Land',
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return _buildSection(
      title: 'Beschreibung',
      child: _buildTextField(
        controller: _descriptionController,
        label: 'Ueber das Unternehmen',
        maxLines: 4,
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: _isEditing
            ? AppColors.backgroundDarker
            : AppColors.backgroundDark.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textWhite.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textWhite.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textWhite.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }
}
