// =============================================================================
// CARD_TYPE.DART
// =============================================================================
// Enum fuer die verschiedenen Kartentypen. Kopiert von mobilapp.
// =============================================================================

/// Typen von Visitenkarten
enum CardType {
  personal('personal'),
  companyProfile('company_profile'),
  subcard('subcard');

  const CardType(this.value);

  final String value;

  static CardType fromString(String value) {
    return CardType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CardType.personal,
    );
  }

  String get displayName {
    switch (this) {
      case CardType.personal:
        return 'Persoenlich';
      case CardType.companyProfile:
        return 'Unternehmensprofil';
      case CardType.subcard:
        return 'Subkarte';
    }
  }
}

/// Kategorien fuer Subkarten
enum SubcardCategory {
  employee('employee'),
  location('location'),
  department('department');

  const SubcardCategory(this.value);

  final String value;

  static SubcardCategory? fromString(String? value) {
    if (value == null) return null;
    return SubcardCategory.values.firstWhere(
      (cat) => cat.value == value,
      orElse: () => SubcardCategory.employee,
    );
  }

  String get displayName {
    switch (this) {
      case SubcardCategory.employee:
        return 'Mitarbeiter';
      case SubcardCategory.location:
        return 'Standort';
      case SubcardCategory.department:
        return 'Abteilung';
    }
  }
}
