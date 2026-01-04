// =============================================================================
// CARD_DTO.DART
// =============================================================================
// Data Transfer Objects fuer Card API-Kommunikation
// =============================================================================

import '../../domain/entities/card.dart';
import '../../domain/entities/card_type.dart';
import '../../domain/entities/social_links.dart';

/// DTO fuer Karten-API-Responses
class CardDto {
  CardDto({
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
    this.socialLinks,
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.galleryImages,
    this.qrCodeData,
    this.slug,
    this.isActive = true,
    this.isPublic = true,
    this.inheritCorporateIdentity = true,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerUserId;
  final String? companyId;
  final String? parentCardId;
  final String? assignedEditorId;
  final String cardType;
  final String? subcardCategory;
  final String name;
  final String? title;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? mobile;
  final String? fax;
  final String? website;
  final String? address;
  final String? street;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? logoUrl;
  final String? brandColorPrimary;
  final String? brandColorSecondary;
  final String? companyDescription;
  final Map<String, dynamic>? socialLinks;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final List<String>? galleryImages;
  final String? qrCodeData;
  final String? slug;
  final bool isActive;
  final bool isPublic;
  final bool inheritCorporateIdentity;
  final String createdAt;
  final String? updatedAt;

  /// Erstellt DTO aus JSON
  factory CardDto.fromJson(Map<String, dynamic> json) {
    return CardDto(
      id: json['id']?.toString() ?? '',
      ownerUserId: json['owner_user_id']?.toString() ?? '',
      companyId: json['company_id']?.toString(),
      parentCardId: json['parent_card_id']?.toString(),
      assignedEditorId: json['assigned_editor_id']?.toString(),
      cardType: json['card_type']?.toString() ?? 'personal',
      subcardCategory: json['subcard_category']?.toString(),
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString(),
      companyName: json['company_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      mobile: json['mobile']?.toString(),
      fax: json['fax']?.toString(),
      website: json['website']?.toString(),
      address: json['address']?.toString(),
      street: json['street']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postal_code']?.toString(),
      country: json['country']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      brandColorPrimary: json['brand_color_primary']?.toString(),
      brandColorSecondary: json['brand_color_secondary']?.toString(),
      companyDescription: json['company_description']?.toString(),
      socialLinks: json['social_links'] as Map<String, dynamic>?,
      profileImageUrl: json['profile_image_url']?.toString(),
      backgroundImageUrl: json['background_image_url']?.toString(),
      galleryImages: (json['gallery_images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      qrCodeData: json['qr_code_data']?.toString(),
      slug: json['slug']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      isPublic: json['is_public'] as bool? ?? true,
      inheritCorporateIdentity:
          json['inherit_corporate_identity'] as bool? ?? true,
      createdAt:
          json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Konvertiert zu Domain Entity
  Card toDomain() {
    return Card(
      id: id,
      ownerUserId: ownerUserId,
      companyId: companyId,
      parentCardId: parentCardId,
      assignedEditorId: assignedEditorId,
      cardType: CardType.fromString(cardType),
      subcardCategory: SubcardCategory.fromString(subcardCategory),
      name: name,
      title: title,
      companyName: companyName,
      email: email,
      phone: phone,
      mobile: mobile,
      fax: fax,
      website: website,
      address: address,
      street: street,
      city: city,
      postalCode: postalCode,
      country: country,
      logoUrl: logoUrl,
      brandColorPrimary: brandColorPrimary,
      brandColorSecondary: brandColorSecondary,
      companyDescription: companyDescription,
      socialLinks: SocialLinks.fromMap(socialLinks),
      profileImageUrl: profileImageUrl,
      backgroundImageUrl: backgroundImageUrl,
      galleryImages: galleryImages ?? [],
      qrCodeData: qrCodeData,
      slug: slug,
      isActive: isActive,
      isPublic: isPublic,
      inheritCorporateIdentity: inheritCorporateIdentity,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  /// Konvertiert zu JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_user_id': ownerUserId,
      if (companyId != null) 'company_id': companyId,
      if (parentCardId != null) 'parent_card_id': parentCardId,
      if (assignedEditorId != null) 'assigned_editor_id': assignedEditorId,
      'card_type': cardType,
      if (subcardCategory != null) 'subcard_category': subcardCategory,
      'name': name,
      if (title != null) 'title': title,
      if (companyName != null) 'company_name': companyName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (mobile != null) 'mobile': mobile,
      if (fax != null) 'fax': fax,
      if (website != null) 'website': website,
      if (address != null) 'address': address,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (brandColorPrimary != null) 'brand_color_primary': brandColorPrimary,
      if (brandColorSecondary != null)
        'brand_color_secondary': brandColorSecondary,
      if (companyDescription != null) 'company_description': companyDescription,
      if (socialLinks != null) 'social_links': socialLinks,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (backgroundImageUrl != null) 'background_image_url': backgroundImageUrl,
      if (galleryImages != null) 'gallery_images': galleryImages,
      if (qrCodeData != null) 'qr_code_data': qrCodeData,
      if (slug != null) 'slug': slug,
      'is_active': isActive,
      'is_public': isPublic,
      'inherit_corporate_identity': inheritCorporateIdentity,
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}

/// DTO fuer Card Create Request
class CardCreateDto {
  CardCreateDto({
    required this.name,
    this.cardType = 'personal',
    this.title,
    this.companyName,
    this.email,
    this.phone,
    this.mobile,
    this.website,
    this.street,
    this.city,
    this.postalCode,
    this.country,
    this.socialLinks,
    this.profileImageUrl,
    this.isPublic = true,
  });

  final String name;
  final String cardType;
  final String? title;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? mobile;
  final String? website;
  final String? street;
  final String? city;
  final String? postalCode;
  final String? country;
  final Map<String, String>? socialLinks;
  final String? profileImageUrl;
  final bool isPublic;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'card_type': cardType,
      if (title != null) 'title': title,
      if (companyName != null) 'company_name': companyName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (mobile != null) 'mobile': mobile,
      if (website != null) 'website': website,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (socialLinks != null) 'social_links': socialLinks,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      'is_public': isPublic,
    };
  }
}

/// DTO fuer Card Update Request
class CardUpdateDto {
  CardUpdateDto({
    this.name,
    this.title,
    this.companyName,
    this.email,
    this.phone,
    this.mobile,
    this.website,
    this.street,
    this.city,
    this.postalCode,
    this.country,
    this.socialLinks,
    this.profileImageUrl,
    this.isPublic,
    this.isActive,
  });

  final String? name;
  final String? title;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? mobile;
  final String? website;
  final String? street;
  final String? city;
  final String? postalCode;
  final String? country;
  final Map<String, String>? socialLinks;
  final String? profileImageUrl;
  final bool? isPublic;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (title != null) 'title': title,
      if (companyName != null) 'company_name': companyName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (mobile != null) 'mobile': mobile,
      if (website != null) 'website': website,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (socialLinks != null) 'social_links': socialLinks,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (isPublic != null) 'is_public': isPublic,
      if (isActive != null) 'is_active': isActive,
    };
  }
}

/// DTO fuer Card Share Response
class CardShareDto {
  CardShareDto({
    required this.cardId,
    required this.shareUrl,
    this.sharedWith,
    required this.sharedAt,
  });

  final String cardId;
  final String shareUrl;
  final String? sharedWith;
  final String sharedAt;

  factory CardShareDto.fromJson(Map<String, dynamic> json) {
    return CardShareDto(
      cardId: json['card_id']?.toString() ?? '',
      shareUrl: json['share_url']?.toString() ?? '',
      sharedWith: json['shared_with']?.toString(),
      sharedAt:
          json['shared_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
