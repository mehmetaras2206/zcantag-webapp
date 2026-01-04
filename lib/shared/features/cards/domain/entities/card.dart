// =============================================================================
// CARD.DART
// =============================================================================
// Domain Entity fuer eine Visitenkarte. Kopiert von mobilapp.
// =============================================================================

import 'package:equatable/equatable.dart';
import 'card_type.dart';
import 'social_links.dart';

/// Visitenkarten Domain Entity
class Card extends Equatable {
  const Card({
    required this.id,
    required this.ownerUserId,
    this.companyId,
    this.parentCardId,
    this.assignedEditorId,
    required this.cardType,
    this.subcardCategory,
    required this.name,
    this.title,
    this.companyName,
    this.email,
    this.phone,
    this.mobile,
    this.fax,
    this.website,
    this.address,
    this.street,
    this.city,
    this.postalCode,
    this.country,
    this.logoUrl,
    this.brandColorPrimary,
    this.brandColorSecondary,
    this.companyDescription,
    this.socialLinks = const SocialLinks([]),
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.galleryImages = const [],
    this.qrCodeData,
    this.slug,
    this.isActive = true,
    this.isPublic = true,
    this.inheritCorporateIdentity = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Identifikation
  final String id;
  final String ownerUserId;
  final String? companyId;
  final String? parentCardId;
  final String? assignedEditorId;

  // Typ
  final CardType cardType;
  final SubcardCategory? subcardCategory;

  // Basis-Informationen
  final String name;
  final String? title;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? mobile;
  final String? fax;
  final String? website;

  // Adresse
  final String? address;
  final String? street;
  final String? city;
  final String? postalCode;
  final String? country;

  // Corporate Identity
  final String? logoUrl;
  final String? brandColorPrimary;
  final String? brandColorSecondary;
  final String? companyDescription;

  // Social Media
  final SocialLinks socialLinks;

  // Medien
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final List<String> galleryImages;

  // Technisch
  final String? qrCodeData;
  final String? slug;
  final bool isActive;
  final bool isPublic;
  final bool inheritCorporateIdentity;

  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        ownerUserId,
        companyId,
        parentCardId,
        assignedEditorId,
        cardType,
        subcardCategory,
        name,
        title,
        companyName,
        email,
        phone,
        mobile,
        fax,
        website,
        address,
        street,
        city,
        postalCode,
        country,
        logoUrl,
        brandColorPrimary,
        brandColorSecondary,
        companyDescription,
        socialLinks,
        profileImageUrl,
        backgroundImageUrl,
        galleryImages,
        qrCodeData,
        slug,
        isActive,
        isPublic,
        inheritCorporateIdentity,
        createdAt,
        updatedAt,
      ];

  /// Erstellt eine Kopie mit geaenderten Werten
  Card copyWith({
    String? id,
    String? ownerUserId,
    String? companyId,
    String? parentCardId,
    String? assignedEditorId,
    CardType? cardType,
    SubcardCategory? subcardCategory,
    String? name,
    String? title,
    String? companyName,
    String? email,
    String? phone,
    String? mobile,
    String? fax,
    String? website,
    String? address,
    String? street,
    String? city,
    String? postalCode,
    String? country,
    String? logoUrl,
    String? brandColorPrimary,
    String? brandColorSecondary,
    String? companyDescription,
    SocialLinks? socialLinks,
    String? profileImageUrl,
    String? backgroundImageUrl,
    List<String>? galleryImages,
    String? qrCodeData,
    String? slug,
    bool? isActive,
    bool? isPublic,
    bool? inheritCorporateIdentity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Card(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      companyId: companyId ?? this.companyId,
      parentCardId: parentCardId ?? this.parentCardId,
      assignedEditorId: assignedEditorId ?? this.assignedEditorId,
      cardType: cardType ?? this.cardType,
      subcardCategory: subcardCategory ?? this.subcardCategory,
      name: name ?? this.name,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      fax: fax ?? this.fax,
      website: website ?? this.website,
      address: address ?? this.address,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      logoUrl: logoUrl ?? this.logoUrl,
      brandColorPrimary: brandColorPrimary ?? this.brandColorPrimary,
      brandColorSecondary: brandColorSecondary ?? this.brandColorSecondary,
      companyDescription: companyDescription ?? this.companyDescription,
      socialLinks: socialLinks ?? this.socialLinks,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
      inheritCorporateIdentity:
          inheritCorporateIdentity ?? this.inheritCorporateIdentity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isSubcard => cardType == CardType.subcard;
  bool get isCompanyProfile => cardType == CardType.companyProfile;
  bool get isPersonal => cardType == CardType.personal;

  String? get fullAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (postalCode != null && city != null) {
      parts.add('$postalCode $city');
    } else if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  String get displayName {
    if (name.isNotEmpty) return name;
    if (companyName != null && companyName!.isNotEmpty) return companyName!;
    return email ?? 'Unbenannte Karte';
  }
}
