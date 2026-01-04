// =============================================================================
// CONTACTS_PROVIDER.DART
// =============================================================================
// Riverpod Provider fuer Contacts State Management
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/features/contacts/domain/entities/contact.dart';
import '../../../../shared/features/contacts/data/dtos/contact_dto.dart';
import '../../data/repositories/contact_repository.dart';

// =============================================================================
// REPOSITORY PROVIDER
// =============================================================================

/// Provider fuer das ContactRepository
final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepositoryImpl();
});

// =============================================================================
// CONTACTS STATE
// =============================================================================

/// State fuer die Kontaktliste
sealed class ContactsState {
  const ContactsState();
}

class ContactsInitial extends ContactsState {
  const ContactsInitial();
}

class ContactsLoading extends ContactsState {
  const ContactsLoading();
}

class ContactsLoaded extends ContactsState {
  const ContactsLoaded({
    required this.contacts,
    required this.stats,
    this.searchQuery,
    this.selectedTags,
    this.favoritesOnly = false,
  });

  final List<Contact> contacts;
  final ContactStats stats;
  final String? searchQuery;
  final List<String>? selectedTags;
  final bool favoritesOnly;

  ContactsLoaded copyWith({
    List<Contact>? contacts,
    ContactStats? stats,
    String? searchQuery,
    List<String>? selectedTags,
    bool? favoritesOnly,
  }) {
    return ContactsLoaded(
      contacts: contacts ?? this.contacts,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTags: selectedTags ?? this.selectedTags,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}

class ContactsError extends ContactsState {
  const ContactsError(this.message);
  final String message;
}

// =============================================================================
// CONTACTS NOTIFIER
// =============================================================================

/// StateNotifier fuer die Kontaktliste
class ContactsNotifier extends StateNotifier<ContactsState> {
  ContactsNotifier(this._repository) : super(const ContactsInitial());

  final ContactRepository _repository;
  String? _currentSearch;
  List<String>? _currentTags;
  bool _favoritesOnly = false;

  /// Laedt alle Kontakte des Users mit optionalen Filtern
  Future<void> loadContacts({
    String? search,
    List<String>? tags,
    bool? favoritesOnly,
  }) async {
    state = const ContactsLoading();

    // Filter merken
    _currentSearch = search;
    _currentTags = tags;
    if (favoritesOnly != null) _favoritesOnly = favoritesOnly;

    // Parallel: Kontakte und Stats laden
    final results = await Future.wait([
      _repository.getContacts(
        search: search,
        tags: tags,
        favoritesOnly: _favoritesOnly,
      ),
      _repository.getStats(),
    ]);

    final contactsResult = results[0] as ContactResult<List<Contact>>;
    final statsResult = results[1] as ContactResult<ContactStats>;

    if (contactsResult.isSuccess && statsResult.isSuccess) {
      state = ContactsLoaded(
        contacts: contactsResult.data!,
        stats: statsResult.data!,
        searchQuery: search,
        selectedTags: tags,
        favoritesOnly: _favoritesOnly,
      );
    } else {
      state = ContactsError(
        contactsResult.error ?? statsResult.error ?? 'Fehler beim Laden',
      );
    }
  }

  /// Sucht Kontakte
  Future<void> search(String query) async {
    await loadContacts(
      search: query.isNotEmpty ? query : null,
      tags: _currentTags,
      favoritesOnly: _favoritesOnly,
    );
  }

  /// Filtert nach Tags
  Future<void> filterByTags(List<String> tags) async {
    await loadContacts(
      search: _currentSearch,
      tags: tags.isNotEmpty ? tags : null,
      favoritesOnly: _favoritesOnly,
    );
  }

  /// Toggled Favoriten-Filter
  Future<void> toggleFavoritesFilter() async {
    _favoritesOnly = !_favoritesOnly;
    await loadContacts(
      search: _currentSearch,
      tags: _currentTags,
      favoritesOnly: _favoritesOnly,
    );
  }

  /// Erstellt einen neuen Kontakt
  Future<bool> createContact(ContactCreateDto data) async {
    final result = await _repository.createContact(data);

    if (result.isSuccess && result.data != null) {
      // Liste aktualisieren
      if (state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;
        final updatedContacts = [result.data!, ...currentState.contacts];
        final updatedStats = ContactStats(
          totalContacts: currentState.stats.totalContacts + 1,
          favoriteContacts: currentState.stats.favoriteContacts,
          maxContacts: currentState.stats.maxContacts,
          limitReached: currentState.stats.totalContacts + 1 >=
              currentState.stats.maxContacts,
          remaining: currentState.stats.remaining != null
              ? currentState.stats.remaining! - 1
              : null,
          planType: currentState.stats.planType,
        );
        state = currentState.copyWith(
          contacts: updatedContacts,
          stats: updatedStats,
        );
      }
      return true;
    }
    return false;
  }

  /// Aktualisiert einen Kontakt
  Future<bool> updateContact(String contactId, ContactUpdateDto data) async {
    final result = await _repository.updateContact(contactId, data);

    if (result.isSuccess && result.data != null) {
      // Liste aktualisieren
      if (state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;
        final updatedContacts = currentState.contacts.map((c) {
          return c.id == contactId ? result.data! : c;
        }).toList();
        state = currentState.copyWith(contacts: updatedContacts);
      }
      return true;
    }
    return false;
  }

  /// Loescht einen Kontakt
  Future<bool> deleteContact(String contactId) async {
    final result = await _repository.deleteContact(contactId);

    if (result.isSuccess) {
      // Aus Liste entfernen
      if (state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;
        final updatedContacts =
            currentState.contacts.where((c) => c.id != contactId).toList();
        final updatedStats = ContactStats(
          totalContacts: currentState.stats.totalContacts - 1,
          favoriteContacts: currentState.stats.favoriteContacts,
          maxContacts: currentState.stats.maxContacts,
          limitReached: false,
          remaining: currentState.stats.remaining != null
              ? currentState.stats.remaining! + 1
              : null,
          planType: currentState.stats.planType,
        );
        state = currentState.copyWith(
          contacts: updatedContacts,
          stats: updatedStats,
        );
      }
      return true;
    }
    return false;
  }

  /// Toggled Favorit-Status eines Kontakts
  Future<bool> toggleFavorite(String contactId) async {
    final result = await _repository.toggleFavorite(contactId);

    if (result.isSuccess && result.data != null) {
      // Liste aktualisieren
      if (state is ContactsLoaded) {
        final currentState = state as ContactsLoaded;
        final updatedContacts = currentState.contacts.map((c) {
          return c.id == contactId ? result.data! : c;
        }).toList();

        // Favoriten-Count aktualisieren
        final favDelta = result.data!.isFavorite ? 1 : -1;
        final updatedStats = ContactStats(
          totalContacts: currentState.stats.totalContacts,
          favoriteContacts: currentState.stats.favoriteContacts + favDelta,
          maxContacts: currentState.stats.maxContacts,
          limitReached: currentState.stats.limitReached,
          remaining: currentState.stats.remaining,
          planType: currentState.stats.planType,
        );

        state = currentState.copyWith(
          contacts: updatedContacts,
          stats: updatedStats,
        );
      }
      return true;
    }
    return false;
  }

  /// Aktualisiert die Liste (Pull-to-Refresh)
  Future<void> refresh() => loadContacts(
        search: _currentSearch,
        tags: _currentTags,
        favoritesOnly: _favoritesOnly,
      );
}

// =============================================================================
// SINGLE CONTACT STATE
// =============================================================================

/// State fuer einen einzelnen Kontakt
sealed class SingleContactState {
  const SingleContactState();
}

class SingleContactInitial extends SingleContactState {
  const SingleContactInitial();
}

class SingleContactLoading extends SingleContactState {
  const SingleContactLoading();
}

class SingleContactLoaded extends SingleContactState {
  const SingleContactLoaded(this.contact);
  final Contact contact;
}

class SingleContactError extends SingleContactState {
  const SingleContactError(this.message);
  final String message;
}

// =============================================================================
// SINGLE CONTACT NOTIFIER
// =============================================================================

/// StateNotifier fuer einen einzelnen Kontakt
class SingleContactNotifier extends StateNotifier<SingleContactState> {
  SingleContactNotifier(this._repository) : super(const SingleContactInitial());

  final ContactRepository _repository;

  /// Laedt einen Kontakt anhand der ID
  Future<void> loadContact(String contactId) async {
    state = const SingleContactLoading();

    final result = await _repository.getContact(contactId);

    if (result.isSuccess && result.data != null) {
      state = SingleContactLoaded(result.data!);
    } else {
      state = SingleContactError(result.error ?? 'Kontakt nicht gefunden');
    }
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider fuer die Kontaktliste
final contactsProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  final repository = ref.watch(contactRepositoryProvider);
  return ContactsNotifier(repository);
});

/// Provider fuer einen einzelnen Kontakt
final singleContactProvider = StateNotifierProvider.family<
    SingleContactNotifier, SingleContactState, String>(
  (ref, contactId) {
    final repository = ref.watch(contactRepositoryProvider);
    final notifier = SingleContactNotifier(repository);
    notifier.loadContact(contactId);
    return notifier;
  },
);

/// Provider fuer Kontakt-Statistiken
final contactStatsProvider = FutureProvider<ContactStats?>((ref) async {
  final repository = ref.watch(contactRepositoryProvider);
  final result = await repository.getStats();
  return result.isSuccess ? result.data : null;
});
