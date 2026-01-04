// =============================================================================
// USER_TEST.DART - Unit Tests fuer User Entity
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/shared/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    late User user;

    setUp(() {
      user = User(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.superAdmin,
        companyId: 'company-456',
        isActive: true,
        emailVerified: true,
        createdAt: DateTime(2024, 1, 15),
      );
    });

    test('should create User with all fields', () {
      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, UserRole.superAdmin);
      expect(user.companyId, 'company-456');
      expect(user.isActive, true);
      expect(user.emailVerified, true);
      expect(user.createdAt, DateTime(2024, 1, 15));
    });

    test('hasCompany returns true when companyId exists', () {
      expect(user.hasCompany, true);
    });

    test('hasCompany returns false when companyId is null', () {
      final noCompanyUser = User(
        id: 'id',
        email: 'test@test.com',
        role: UserRole.individual,
        isActive: true,
        emailVerified: false,
        createdAt: DateTime.now(),
      );
      expect(noCompanyUser.hasCompany, false);
    });

    test('isAdmin returns true for admin role', () {
      final adminUser = user.copyWith(role: UserRole.admin);
      expect(adminUser.isAdmin, true);
    });

    test('isAdmin returns true for superAdmin role', () {
      expect(user.isAdmin, true);
    });

    test('isAdmin returns false for non-admin roles', () {
      final editorUser = user.copyWith(role: UserRole.editor);
      expect(editorUser.isAdmin, false);
    });

    test('isSuperAdmin returns true only for superAdmin role', () {
      expect(user.isSuperAdmin, true);

      final adminUser = user.copyWith(role: UserRole.admin);
      expect(adminUser.isSuperAdmin, false);
    });

    test('canEdit returns true for editor and above', () {
      final editorUser = user.copyWith(role: UserRole.editor);
      expect(editorUser.canEdit, true);

      final adminUser = user.copyWith(role: UserRole.admin);
      expect(adminUser.canEdit, true);

      expect(user.canEdit, true); // superAdmin
    });

    test('canEdit returns false for viewer and individual', () {
      final viewerUser = user.copyWith(role: UserRole.viewer);
      expect(viewerUser.canEdit, false);

      final individualUser = user.copyWith(role: UserRole.individual);
      expect(individualUser.canEdit, false);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = user.copyWith(
        name: 'New Name',
        role: UserRole.editor,
      );

      expect(updated.name, 'New Name');
      expect(updated.role, UserRole.editor);
      expect(updated.id, 'user-123');
      expect(updated.email, 'test@example.com');
    });

    test('equality check works correctly', () {
      final user1 = User(
        id: 'same-id',
        email: 'test@test.com',
        role: UserRole.individual,
        isActive: true,
        emailVerified: false,
        createdAt: DateTime(2024, 1, 1),
      );
      final user2 = User(
        id: 'same-id',
        email: 'different@test.com', // Email differs but ID same
        role: UserRole.admin,
        isActive: false,
        emailVerified: true,
        createdAt: DateTime(2024, 6, 1),
      );
      // Equality is based on ID only
      expect(user1, equals(user2));
    });

    test('different IDs means not equal', () {
      final user1 = User(
        id: 'id-1',
        email: 'a@test.com',
        role: UserRole.individual,
        isActive: true,
        emailVerified: false,
        createdAt: DateTime.now(),
      );
      final user2 = User(
        id: 'id-2',
        email: 'a@test.com',
        role: UserRole.individual,
        isActive: true,
        emailVerified: false,
        createdAt: DateTime.now(),
      );
      expect(user1, isNot(equals(user2)));
    });

    test('toString returns expected format', () {
      final str = user.toString();
      expect(str, contains('User'));
      expect(str, contains('user-123'));
      expect(str, contains('test@example.com'));
    });
  });

  group('UserRole Enum', () {
    test('has correct values', () {
      expect(UserRole.values.length, 5);
      expect(UserRole.values, contains(UserRole.individual));
      expect(UserRole.values, contains(UserRole.viewer));
      expect(UserRole.values, contains(UserRole.editor));
      expect(UserRole.values, contains(UserRole.admin));
      expect(UserRole.values, contains(UserRole.superAdmin));
    });

    test('fromString converts string to role correctly', () {
      expect(UserRole.fromString('super_admin'), UserRole.superAdmin);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('editor'), UserRole.editor);
      expect(UserRole.fromString('viewer'), UserRole.viewer);
      expect(UserRole.fromString('individual'), UserRole.individual);
    });

    test('fromString returns individual for unknown string', () {
      expect(UserRole.fromString('unknown'), UserRole.individual);
      expect(UserRole.fromString(''), UserRole.individual);
    });

    test('toApiString converts role to API string', () {
      expect(UserRole.superAdmin.toApiString(), 'super_admin');
      expect(UserRole.admin.toApiString(), 'admin');
      expect(UserRole.editor.toApiString(), 'editor');
      expect(UserRole.viewer.toApiString(), 'viewer');
      expect(UserRole.individual.toApiString(), 'individual');
    });

    test('displayName returns human-readable names', () {
      expect(UserRole.superAdmin.displayName, 'Super-Admin');
      expect(UserRole.admin.displayName, 'Admin');
      expect(UserRole.editor.displayName, 'Editor');
      expect(UserRole.viewer.displayName, 'Viewer');
      expect(UserRole.individual.displayName, 'Einzelperson');
    });
  });
}
