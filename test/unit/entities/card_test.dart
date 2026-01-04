// =============================================================================
// CARD_TEST.DART - Unit Tests fuer Card Entity
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/shared/features/cards/domain/entities/card.dart';
import 'package:webapp/shared/features/cards/domain/entities/card_type.dart';
import 'package:webapp/shared/features/cards/domain/entities/social_links.dart';

void main() {
  group('Card Entity', () {
    late Card card;

    setUp(() {
      card = Card(
        id: 'card-123',
        ownerUserId: 'user-456',
        companyId: 'comp-789',
        cardType: CardType.personal,
        name: 'Max Mustermann',
        title: 'CEO',
        companyName: 'Test GmbH',
        email: 'max@test.com',
        phone: '+49 123 456789',
        mobile: '+49 171 9999999',
        website: 'https://example.com',
        street: 'Musterstrasse 1',
        city: 'Berlin',
        postalCode: '10115',
        country: 'Deutschland',
        profileImageUrl: 'https://example.com/image.jpg',
        socialLinks: SocialLinks([
          const SocialLink(
              platform: SocialPlatform.linkedin,
              url: 'https://linkedin.com/in/max'),
        ]),
        slug: 'max-mustermann',
        isActive: true,
        isPublic: true,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 6, 20),
      );
    });

    test('should create Card with all fields', () {
      expect(card.id, 'card-123');
      expect(card.ownerUserId, 'user-456');
      expect(card.companyId, 'comp-789');
      expect(card.cardType, CardType.personal);
      expect(card.name, 'Max Mustermann');
      expect(card.title, 'CEO');
      expect(card.companyName, 'Test GmbH');
      expect(card.email, 'max@test.com');
      expect(card.phone, '+49 123 456789');
      expect(card.website, 'https://example.com');
      expect(card.isActive, true);
      expect(card.isPublic, true);
    });

    test('displayName returns name when not empty', () {
      expect(card.displayName, 'Max Mustermann');
    });

    test('displayName returns companyName when name is empty', () {
      final noNameCard = card.copyWith(name: '');
      expect(noNameCard.displayName, 'Test GmbH');
    });

    test('displayName returns email when name and company are empty', () {
      final minimalCard = Card(
        id: 'id',
        ownerUserId: 'uid',
        cardType: CardType.personal,
        name: '',
        email: 'test@test.com',
        createdAt: DateTime.now(),
      );
      expect(minimalCard.displayName, 'test@test.com');
    });

    test('displayName returns fallback when all empty', () {
      final emptyCard = Card(
        id: 'id',
        ownerUserId: 'uid',
        cardType: CardType.personal,
        name: '',
        createdAt: DateTime.now(),
      );
      expect(emptyCard.displayName, 'Unbenannte Karte');
    });

    test('isSubcard returns true for subcard type', () {
      final subcard = card.copyWith(cardType: CardType.subcard);
      expect(subcard.isSubcard, true);
      expect(card.isSubcard, false);
    });

    test('isCompanyProfile returns true for companyProfile type', () {
      final companyCard = card.copyWith(cardType: CardType.companyProfile);
      expect(companyCard.isCompanyProfile, true);
      expect(card.isCompanyProfile, false);
    });

    test('isPersonal returns true for personal type', () {
      expect(card.isPersonal, true);

      final subcard = card.copyWith(cardType: CardType.subcard);
      expect(subcard.isPersonal, false);
    });

    test('fullAddress builds correct address string', () {
      expect(card.fullAddress, 'Musterstrasse 1, 10115 Berlin, Deutschland');
    });

    test('fullAddress handles partial address', () {
      final partialCard = Card(
        id: 'id',
        ownerUserId: 'uid',
        cardType: CardType.personal,
        name: 'Test',
        city: 'Hamburg',
        createdAt: DateTime.now(),
      );
      expect(partialCard.fullAddress, 'Hamburg');
    });

    test('fullAddress returns null when no address parts', () {
      final noAddressCard = Card(
        id: 'id',
        ownerUserId: 'uid',
        cardType: CardType.personal,
        name: 'Test',
        createdAt: DateTime.now(),
      );
      expect(noAddressCard.fullAddress, isNull);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = card.copyWith(
        name: 'Hans Mueller',
        title: 'CTO',
      );

      expect(updated.name, 'Hans Mueller');
      expect(updated.title, 'CTO');
      expect(updated.id, 'card-123');
      expect(updated.ownerUserId, 'user-456');
    });

    test('equality check works correctly', () {
      final card1 = Card(
        id: 'same-id',
        ownerUserId: 'user',
        cardType: CardType.personal,
        name: 'Test',
        createdAt: DateTime(2024, 1, 1),
      );
      final card2 = Card(
        id: 'same-id',
        ownerUserId: 'user',
        cardType: CardType.personal,
        name: 'Test',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(card1, equals(card2));
    });
  });

  group('CardType Enum', () {
    test('has correct values', () {
      expect(CardType.values.length, 3);
      expect(CardType.values, contains(CardType.personal));
      expect(CardType.values, contains(CardType.companyProfile));
      expect(CardType.values, contains(CardType.subcard));
    });

    test('fromString converts string to CardType correctly', () {
      expect(CardType.fromString('personal'), CardType.personal);
      expect(CardType.fromString('company_profile'), CardType.companyProfile);
      expect(CardType.fromString('subcard'), CardType.subcard);
    });

    test('fromString returns personal for unknown string', () {
      expect(CardType.fromString('unknown'), CardType.personal);
    });

    test('displayName returns human-readable names', () {
      expect(CardType.personal.displayName, 'Persoenlich');
      expect(CardType.companyProfile.displayName, 'Unternehmensprofil');
      expect(CardType.subcard.displayName, 'Subkarte');
    });

    test('value returns API string', () {
      expect(CardType.personal.value, 'personal');
      expect(CardType.companyProfile.value, 'company_profile');
      expect(CardType.subcard.value, 'subcard');
    });
  });

  group('SubcardCategory Enum', () {
    test('has correct values', () {
      expect(SubcardCategory.values.length, 3);
      expect(SubcardCategory.values, contains(SubcardCategory.employee));
      expect(SubcardCategory.values, contains(SubcardCategory.location));
      expect(SubcardCategory.values, contains(SubcardCategory.department));
    });

    test('fromString converts string to SubcardCategory', () {
      expect(SubcardCategory.fromString('employee'), SubcardCategory.employee);
      expect(SubcardCategory.fromString('location'), SubcardCategory.location);
      expect(
          SubcardCategory.fromString('department'), SubcardCategory.department);
    });

    test('fromString returns null for null input', () {
      expect(SubcardCategory.fromString(null), isNull);
    });

    test('displayName returns human-readable names', () {
      expect(SubcardCategory.employee.displayName, 'Mitarbeiter');
      expect(SubcardCategory.location.displayName, 'Standort');
      expect(SubcardCategory.department.displayName, 'Abteilung');
    });
  });

  group('SocialLinks', () {
    test('should create empty SocialLinks', () {
      const links = SocialLinks([]);
      expect(links.isEmpty, true);
      expect(links.count, 0);
    });

    test('should create SocialLinks with entries', () {
      final links = SocialLinks([
        const SocialLink(
            platform: SocialPlatform.linkedin,
            url: 'https://linkedin.com/in/test'),
        const SocialLink(
            platform: SocialPlatform.twitter,
            url: 'https://twitter.com/test'),
      ]);

      expect(links.isEmpty, false);
      expect(links.isNotEmpty, true);
      expect(links.count, 2);
    });

    test('getLink returns correct link for platform', () {
      final links = SocialLinks([
        const SocialLink(
            platform: SocialPlatform.linkedin,
            url: 'https://linkedin.com/in/test'),
      ]);

      final linkedIn = links.getLink(SocialPlatform.linkedin);
      expect(linkedIn, isNotNull);
      expect(linkedIn!.url, 'https://linkedin.com/in/test');
    });

    test('getLink returns null for missing platform', () {
      final links = SocialLinks([
        const SocialLink(
            platform: SocialPlatform.linkedin,
            url: 'https://linkedin.com/in/test'),
      ]);

      final twitter = links.getLink(SocialPlatform.twitter);
      expect(twitter, isNull);
    });

    test('fromMap creates SocialLinks from map', () {
      final map = {
        'linkedin': 'https://linkedin.com/in/test',
        'twitter': 'https://twitter.com/test',
      };

      final links = SocialLinks.fromMap(map);
      expect(links.count, 2);
    });

    test('fromMap returns empty for null map', () {
      final links = SocialLinks.fromMap(null);
      expect(links.isEmpty, true);
    });

    test('toMap converts links to map', () {
      final links = SocialLinks([
        const SocialLink(
            platform: SocialPlatform.linkedin,
            url: 'https://linkedin.com/test'),
      ]);

      final map = links.toMap();
      expect(map['linkedin'], 'https://linkedin.com/test');
    });
  });

  group('SocialPlatform Enum', () {
    test('has all expected platforms', () {
      expect(SocialPlatform.values.length, 12);
      expect(SocialPlatform.values, contains(SocialPlatform.linkedin));
      expect(SocialPlatform.values, contains(SocialPlatform.instagram));
      expect(SocialPlatform.values, contains(SocialPlatform.facebook));
      expect(SocialPlatform.values, contains(SocialPlatform.twitter));
      expect(SocialPlatform.values, contains(SocialPlatform.xing));
      expect(SocialPlatform.values, contains(SocialPlatform.youtube));
      expect(SocialPlatform.values, contains(SocialPlatform.tiktok));
      expect(SocialPlatform.values, contains(SocialPlatform.website));
      expect(SocialPlatform.values, contains(SocialPlatform.github));
      expect(SocialPlatform.values, contains(SocialPlatform.whatsapp));
      expect(SocialPlatform.values, contains(SocialPlatform.telegram));
      expect(SocialPlatform.values, contains(SocialPlatform.other));
    });

    test('fromString converts string to platform', () {
      expect(SocialPlatform.fromString('linkedin'), SocialPlatform.linkedin);
      expect(SocialPlatform.fromString('LINKEDIN'), SocialPlatform.linkedin);
      expect(SocialPlatform.fromString('unknown'), SocialPlatform.other);
    });

    test('displayName returns human-readable names', () {
      expect(SocialPlatform.linkedin.displayName, 'LinkedIn');
      expect(SocialPlatform.twitter.displayName, 'X (Twitter)');
      expect(SocialPlatform.xing.displayName, 'XING');
    });
  });

  group('SocialLink', () {
    test('should create SocialLink', () {
      const link = SocialLink(
        platform: SocialPlatform.linkedin,
        url: 'https://linkedin.com/in/test',
      );

      expect(link.platform, SocialPlatform.linkedin);
      expect(link.url, 'https://linkedin.com/in/test');
    });

    test('fromMapEntry creates link from entry', () {
      final link = SocialLink.fromMapEntry('twitter', 'https://twitter.com/t');
      expect(link.platform, SocialPlatform.twitter);
      expect(link.url, 'https://twitter.com/t');
    });

    test('toMapEntry converts to entry', () {
      const link = SocialLink(
        platform: SocialPlatform.github,
        url: 'https://github.com/test',
      );

      final entry = link.toMapEntry();
      expect(entry.key, 'github');
      expect(entry.value, 'https://github.com/test');
    });

    test('equality check works', () {
      const link1 = SocialLink(
        platform: SocialPlatform.linkedin,
        url: 'https://linkedin.com',
      );
      const link2 = SocialLink(
        platform: SocialPlatform.linkedin,
        url: 'https://linkedin.com',
      );
      expect(link1, equals(link2));
    });
  });
}
