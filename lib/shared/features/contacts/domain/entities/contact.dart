// =============================================================================
// CONTACT.DART
// =============================================================================
// Domain Entity fuer Kontakte. Kopiert von mobilapp.
// =============================================================================

import 'package:equatable/equatable.dart';

/// Contact Entity
class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.userId,
    this.cardId,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.title,
    this.notes,
    this.tags = const [],
    this.isFavorite = false,
    this.isFrozen = false,
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
  final List<String> tags;
  final bool isFavorite;
  final bool isFrozen; // Kontakt ueber Limit - ausgegraut
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get displayName => name.isNotEmpty ? name : (company ?? 'Unbekannt');

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get hasContactInfo => email != null || phone != null;
  bool get hasTags => tags.isNotEmpty;

  Contact copyWith({
    String? id,
    String? userId,
    String? cardId,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? title,
    String? notes,
    List<String>? tags,
    bool? isFavorite,
    bool? isFrozen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardId: cardId ?? this.cardId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isFrozen: isFrozen ?? this.isFrozen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        cardId,
        name,
        email,
        phone,
        company,
        title,
        notes,
        tags,
        isFavorite,
        isFrozen,
        createdAt,
        updatedAt,
      ];
}

/// Statistiken zu Kontakten
class ContactStats extends Equatable {
  const ContactStats({
    required this.totalContacts,
    required this.favoriteContacts,
    required this.maxContacts,
    required this.limitReached,
    this.remaining,
    required this.planType,
    this.frozenContacts = 0,
  });

  final int totalContacts;
  final int favoriteContacts;
  final int maxContacts;
  final bool limitReached;
  final int? remaining;
  final String planType;
  final int frozenContacts; // Anzahl eingefrorener Kontakte

  double get usagePercent =>
      maxContacts > 0 ? totalContacts / maxContacts : 0.0;

  /// Anzahl aktiver (nicht eingefrorener) Kontakte
  int get activeContacts => totalContacts - frozenContacts;

  ContactWarningLevel get warningLevel {
    if (limitReached) return ContactWarningLevel.critical;
    if (usagePercent >= 0.95) return ContactWarningLevel.critical;
    if (usagePercent >= 0.80) return ContactWarningLevel.warning;
    return ContactWarningLevel.normal;
  }

  @override
  List<Object?> get props => [
        totalContacts,
        favoriteContacts,
        maxContacts,
        limitReached,
        remaining,
        planType,
        frozenContacts,
      ];
}

/// Warnstufen fuer Kontakt-Limit
enum ContactWarningLevel {
  normal,
  warning,
  critical,
}
