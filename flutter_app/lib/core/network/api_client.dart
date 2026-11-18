import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Thin wrapper around `package:http` so every feature talks to the
/// backend the same way, with consistent timeouts and error mapping.
///
/// Rule 4 compliance: this client only ever calls [AppConstants.backendBaseUrl].
/// No third-party AI API key ever lives in this app.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse("${AppConstants.backendBaseUrl}$endpoint");
    try {
      final response = await _client
          .post(
            uri,
            headers: const {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: AppConstants.requestTimeoutSeconds));

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(
        "Cannot reach the server. Check your internet connection and "
        "make sure the backend is running.",
      );
    } on HttpException {
      throw const ApiException("A network error occurred. Please try again.");
    } on FormatException {
      throw const ApiException("Received an invalid response from the server.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException("Something went wrong. Please try again.");
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final Map<String, dynamic> decoded = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : {};

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    final message = decoded["error"]?.toString() ??
        decoded["message"]?.toString() ??
        "Request failed with status $statusCode.";

    switch (statusCode) {
      case 400:
        throw ApiException("Invalid request: $message");
      case 401:
      case 403:
        throw ApiException("Not authorized: $message");
      case 429:
        throw const ApiException(
            "Too many requests. Please wait a moment and try again.");
      case 500:
      default:
        throw ApiException(message);
    }
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
