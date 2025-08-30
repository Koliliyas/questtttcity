import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/unlock_requests.dart';
import 'package:http/http.dart' as http;

class UnlockRequestsDatasource {
  final FlutterSecureStorage secureStorage;
  final http.Client client;

  UnlockRequestsDatasource({required this.secureStorage, required this.client});

  Future<List<UnlockRequest>> getUnlockRequests() async {
    try {
      String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

      final String? serverToken =
          await secureStorage.read(key: SharedPreferencesKeys.accessToken);

      final response = await client.get(
        Uri.parse('${baseUrl}unlock_requests?order_by=email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseJson = json.decode(response.body)['items'];
        return responseJson
            .map((unlockRequest) => UnlockRequest.fromJson(unlockRequest))
            .toList();
      } else {
        // Возвращаем пустой список вместо исключения
        return [];
      }
    } catch (e) {
      // Возвращаем пустой список при любой ошибке
      return [];
    }
  }

  Future<bool> updateRequest(String id, String status) async {
    try {
      String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
      final String? serverToken =
          await secureStorage.read(key: SharedPreferencesKeys.accessToken);

      final response = await client.patch(
        Uri.parse('${baseUrl}unlock_requests/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
