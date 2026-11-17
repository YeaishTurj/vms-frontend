import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import 'api_exception.dart';

/// Standard HTTP Client for VMS API communication.
/// Handles request execution, JSON parsing, timeouts, and standardized error conversion.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Performs an HTTP GET request.
  Future<dynamic> get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _defaultHeaders)
          .timeout(ApiConfig.timeout);
      return _processResponse(response);
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
      return _processResponse(response);
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
      return _processResponse(response);
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
      return _processResponse(response);
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  dynamic _processResponse(http.Response response) {
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
    if (error is SocketException) {
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
