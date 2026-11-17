import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import 'api_exception.dart';

/// Standard HTTP Client for VMS API communication.
/// Handles request execution, JSON parsing, timeouts, Bearer token injection, and standardized error conversion.
class ApiClient {
  static String? Function()? defaultTokenProvider;
  static void Function()? defaultOnUnauthorized;

  final http.Client _client;
  final String? Function()? _tokenProvider;
  final void Function()? _onUnauthorized;

  ApiClient({
    http.Client? client,
    String? Function()? tokenProvider,
    void Function()? onUnauthorized,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider,
        _onUnauthorized = onUnauthorized;

  Map<String, String> get _defaultHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _tokenProvider?.call() ?? defaultTokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Performs an HTTP GET request.
  Future<dynamic> get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _defaultHeaders)
          .timeout(ApiConfig.timeout);
      return _processResponse(response, requestUri: uri);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  /// Performs an HTTP POST request.
  Future<dynamic> post(Uri uri, {Map<String, dynamic>? body}) async {
    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client
          .post(uri, headers: _defaultHeaders, body: encodedBody)
          .timeout(ApiConfig.timeout);
      return _processResponse(response, requestUri: uri);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  /// Performs an HTTP PUT request.
  Future<dynamic> put(Uri uri, {Map<String, dynamic>? body}) async {
    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client
          .put(uri, headers: _defaultHeaders, body: encodedBody)
          .timeout(ApiConfig.timeout);
      return _processResponse(response, requestUri: uri);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  /// Performs an HTTP DELETE request.
  Future<dynamic> delete(Uri uri) async {
    try {
      final response = await _client
          .delete(uri, headers: _defaultHeaders)
          .timeout(ApiConfig.timeout);
      return _processResponse(response, requestUri: uri);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  dynamic _processResponse(http.Response response, {Uri? requestUri}) {
    final statusCode = response.statusCode;

    // Successful 204 No Content or empty payload
    if (statusCode == 204 || response.body.isEmpty) {
      return null;
    }

    dynamic decodedJson;
    try {
      decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      decodedJson = null;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedJson;
    }

    // Intercept 401 Unauthorized on protected routes to trigger session expiration
    if (statusCode == 401) {
      final isLogin = requestUri != null && requestUri.path.contains('/auth/login');
      if (!isLogin) {
        final callback = _onUnauthorized ?? defaultOnUnauthorized;
        callback?.call();
      }
    }

    // Backend returned an error response (4xx, 5xx)
    String message = 'Request failed with status $statusCode';
    String? error;
    Map<String, String>? fieldErrors;

    if (decodedJson is Map<String, dynamic>) {
      error = decodedJson['error'] as String?;
      message = (decodedJson['message'] as String?) ?? message;

      if (decodedJson['details'] is Map) {
        fieldErrors = (decodedJson['details'] as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
    }

    throw ApiException(
      statusCode: statusCode,
      message: message,
      error: error,
      fieldErrors: fieldErrors,
    );
  }

  ApiException _handleNetworkError(Object error) {
    if (error is ApiException) {
      return error;
    }
    if (error is TimeoutException) {
      return const ApiException(
        statusCode: 408,
        message: 'Request timed out. Please verify backend connection and try again.',
      );
    }
    if (error is http.ClientException) {
      return const ApiException(
        statusCode: 503,
        message: 'Cannot reach VMS backend server. Please verify Spring Boot is running.',
      );
    }
    return ApiException(
      statusCode: 0,
      message: 'Network communication error: ${error.toString()}',
    );
  }

  void close() {
    _client.close();
  }
}
