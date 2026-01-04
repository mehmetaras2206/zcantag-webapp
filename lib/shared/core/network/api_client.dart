// =============================================================================
// API_CLIENT.DART (Web Version)
// =============================================================================
// HTTP-Client fuer Web-App. Angepasst von mobilapp Version.
// Verwendet WebStorage statt SecureStorage.
// =============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/web_storage.dart';

/// Zentrale API-Client Klasse fuer alle HTTP-Requests
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _accessToken;
  bool _isRefreshing = false;

  /// Setzt den Access Token fuer authentifizierte Requests
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Gibt den aktuellen Access Token zurueck
  String? get accessToken => _accessToken;

  /// Standard HTTP-Headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  /// HTTP POST Request
  Future<ApiResponse> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool autoRefresh = true,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {..._headers, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponseWithRefresh(
        response,
        () => post(url, body: body, headers: headers, autoRefresh: false),
        autoRefresh,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// HTTP GET Request
  Future<ApiResponse> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    bool autoRefresh = true,
  }) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client
          .get(
            uri,
            headers: {..._headers, ...?headers},
          )
          .timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponseWithRefresh(
        response,
        () => get(url, headers: headers, queryParams: queryParams, autoRefresh: false),
        autoRefresh,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// HTTP PUT Request
  Future<ApiResponse> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool autoRefresh = true,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: {..._headers, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponseWithRefresh(
        response,
        () => put(url, body: body, headers: headers, autoRefresh: false),
        autoRefresh,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// HTTP DELETE Request
  Future<ApiResponse> delete(
    String url, {
    Map<String, String>? headers,
    bool autoRefresh = true,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: {..._headers, ...?headers},
          )
          .timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponseWithRefresh(
        response,
        () => delete(url, headers: headers, autoRefresh: false),
        autoRefresh,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// HTTP PATCH Request
  Future<ApiResponse> patch(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool autoRefresh = true,
  }) async {
    try {
      final response = await _client
          .patch(
            Uri.parse(url),
            headers: {..._headers, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      return _handleResponseWithRefresh(
        response,
        () => patch(url, body: body, headers: headers, autoRefresh: false),
        autoRefresh,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// File Upload mit Multipart-Request
  Future<ApiResponse> uploadFile(
    String url,
    List<int> fileBytes,
    String fileName, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool autoRefresh = true,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Auth-Header hinzufuegen
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      // Datei hinzufuegen
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: fileName,
      ));

      // Zusaetzliche Felder hinzufuegen
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(
            Duration(milliseconds: AppConfig.connectionTimeout),
          );
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponseWithRefresh(
        response,
        () => uploadFile(
          url,
          fileBytes,
          fileName,
          fieldName: fieldName,
          additionalFields: additionalFields,
          autoRefresh: false,
        ),
        autoRefresh,
      );
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Error-Handler
  ApiResponse _handleError(Object e) {
    if (e.toString().contains('TimeoutException')) {
      return ApiResponse.error('Verbindungs-Timeout');
    }
    return ApiResponse.error('Netzwerkfehler: ${e.toString()}');
  }

  /// Response-Handler mit automatischem Token-Refresh
  Future<ApiResponse> _handleResponseWithRefresh(
    http.Response response,
    Future<ApiResponse> Function() retryRequest,
    bool autoRefresh,
  ) async {
    final statusCode = response.statusCode;

    if (statusCode == 401 && autoRefresh && !_isRefreshing) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        return retryRequest();
      }
      return ApiResponse.error(
        'Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an.',
        401,
      );
    }

    return _handleResponse(response);
  }

  /// Token-Refresh
  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await WebStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _client
          .post(
            Uri.parse(AppConfig.authRefresh),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(Duration(milliseconds: AppConfig.connectionTimeout));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = body['access_token'] as String?;
        final newRefreshToken = body['refresh_token'] as String?;

        if (newAccessToken != null) {
          await WebStorage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await WebStorage.saveRefreshToken(newRefreshToken);
          }
          _accessToken = newAccessToken;
          return true;
        }
      }

      await WebStorage.clearAuthData();
      _accessToken = null;
      return false;
    } catch (e) {
      await WebStorage.clearAuthData();
      _accessToken = null;
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Response-Handler
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(body, statusCode);
    }

    String errorMessage = 'Unbekannter Fehler';

    if (body is Map<String, dynamic>) {
      errorMessage = body['detail']?.toString() ??
          body['message']?.toString() ??
          body['error']?.toString() ??
          errorMessage;
    }

    switch (statusCode) {
      case 400:
        return ApiResponse.error(errorMessage, statusCode);
      case 401:
        return ApiResponse.error('Nicht autorisiert', statusCode);
      case 403:
        return ApiResponse.error('Zugriff verweigert', statusCode);
      case 404:
        return ApiResponse.error('Nicht gefunden', statusCode);
      case 409:
        return ApiResponse.error(errorMessage, statusCode);
      case 422:
        return ApiResponse.error('Ungueltige Eingabe', statusCode);
      case 500:
        return ApiResponse.error('Server-Fehler', statusCode);
      default:
        return ApiResponse.error(errorMessage, statusCode);
    }
  }

  /// Schliesst den HTTP-Client
  void dispose() {
    _client.close();
  }
}

// =============================================================================
// API RESPONSE KLASSE
// =============================================================================

/// Wrapper-Klasse fuer API-Responses mit Result-Pattern
class ApiResponse {
  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data, int statusCode) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse._(
      isSuccess: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }

  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;
  final int? statusCode;

  bool get isAuthError => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}
