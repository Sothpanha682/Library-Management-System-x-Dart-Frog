import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.code = 'ERROR',
    this.statusCode = 500,
    this.details,
  });

  final String message;
  final String code;
  final int statusCode;
  final dynamic details;

  @override
  String toString() => message;
}

class ApiClient {
  static const Duration timeoutDuration = Duration(seconds: 15);

  static Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    }

    String message = 'An unexpected error occurred.';
    String code = 'UNKNOWN_ERROR';
    dynamic details;

    if (jsonBody is Map<String, dynamic>) {
      message = jsonBody['message'] as String? ?? message;
      if (jsonBody['error'] is Map<String, dynamic>) {
        code = jsonBody['error']['code'] as String? ?? code;
        details = jsonBody['error']['details'];
      }
    }

    throw ApiException(
      message: message,
      code: code,
      statusCode: response.statusCode,
      details: details,
    );
  }

  static Future<dynamic> get(String url, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'Unable to connect to the library server. Check your network or server status.',
        code: 'NETWORK_ERROR',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timed out. Please try again.',
        code: 'TIMEOUT',
        statusCode: 408,
      );
    }
  }

  static Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'Unable to connect to the library server.',
        code: 'NETWORK_ERROR',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timed out. Please try again.',
        code: 'TIMEOUT',
        statusCode: 408,
      );
    }
  }

  static Future<dynamic> put(
    String url, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'Unable to connect to the library server.',
        code: 'NETWORK_ERROR',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timed out. Please try again.',
        code: 'TIMEOUT',
        statusCode: 408,
      );
    }
  }

  static Future<dynamic> delete(String url, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'Unable to connect to the library server.',
        code: 'NETWORK_ERROR',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timed out. Please try again.',
        code: 'TIMEOUT',
        statusCode: 408,
      );
    }
  }
}
