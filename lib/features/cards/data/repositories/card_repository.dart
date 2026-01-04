// =============================================================================
// CARD_REPOSITORY.DART
// =============================================================================
// Repository fuer Card-Operationen (Web Version)
// =============================================================================

import '../../../../shared/core/config/app_config.dart';
import '../../../../shared/core/network/api_client.dart';
import '../../../../shared/features/cards/domain/entities/card.dart';
import '../../../../shared/features/cards/data/dtos/card_dto.dart';

/// Abstrakte Card Repository Schnittstelle
abstract class CardRepository {
  Future<CardResult<List<Card>>> getMyCards();
  Future<CardResult<Card>> getCard(String cardId);
  Future<CardResult<Card>> getPublicCard(String slug);
  Future<CardResult<Card>> createCard(CardCreateDto data);
  Future<CardResult<Card>> updateCard(String cardId, CardUpdateDto data);
  Future<CardResult<void>> deleteCard(String cardId);
  Future<CardResult<CardShareResult>> shareCard(String cardId, {String? email});
}

/// Implementierung des Card Repository
class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl([ApiClient? client]) : _apiClient = client ?? ApiClient();

  final ApiClient _apiClient;

  /// Setzt den Access Token
  void setAccessToken(String? token) {
    _apiClient.setAccessToken(token);
  }

  @override
  Future<CardResult<List<Card>>> getMyCards() async {
    try {
      final response = await _apiClient.get(AppConfig.cardsAll);

      if (response.isSuccess && response.data != null) {
        final list = response.data as List<dynamic>;
        final cards = list
            .map((json) => CardDto.fromJson(json as Map<String, dynamic>).toDomain())
            .toList();
        return CardResult.success(cards);
      } else {
        return CardResult.failure(
          response.errorMessage ?? 'Fehler beim Laden der Karten',
        );
      }
    } catch (e) {
      return CardResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }

  @override
  Future<CardResult<Card>> getCard(String cardId) async {
    try {
      final response = await _apiClient.get(AppConfig.cardById(cardId));

      if (response.isSuccess && response.data != null) {
        final card =
            CardDto.fromJson(response.data as Map<String, dynamic>).toDomain();
        return CardResult.success(card);
      } else {
        return CardResult.failure(
          response.errorMessage ?? 'Karte nicht gefunden',
        );
      }
    } catch (e) {
      return CardResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }

  @override
  Future<CardResult<Card>> getPublicCard(String slug) async {
    try {
      final response = await _apiClient.get(
        AppConfig.cardPublic(slug),
        autoRefresh: false,
      );

      if (response.isSuccess && response.data != null) {
        final card =
            CardDto.fromJson(response.data as Map<String, dynamic>).toDomain();
        return CardResult.success(card);
      } else {
        return CardResult.failure(
          response.errorMessage ?? 'Karte nicht gefunden',
        );
      }
    } catch (e) {
      return CardResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }

  @override
  Future<CardResult<Card>> createCard(CardCreateDto data) async {
    try {
      final response = await _apiClient.post(
        AppConfig.cardsCreate,
        body: data.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final card =
            CardDto.fromJson(response.data as Map<String, dynamic>).toDomain();
        return CardResult.success(card);
      } else {
        return CardResult.failure(
          response.errorMessage ?? 'Fehler beim Erstellen der Karte',
        );
      }
    } catch (e) {
      return CardResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }

  @override
  Future<CardResult<Card>> updateCard(String cardId, CardUpdateDto data) async {
    try {
      final response = await _apiClient.put(
        AppConfig.cardUpdate(cardId),
        body: data.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final card =
            CardDto.fromJson(response.data as Map<String, dynamic>).toDomain();
        return CardResult.success(card);
      } else {
        return CardResult.failure(
          response.errorMessage ?? 'Fehler beim Aktualisieren der Karte',
        );
      }
    } catch (e) {
      return CardResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }

  @override
  Future<CardResult<void>> deleteCard(String cardId) async {
    try {
      final response = await _apiClient.delete(AppConfig.cardDelete(cardId));

      if (response.isSuccess) {
        return CardResult.success(null);
      } else {
        return CardResult.failure(
          response.errorMessage ?? 'Fehler beim Loeschen der Karte',
        );
      }
    } catch (e) {
      return CardResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }

  @override
  Future<CardResult<CardShareResult>> shareCard(
    String cardId, {
    String? email,
  }) async {
    try {
      final body = <String, dynamic>{'card_id': cardId};
      if (email != null) body['shared_with_email'] = email;

      final response = await _apiClient.post(
        AppConfig.cardShare(cardId),
        body: body,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return CardResult.success(CardShareResult(
          cardId: data['card_id']?.toString() ?? cardId,
          shareUrl: data['share_url']?.toString() ?? '',
          sharedWithEmail: data['shared_with']?.toString(),
          sharedAt:
              DateTime.tryParse(data['shared_at']?.toString() ?? '') ??
                  DateTime.now(),
        ));
      } else {
        return CardResult.failure(
          response.errorMessage ?? 'Fehler beim Teilen der Karte',
        );
      }
    } catch (e) {
      return CardResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }
}

/// Result-Klasse fuer Card-Operationen
class CardResult<T> {
  const CardResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  final T? data;
  final String? error;
  final bool isSuccess;

  factory CardResult.success(T? data) {
    return CardResult._(data: data, isSuccess: true);
  }

  factory CardResult.failure(String error) {
    return CardResult._(error: error, isSuccess: false);
  }
}

/// Share Result Daten
class CardShareResult {
  const CardShareResult({
    required this.cardId,
    required this.shareUrl,
    this.sharedWithEmail,
    required this.sharedAt,
  });

  final String cardId;
  final String shareUrl;
  final String? sharedWithEmail;
  final DateTime sharedAt;
}
