// =============================================================================
// CONTACT_TEST.DART - Unit Tests fuer Contact Entity
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/shared/features/contacts/domain/entities/contact.dart';

void main() {
  group('Contact Entity', () {
    late Contact contact;

    setUp(() {
      contact = Contact(
        id: 'test-id-123',
        userId: 'user-456',
        cardId: 'card-789',
        name: 'Max Mustermann',
        email: 'max@example.com',
        phone: '+49 123 456789',
        company: 'Test GmbH',
        title: 'CEO',
        notes: 'Test notes',
        tags: const ['vip', 'kunde'],
        isFavorite: true,
        isFrozen: false,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 6, 20),
      );
    });

    test('should create Contact with all fields', () {
      expect(contact.id, 'test-id-123');
      expect(contact.userId, 'user-456');
      expect(contact.cardId, 'card-789');
      expect(contact.name, 'Max Mustermann');
      expect(contact.email, 'max@example.com');
      expect(contact.phone, '+49 123 456789');
      expect(contact.company, 'Test GmbH');
      expect(contact.title, 'CEO');
      expect(contact.notes, 'Test notes');
      expect(contact.tags, ['vip', 'kunde']);
      expect(contact.isFavorite, true);
      expect(contact.isFrozen, false);
    });

    test('displayName returns name when name is not empty', () {
      expect(contact.displayName, 'Max Mustermann');
    });

    test('displayName returns company when name is empty', () {
      final contactWithoutName = contact.copyWith(name: '');
      expect(contactWithoutName.displayName, 'Test GmbH');
    });

    test('displayName returns Unbekannt when name and company are empty', () {
      final unknownContact = Contact(
        id: 'id',
        userId: 'uid',
        name: '',
        createdAt: DateTime.now(),
      );
      expect(unknownContact.displayName, 'Unbekannt');
    });

    test('initials returns correct initials for full name', () {
      expect(contact.initials, 'MM');
    });

    test('initials returns first letter for single name', () {
      final singleNameContact = contact.copyWith(name: 'Max');
      expect(singleNameContact.initials, 'M');
    });

    test('initials returns ? for empty name', () {
      final noNameContact = Contact(
        id: 'id',
        userId: 'uid',
        name: '',
        createdAt: DateTime.now(),
      );
      expect(noNameContact.initials, '?');
    });

    test('hasContactInfo returns true when email exists', () {
      final contactWithEmail = Contact(
        id: 'id',
        userId: 'uid',
        name: 'Test',
        email: 'test@test.com',
        createdAt: DateTime.now(),
      );
      expect(contactWithEmail.hasContactInfo, true);
    });

    test('hasContactInfo returns true when phone exists', () {
      final contactWithPhone = Contact(
        id: 'id',
        userId: 'uid',
        name: 'Test',
        phone: '+49 123',
        createdAt: DateTime.now(),
      );
      expect(contactWithPhone.hasContactInfo, true);
    });

    test('hasContactInfo returns false when no email or phone', () {
      final minimalContact = Contact(
        id: 'id',
        userId: 'uid',
        name: 'Test',
        createdAt: DateTime.now(),
      );
      expect(minimalContact.hasContactInfo, false);
    });

    test('hasTags returns true when tags exist', () {
      expect(contact.hasTags, true);
    });

    test('hasTags returns false when tags are empty', () {
      final noTagsContact = contact.copyWith(tags: []);
      expect(noTagsContact.hasTags, false);
    });

    test('copyWith creates a new instance with updated fields', () {
      final updated = contact.copyWith(
        name: 'Neue Name',
        isFavorite: false,
      );

      expect(updated.name, 'Neue Name');
      expect(updated.isFavorite, false);
      // Original values should be preserved
      expect(updated.email, 'max@example.com');
      expect(updated.id, 'test-id-123');
    });

    test('equality check works correctly', () {
      final contact1 = Contact(
        id: 'same-id',
        userId: 'user',
        name: 'Test',
        createdAt: DateTime(2024, 1, 1),
      );
      final contact2 = Contact(
        id: 'same-id',
        userId: 'user',
        name: 'Test',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(contact1, equals(contact2));
    });

    test('frozen contact should have isFrozen set to true', () {
      final frozenContact = contact.copyWith(isFrozen: true);
      expect(frozenContact.isFrozen, true);
    });
  });

  group('ContactStats Entity', () {
    late ContactStats stats;

    setUp(() {
      stats = const ContactStats(
        totalContacts: 450,
        favoriteContacts: 25,
        maxContacts: 500,
        limitReached: false,
        remaining: 50,
        planType: 'free',
        frozenContacts: 0,
      );
    });

    test('should create ContactStats with all fields', () {
      expect(stats.totalContacts, 450);
      expect(stats.favoriteContacts, 25);
      expect(stats.maxContacts, 500);
      expect(stats.limitReached, false);
      expect(stats.remaining, 50);
      expect(stats.planType, 'free');
      expect(stats.frozenContacts, 0);
    });

    test('usagePercent calculates correctly', () {
      expect(stats.usagePercent, 0.9);
    });

    test('usagePercent returns 0 when maxContacts is 0', () {
      const zeroMaxStats = ContactStats(
        totalContacts: 10,
        favoriteContacts: 0,
        maxContacts: 0,
        limitReached: false,
        planType: 'free',
      );
      expect(zeroMaxStats.usagePercent, 0.0);
    });

    test('activeContacts calculated correctly', () {
      const statsWithFrozen = ContactStats(
        totalContacts: 100,
        favoriteContacts: 10,
        maxContacts: 80,
        limitReached: true,
        planType: 'free',
        frozenContacts: 20,
      );
      expect(statsWithFrozen.activeContacts, 80);
    });

    test('warningLevel returns normal when usage below 80%', () {
      const normalStats = ContactStats(
        totalContacts: 300,
        favoriteContacts: 10,
        maxContacts: 500,
        limitReached: false,
        planType: 'free',
      );
      expect(normalStats.warningLevel, ContactWarningLevel.normal);
    });

    test('warningLevel returns warning when usage at 80-95%', () {
      const warningStats = ContactStats(
        totalContacts: 425,
        favoriteContacts: 10,
        maxContacts: 500,
        limitReached: false,
        planType: 'free',
      );
      expect(warningStats.warningLevel, ContactWarningLevel.warning);
    });

    test('warningLevel returns critical when usage above 95%', () {
      const criticalStats = ContactStats(
        totalContacts: 490,
        favoriteContacts: 10,
        maxContacts: 500,
        limitReached: false,
        planType: 'free',
      );
      expect(criticalStats.warningLevel, ContactWarningLevel.critical);
    });

    test('warningLevel returns critical when limitReached', () {
      const limitStats = ContactStats(
        totalContacts: 500,
        favoriteContacts: 10,
        maxContacts: 500,
        limitReached: true,
        planType: 'free',
      );
      expect(limitStats.warningLevel, ContactWarningLevel.critical);
    });
  });

  group('ContactWarningLevel Enum', () {
    test('has correct values', () {
      expect(ContactWarningLevel.values.length, 3);
      expect(ContactWarningLevel.values, contains(ContactWarningLevel.normal));
      expect(ContactWarningLevel.values, contains(ContactWarningLevel.warning));
      expect(
          ContactWarningLevel.values, contains(ContactWarningLevel.critical));
    });
  });
}
