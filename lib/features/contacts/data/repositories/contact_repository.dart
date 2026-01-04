// =============================================================================
// CONTACT_REPOSITORY.DART
// =============================================================================
// Repository fuer Contact API Operationen
// =============================================================================

import '../../../../shared/core/network/api_client.dart';
import '../../../../shared/core/config/app_config.dart';
import '../../../../shared/features/contacts/domain/entities/contact.dart';
import '../../../../shared/features/contacts/data/dtos/contact_dto.dart';

/// Result Wrapper fuer Repository Operationen
class ContactResult<T> {
  const ContactResult.success(this.data)
      : error = null,
        isSuccess = true;
  const ContactResult.failure(this.error)
      : data = null,
        isSuccess = false;

  final T? data;
  final String? error;
  final bool isSuccess;
}

/// Abstract Repository Interface
abstract class ContactRepository {
  /// Holt alle Kontakte des Users
  Future<ContactResult<List<Contact>>> getContacts({
    String? search,
    List<String>? tags,
    bool? favoritesOnly,
    int page = 1,
    int pageSize = 50,
  });

  /// Holt einen einzelnen Kontakt
  Future<ContactResult<Contact>> getContact(String contactId);

  /// Erstellt einen neuen Kontakt
  Future<ContactResult<Contact>> createContact(ContactCreateDto data);

  /// Aktualisiert einen Kontakt
  Future<ContactResult<Contact>> updateContact(
      String contactId, ContactUpdateDto data);

  /// Loescht einen Kontakt
  Future<ContactResult<void>> deleteContact(String contactId);

  /// Holt Kontakt-Statistiken
  Future<ContactResult<ContactStats>> getStats();

  /// Toggled Favorit-Status
  Future<ContactResult<Contact>> toggleFavorite(String contactId);
}

/// Repository Implementation
class ContactRepositoryImpl implements ContactRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<ContactResult<List<Contact>>> getContacts({
    String? search,
    List<String>? tags,
    bool? favoritesOnly,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags.join(',');
      }
      if (favoritesOnly == true) {
        queryParams['favorites_only'] = 'true';
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _apiClient.get(
        '${AppConfig.contactsAll}?$queryString',
      );

      if (response.isSuccess && response.data != null) {
        // API gibt entweder Array oder Object mit 'items' zurueck
        final List<dynamic> items = response.data is List
            ? response.data
            : (response.data['items'] as List<dynamic>? ?? []);

        final contacts =
            items.map((json) => ContactDto.fromJson(json).toDomain()).toList();

        return ContactResult.success(contacts);
      } else {
        return ContactResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Kontakte');
      }
    } catch (e) {
      return ContactResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<ContactResult<Contact>> getContact(String contactId) async {
    try {
      final response = await _apiClient.get(
        AppConfig.contactById(contactId),
      );

      if (response.isSuccess && response.data != null) {
        final contact = ContactDto.fromJson(response.data).toDomain();
        return ContactResult.success(contact);
      } else {
        return ContactResult.failure(
            response.errorMessage ?? 'Kontakt nicht gefunden');
      }
    } catch (e) {
      return ContactResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<ContactResult<Contact>> createContact(ContactCreateDto data) async {
    try {
      final response = await _apiClient.post(
        AppConfig.contactsCreate,
        body: data.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final contact = ContactDto.fromJson(response.data).toDomain();
        return ContactResult.success(contact);
      } else {
        return ContactResult.failure(
            response.errorMessage ?? 'Fehler beim Erstellen des Kontakts');
      }
    } catch (e) {
      return ContactResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<ContactResult<Contact>> updateContact(
    String contactId,
    ContactUpdateDto data,
  ) async {
    try {
      final response = await _apiClient.put(
        AppConfig.contactUpdate(contactId),
        body: data.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final contact = ContactDto.fromJson(response.data).toDomain();
        return ContactResult.success(contact);
      } else {
        return ContactResult.failure(
            response.errorMessage ?? 'Fehler beim Aktualisieren des Kontakts');
      }
    } catch (e) {
      return ContactResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<ContactResult<void>> deleteContact(String contactId) async {
    try {
      final response = await _apiClient.delete(
        AppConfig.contactDelete(contactId),
      );

      if (response.isSuccess) {
        return const ContactResult.success(null);
      } else {
        return ContactResult.failure(
            response.errorMessage ?? 'Fehler beim Loeschen des Kontakts');
      }
    } catch (e) {
      return ContactResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<ContactResult<ContactStats>> getStats() async {
    try {
      final response = await _apiClient.get(
        AppConfig.contactsCount,
      );

      if (response.isSuccess && response.data != null) {
        final stats = ContactStatsDto.fromJson(response.data).toDomain();
        return ContactResult.success(stats);
      } else {
        return ContactResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Statistiken');
      }
    } catch (e) {
      return ContactResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<ContactResult<Contact>> toggleFavorite(String contactId) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.contactById(contactId)}/favorite',
        body: {},
      );

      if (response.isSuccess && response.data != null) {
        final contact = ContactDto.fromJson(response.data).toDomain();
        return ContactResult.success(contact);
      } else {
        return ContactResult.failure(
            response.errorMessage ?? 'Fehler beim Aendern des Favoriten-Status');
      }
    } catch (e) {
      return ContactResult.failure('Netzwerkfehler: $e');
    }
  }
}
