// =============================================================================
// CARDS_PROVIDER.DART
// =============================================================================
// Riverpod Provider fuer Cards State Management (Web Version)
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/features/cards/domain/entities/card.dart';
import '../../../../shared/features/cards/data/dtos/card_dto.dart';
import '../../data/repositories/card_repository.dart';

// =============================================================================
// REPOSITORY PROVIDER
// =============================================================================

/// Provider fuer das CardRepository
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl();
});

// =============================================================================
// CARDS STATE
// =============================================================================

/// State fuer die Kartenliste
sealed class CardsState {
  const CardsState();
}

class CardsInitial extends CardsState {
  const CardsInitial();
}

class CardsLoading extends CardsState {
  const CardsLoading();
}

class CardsLoaded extends CardsState {
  const CardsLoaded(this.cards);
  final List<Card> cards;
}

class CardsError extends CardsState {
  const CardsError(this.message);
  final String message;
}

// =============================================================================
// CARDS NOTIFIER
// =============================================================================

/// StateNotifier fuer die Kartenliste des aktuellen Users
class CardsNotifier extends StateNotifier<CardsState> {
  CardsNotifier(this._repository) : super(const CardsInitial());

  final CardRepository _repository;

  /// Laedt alle Karten des aktuellen Users
  Future<void> loadMyCards() async {
    state = const CardsLoading();

    final result = await _repository.getMyCards();

    if (result.isSuccess && result.data != null) {
      state = CardsLoaded(result.data!);
    } else {
      state = CardsError(result.error ?? 'Fehler beim Laden der Karten');
    }
  }

  /// Fuegt eine neue Karte hinzu
  Future<bool> createCard(CardCreateDto data) async {
    final result = await _repository.createCard(data);

    if (result.isSuccess && result.data != null) {
      // Aktuelle Liste aktualisieren
      if (state is CardsLoaded) {
        final currentCards = (state as CardsLoaded).cards;
        state = CardsLoaded([result.data!, ...currentCards]);
      }
      return true;
    }
    return false;
  }

  /// Aktualisiert eine Karte
  Future<bool> updateCard(String cardId, CardUpdateDto data) async {
    final result = await _repository.updateCard(cardId, data);

    if (result.isSuccess && result.data != null) {
      // Aktuelle Liste aktualisieren
      if (state is CardsLoaded) {
        final currentCards = (state as CardsLoaded).cards;
        final updatedCards = currentCards.map((card) {
          return card.id == cardId ? result.data! : card;
        }).toList();
        state = CardsLoaded(updatedCards);
      }
      return true;
    }
    return false;
  }

  /// Loescht eine Karte
  Future<bool> deleteCard(String cardId) async {
    final result = await _repository.deleteCard(cardId);

    if (result.isSuccess) {
      // Aus der Liste entfernen
      if (state is CardsLoaded) {
        final currentCards = (state as CardsLoaded).cards;
        final filteredCards =
            currentCards.where((card) => card.id != cardId).toList();
        state = CardsLoaded(filteredCards);
      }
      return true;
    }
    return false;
  }

  /// Aktualisiert die Liste (Pull-to-Refresh)
  Future<void> refresh() => loadMyCards();
}

// =============================================================================
// SINGLE CARD STATE
// =============================================================================

/// State fuer eine einzelne Karte
sealed class SingleCardState {
  const SingleCardState();
}

class SingleCardInitial extends SingleCardState {
  const SingleCardInitial();
}

class SingleCardLoading extends SingleCardState {
  const SingleCardLoading();
}

class SingleCardLoaded extends SingleCardState {
  const SingleCardLoaded(this.card);
  final Card card;
}

class SingleCardError extends SingleCardState {
  const SingleCardError(this.message);
  final String message;
}

// =============================================================================
// SINGLE CARD NOTIFIER
// =============================================================================

/// StateNotifier fuer eine einzelne Karte
class SingleCardNotifier extends StateNotifier<SingleCardState> {
  SingleCardNotifier(this._repository) : super(const SingleCardInitial());

  final CardRepository _repository;

  /// Laedt eine Karte anhand der ID
  Future<void> loadCard(String cardId) async {
    state = const SingleCardLoading();

    final result = await _repository.getCard(cardId);

    if (result.isSuccess && result.data != null) {
      state = SingleCardLoaded(result.data!);
    } else {
      state = SingleCardError(result.error ?? 'Karte nicht gefunden');
    }
  }

  /// Laedt eine oeffentliche Karte anhand des Slugs
  Future<void> loadPublicCard(String slug) async {
    state = const SingleCardLoading();

    final result = await _repository.getPublicCard(slug);

    if (result.isSuccess && result.data != null) {
      state = SingleCardLoaded(result.data!);
    } else {
      state = SingleCardError(result.error ?? 'Karte nicht gefunden');
    }
  }
}

// =============================================================================
// SHARE STATE
// =============================================================================

/// State fuer Card Sharing
sealed class ShareCardState {
  const ShareCardState();
}

class ShareCardInitial extends ShareCardState {
  const ShareCardInitial();
}

class ShareCardLoading extends ShareCardState {
  const ShareCardLoading();
}

class ShareCardSuccess extends ShareCardState {
  const ShareCardSuccess(this.result);
  final CardShareResult result;
}

class ShareCardError extends ShareCardState {
  const ShareCardError(this.message);
  final String message;
}

// =============================================================================
// SHARE CARD NOTIFIER
// =============================================================================

/// StateNotifier fuer Card Sharing
class ShareCardNotifier extends StateNotifier<ShareCardState> {
  ShareCardNotifier(this._repository) : super(const ShareCardInitial());

  final CardRepository _repository;

  /// Teilt eine Karte
  Future<bool> shareCard(String cardId, {String? email}) async {
    state = const ShareCardLoading();

    final result = await _repository.shareCard(cardId, email: email);

    if (result.isSuccess && result.data != null) {
      state = ShareCardSuccess(result.data!);
      return true;
    } else {
      state = ShareCardError(result.error ?? 'Fehler beim Teilen der Karte');
      return false;
    }
  }

  /// Reset State
  void reset() {
    state = const ShareCardInitial();
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider fuer die Kartenliste des aktuellen Users
final cardsProvider = StateNotifierProvider<CardsNotifier, CardsState>((ref) {
  final repository = ref.watch(cardRepositoryProvider);
  return CardsNotifier(repository);
});

/// Provider fuer eine einzelne Karte
final singleCardProvider =
    StateNotifierProvider.family<SingleCardNotifier, SingleCardState, String>(
  (ref, cardId) {
    final repository = ref.watch(cardRepositoryProvider);
    final notifier = SingleCardNotifier(repository);
    // Auto-load wenn Provider erstellt wird
    notifier.loadCard(cardId);
    return notifier;
  },
);

/// Provider fuer eine oeffentliche Karte (anhand Slug)
final publicCardProvider =
    StateNotifierProvider.family<SingleCardNotifier, SingleCardState, String>(
  (ref, slug) {
    final repository = ref.watch(cardRepositoryProvider);
    final notifier = SingleCardNotifier(repository);
    notifier.loadPublicCard(slug);
    return notifier;
  },
);

/// Provider fuer Card Sharing
final shareCardProvider =
    StateNotifierProvider<ShareCardNotifier, ShareCardState>((ref) {
  final repository = ref.watch(cardRepositoryProvider);
  return ShareCardNotifier(repository);
});
