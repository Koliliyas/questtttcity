import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';

class QuestDetailRemoteDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getQuestDetail(int questId) async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      String baseUrl =
          (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
              .replaceAll(RegExp(r'/$'), '');

      // Получаем токен авторизации
      final token =
          await _secureStorage.read(key: SharedPreferencesKeys.accessToken);

      final response = await http.get(
        Uri.parse('$baseUrl/quests/user/$questId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load quest details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
