// =============================================================================
// COMPANY_DTO.DART
// =============================================================================
// DTOs fuer Company API Operationen
// =============================================================================

import '../../domain/entities/company.dart';

/// Company DTO fuer API Response
class CompanyDto {
  const CompanyDto({
    required this.id,
    required this.name,
    this.displayName,
    this.logoUrl,
    this.websiteUrl,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.description,
    this.industry,
    this.planType,
    this.primaryColor,
    this.secondaryColor,
    this.createdAt,
    this.updatedAt,
    this.memberCount,
    this.cardCount,
  });

  final String id;
  final String name;
  final String? displayName;
  final String? logoUrl;
  final String? websiteUrl;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? description;
  final String? industry;
  final String? planType;
  final String? primaryColor;
  final String? secondaryColor;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? memberCount;
  final int? cardCount;

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    return CompanyDto(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String?,
      logoUrl: json['logo_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      description: json['description'] as String?,
      industry: json['industry'] as String?,
      planType: json['plan_type'] as String?,
      primaryColor: json['primary_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      memberCount: json['member_count'] as int?,
      cardCount: json['card_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'logo_url': logoUrl,
      'website_url': websiteUrl,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'description': description,
      'industry': industry,
      'plan_type': planType,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'member_count': memberCount,
      'card_count': cardCount,
    };
  }

  Company toDomain() {
    return Company(
      id: id,
      name: name,
      displayName: displayName ?? name,
      logoUrl: logoUrl,
      websiteUrl: websiteUrl,
      email: email,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
      country: country,
      description: description,
      industry: industry,
      planType: PlanType.fromString(planType ?? 'free'),
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      createdAt: createdAt,
      updatedAt: updatedAt,
      memberCount: memberCount ?? 0,
      cardCount: cardCount ?? 0,
    );
  }
}

/// Company Update DTO
class CompanyUpdateDto {
  const CompanyUpdateDto({
    this.name,
    this.displayName,
    this.logoUrl,
    this.websiteUrl,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.description,
    this.industry,
    this.primaryColor,
    this.secondaryColor,
  });

  final String? name;
  final String? displayName;
  final String? logoUrl;
  final String? websiteUrl;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? description;
  final String? industry;
  final String? primaryColor;
  final String? secondaryColor;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (displayName != null) map['display_name'] = displayName;
    if (logoUrl != null) map['logo_url'] = logoUrl;
    if (websiteUrl != null) map['website_url'] = websiteUrl;
    if (email != null) map['email'] = email;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (city != null) map['city'] = city;
    if (postalCode != null) map['postal_code'] = postalCode;
    if (country != null) map['country'] = country;
    if (description != null) map['description'] = description;
    if (industry != null) map['industry'] = industry;
    if (primaryColor != null) map['primary_color'] = primaryColor;
    if (secondaryColor != null) map['secondary_color'] = secondaryColor;
    return map;
  }
}
