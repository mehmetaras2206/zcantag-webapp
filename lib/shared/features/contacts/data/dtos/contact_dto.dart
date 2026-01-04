// =============================================================================
// CONTACT_DTO.DART
// =============================================================================
// DTOs fuer Contact API Kommunikation
// =============================================================================

import '../../domain/entities/contact.dart';

/// Contact DTO - API Response
class ContactDto {
  const ContactDto({
    required this.id,
    required this.userId,
    this.cardId,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.title,
    this.notes,
    this.tags,
    this.isFavorite,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String? cardId;
  final String name;
  final String? email;
  final String? phone;
  final String? company;
  final String? title;
  final String? notes;
  final List<String>? tags;
  final bool? isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory ContactDto.fromJson(Map<String, dynamic> json) {
    return ContactDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cardId: json['card_id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      isFavorite: json['is_favorite'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Contact toDomain() {
    return Contact(
      id: id,
      userId: userId,
      cardId: cardId,
      name: name,
      email: email,
      phone: phone,
      company: company,
      title: title,
      notes: notes,
      tags: tags ?? [],
      isFavorite: isFavorite ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Contact Create DTO - fuer POST /api/contacts
class ContactCreateDto {
  const ContactCreateDto({
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.title,
    this.notes,
    this.tags,
    this.cardId,
  });

  final String name;
  final String? email;
  final String? phone;
  final String? company;
  final String? title;
  final String? notes;
  final List<String>? tags;
  final String? cardId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (company != null) 'company': company,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
      if (cardId != null) 'card_id': cardId,
    };
  }
}

/// Contact Update DTO - fuer PUT /api/contacts/{id}
class ContactUpdateDto {
  const ContactUpdateDto({
    this.name,
    this.email,
    this.phone,
    this.company,
    this.title,
    this.notes,
    this.tags,
    this.isFavorite,
  });

  final String? name;
  final String? email;
  final String? phone;
  final String? company;
  final String? title;
  final String? notes;
  final List<String>? tags;
  final bool? isFavorite;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (company != null) 'company': company,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (isFavorite != null) 'is_favorite': isFavorite,
    };
  }
}

/// Contact Stats DTO - fuer GET /api/contacts/stats
class ContactStatsDto {
  const ContactStatsDto({
    required this.totalContacts,
    required this.favoriteContacts,
    required this.maxContacts,
    required this.limitReached,
    this.remaining,
    required this.planType,
  });

  final int totalContacts;
  final int favoriteContacts;
  final int maxContacts;
  final bool limitReached;
  final int? remaining;
  final String planType;

  factory ContactStatsDto.fromJson(Map<String, dynamic> json) {
    return ContactStatsDto(
      totalContacts: json['total_contacts'] as int? ?? 0,
      favoriteContacts: json['favorite_contacts'] as int? ?? 0,
      maxContacts: json['max_contacts'] as int? ?? 0,
      limitReached: json['limit_reached'] as bool? ?? false,
      remaining: json['remaining'] as int?,
      planType: json['plan_type'] as String? ?? 'free',
    );
  }

  ContactStats toDomain() {
    return ContactStats(
      totalContacts: totalContacts,
      favoriteContacts: favoriteContacts,
      maxContacts: maxContacts,
      limitReached: limitReached,
      remaining: remaining,
      planType: planType,
    );
  }
}
