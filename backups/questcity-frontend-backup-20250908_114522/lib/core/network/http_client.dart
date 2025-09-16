import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:los_angeles_quest/utils/logger.dart';

class CustomHttpClient {
  final client = HttpClient();

  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

  Future<HttpClientResponse> postWithRetry(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
    Map<String, String>? formData,
  }) async {
    return await _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = await client.postUrl(uri);

      // Headers
      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Body
      if (body != null) {
        request.write(body);
      } else if (formData != null) {
        final formBody = formData.entries
            .map((entry) =>
                '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
            .join('&');
        request.headers
            .set('Content-Type', 'application/x-www-form-urlencoded');
        request.write(formBody);
      }

      return await request.close().timeout(_timeout);
    });
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        appLogger.d('HTTP attempt $attempt/$_maxRetries');
        return await operation();
      } on TimeoutException catch (e) {
        lastException = e;
        appLogger.w('HTTP timeout on attempt $attempt');
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      } on SocketException catch (e) {
        lastException = e;
        appLogger.w('HTTP socket error on attempt $attempt: ${e.message}');
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    throw lastException!;
  }

  void dispose() {
    client.close();
  }
}
