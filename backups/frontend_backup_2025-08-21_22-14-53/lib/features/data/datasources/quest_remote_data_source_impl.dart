import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/data/models/quest_parameter_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/current_quest_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_create_model.dart';
import 'package:los_angeles_quest/features/data/models/quests/quest_update_model.dart';
import 'package:los_angeles_quest/features/domain/entities/quest_parameter_entity.dart';

import '../models/quests/quest_list_model.dart' as quest_list;
import '../models/quests/quest_model.dart' as quest_model;

abstract class QuestRemoteDataSource {
  Future<List<QuestParameterEntity>> getLevels();
  Future<List<QuestParameterEntity>> getPlaces();
  Future<List<QuestParameterEntity>> getMiles();
  Future<List<QuestParameterEntity>> getVehicles();
  Future<List<QuestParameterEntity>> getPrices();
  Future<QuestParameterModel> create(QuestCreateModel quest);
  Future<QuestParameterModel> update(int id, QuestUpdateModel quest);
  Future<void> delete(int id);
  Future<quest_list.QuestListModel> getAll();
  Future<quest_model.QuestModel> getOne(int id);
  Future<CurrentQuestModel> getCurrentQuest(int id);
  Future<List<Map<String, dynamic>>> getAllQuests();
  Future<List<Map<String, dynamic>>> getAllQuestsForUsers();
  Future<Map<String, dynamic>> createQuest(Map<String, dynamic> questData);
  Future<Map<String, dynamic>> updateQuest(
      int questId, Map<String, dynamic> questData);
  Future<Map<String, dynamic>> getQuest(int questId);
  Future<void> deleteQuest(int questId);
  Future<Map<String, dynamic>> getQuestAnalytics();
  Future<Map<String, dynamic>> bulkActionQuests(
      String action, List<int> questIds);
}

class QuestRemoteDataSourceImpl implements QuestRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  QuestRemoteDataSourceImpl(
      {required this.client, required this.secureStorage});

  @override
  Future<QuestParameterModel> create(QuestCreateModel quest) async {
    // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
    String baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
        .replaceAll(RegExp(r'/$'), '');

    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    // Детальное логирование токена для отладки
    print('🔍 DEBUG: QuestRemoteDataSource.create() - Token Analysis:');
    print('  - Token key: ${SharedPreferencesKeys.accessToken}');
    print('  - Token value: ${serverToken ?? "NULL"}');
    print('  - Token length: ${serverToken?.length ?? 0}');
    if (serverToken != null && serverToken.isNotEmpty) {
      print(
          '  - Token starts with: ${serverToken.substring(0, serverToken.length > 20 ? 20 : serverToken.length)}...');
    } else {
      print('  - Token starts with: N/A');
    }

    // Проверяем наличие токена
    if (serverToken == null || serverToken.isEmpty) {
      print('❌ ERROR: Access token is missing or empty');
      throw UnauthorizedException(
          'Access token is required for quest creation');
    }

    // Логируем данные для отладки
    final questJson = quest.toJson();
    final cleanedJson = Utils.getQuestFields(questJson);

    // Исправляем кодировку русского текста перед отправкой
    final fixedJson = Utils.fixJsonEncoding(cleanedJson);

    print('🔍 DEBUG: QuestRemoteDataSource.create() - Request Data:');
    print('  - Original JSON: ${jsonEncode(questJson)}');
    print('  - Cleaned JSON: ${jsonEncode(cleanedJson)}');
    print('  - Fixed JSON: ${jsonEncode(fixedJson)}');
    print('  - Server URL: ${baseUrl}quests/');
    print('  - Token: Present (${serverToken.length} chars)');
    print(
        '  - Authorization Header: Bearer ${serverToken.substring(0, serverToken.length > 20 ? 20 : serverToken.length)}...');

    final response = await client.post(Uri.parse('${baseUrl}quests/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
        body: jsonEncode(fixedJson));

    print('🔍 DEBUG: Response Analysis:');
    print('  - Status Code: ${response.statusCode}');
    print('  - Response Headers: ${response.headers}');
    print('  - Response Body: ${response.body}');

    if (response.statusCode != 201) {
      print('🔍 DEBUG: Server error - Status: ${response.statusCode}');
      print('🔍 DEBUG: Server error - Body: ${response.body}');

      // Пытаемся получить детальную информацию об ошибке
      try {
        final errorData = json.decode(response.body);
        print('🔍 DEBUG: Parsed error data: $errorData');

        // Извлекаем сообщение об ошибке
        String errorMessage = 'Unknown error';
        if (errorData is Map<String, dynamic>) {
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'].toString();
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'].toString();
          }
        }

        // Исправляем кодировку если нужно
        errorMessage = Utils.fixRussianEncoding(errorMessage);

        print('🔍 DEBUG: Server error ${response.statusCode}: $errorMessage');
        throw ServerException();
      } catch (e) {
        // Если не удалось распарсить JSON, бросаем общее исключение
        final rawBody = response.body;
        final fixedBody = Utils.fixRussianEncoding(rawBody);
        print('🔍 DEBUG: Server error ${response.statusCode}: $fixedBody');
        throw ServerException();
      }
    }

    return QuestParameterModel.fromJson(json.decode(response.body));
  }

  @override
  Future<quest_list.QuestListModel> getAll() async {
    // Временно возвращаем тестовые данные
    return const quest_list.QuestListModel(items: [
      quest_list.QuestItem(
        id: 1,
        name: 'Hollywood Hills',
        image:
            'https://www.lamag.com/wp-content/uploads/sites/9/2019/07/hollywood-sign-istock-1062460004.jpg',
        mainPreferences: quest_list.MainPreferences(
            categoryId: 1,
            group: 1,
            vehicleId: 2,
            price: quest_list.Price(amount: 100, isSubscription: false),
            timeframe: 120,
            level: 'beginner',
            milege: 'local',
            placeId: 5),
        rating: 4.5,
      ),
      quest_list.QuestItem(
        id: 2,
        name: 'Santa Monica Pier',
        image:
            'https://www.visitcalifornia.com/sites/default/files/styles/welcome_image/public/vc_spotlight_santamonicapier_module1_santamonicapier_rf_623930488_1280x640.jpg',
        mainPreferences: quest_list.MainPreferences(
            categoryId: 2,
            group: 2,
            vehicleId: 1,
            price: quest_list.Price(amount: 50, isSubscription: false),
            timeframe: 240,
            level: 'intermediate',
            milege: 'local',
            placeId: 2),
        rating: 4.8,
      ),
    ]);
  }

  @override
  Future<quest_model.QuestModel> getOne(int id) async {
    // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
    String baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
        .replaceAll(RegExp(r'/$'), '');

    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.get(
      Uri.parse('$baseUrl/quests/get-quest/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverToken'
      },
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return quest_model.QuestModel.fromJson(responseJson);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<QuestParameterModel> update(int id, QuestUpdateModel quest) async {
    // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
    String baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
        .replaceAll(RegExp(r'/$'), '');

    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.patch(Uri.parse('$baseUrl/quests/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
        body: jsonEncode(Utils.getNotNullFields(quest.toJson())));

    if (response.statusCode != 200) throw ServerException();

    return QuestParameterModel.fromJson(json.decode(response.body));
  }

  @override
  Future<CurrentQuestModel> getCurrentQuest(int id) async {
    // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
    String baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
        .replaceAll(RegExp(r'/$'), '');

    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.get(
      Uri.parse('$baseUrl/quests/me/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverToken'
      },
    );

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return CurrentQuestModel.fromJson(responseJson);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> delete(int id) async {
    // TODO: Implement real API call
    throw UnimplementedError('Delete quest not implemented yet');
  }

  @override
  Future<Map<String, dynamic>> getQuest(int questId) async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      final baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
          .replaceAll(RegExp(r'/$'), '');

      print('🔍 DEBUG: getQuest() - Starting request...');
      print('🔍 DEBUG: getQuest() - questId: $questId');
      print('🔍 DEBUG: getQuest() - BASE_URL: ${dotenv.env['BASE_URL']}');
      print('🔍 DEBUG: getQuest() - Cleaned baseUrl: $baseUrl');
      print('🔍 DEBUG: getQuest() - Final URL: $baseUrl/quests/admin/$questId');

      final response = await client.get(
        Uri.parse('$baseUrl/quests/admin/$questId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await secureStorage.read(key: SharedPreferencesKeys.accessToken)}'
        },
      );

      print('🔍 DEBUG: getQuest() - Response status: ${response.statusCode}');
      print('🔍 DEBUG: getQuest() - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 DEBUG: getQuest() - Success! Data keys: ${data.keys}');
        return data;
      } else {
        print('🔍 DEBUG: getQuest() - Error: HTTP ${response.statusCode}');
        throw ServerException('Failed to get quest: ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 DEBUG: getQuest() - Exception caught: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllQuests() async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      final baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
          .replaceAll(RegExp(r'/$'), '');
      final url = '$baseUrl/quests/admin/list';
      final token =
          await secureStorage.read(key: SharedPreferencesKeys.accessToken);

      print('🔍 DEBUG: getAllQuests() - Starting request...');
      print('🔍 DEBUG: getAllQuests() - URL: $url');
      print(
          '🔍 DEBUG: getAllQuests() - Token: ${token != null ? "Present (${token.length} chars)" : "NULL"}');
      if (token != null) {
        print(
            '🔍 DEBUG: getAllQuests() - Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      }

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print('🔍 DEBUG: getAllQuests() - Response received');
      print(
          '🔍 DEBUG: getAllQuests() - Response status: ${response.statusCode}');
      print('🔍 DEBUG: getAllQuests() - Response headers: ${response.headers}');
      print('🔍 DEBUG: getAllQuests() - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
            '🔍 DEBUG: getAllQuests() - Parsed data type: ${data.runtimeType}');
        print('🔍 DEBUG: getAllQuests() - Parsed data: $data');

        // Бэкенд возвращает список квестов напрямую для админского эндпоинта
        if (data is List) {
          print(
              '🔍 DEBUG: getAllQuests() - Success! Returning ${data.length} quests');
          return List<Map<String, dynamic>>.from(data);
        } else {
          print('🔍 DEBUG: getAllQuests() - Error: Invalid response format');
          throw ServerException(
              'Invalid response format from server: expected List, got ${data.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        print('🔍 DEBUG: getAllQuests() - Error: Unauthorized (401)');
        throw UnauthorizedException('Unauthorized access to quests');
      } else if (response.statusCode == 403) {
        print('🔍 DEBUG: getAllQuests() - Error: Forbidden (403)');
        throw UnauthorizedException(
            'Access forbidden - insufficient permissions');
      } else {
        print('🔍 DEBUG: getAllQuests() - Error: HTTP ${response.statusCode}');
        throw ServerException(
            'Failed to get quests: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔍 DEBUG: getAllQuests() - Exception caught: $e');
      print('🔍 DEBUG: getAllQuests() - Exception type: ${e.runtimeType}');
      if (e is ServerException) rethrow;
      if (e is UnauthorizedException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllQuestsForUsers() async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      final baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
          .replaceAll(RegExp(r'/$'), '');
      final url = '$baseUrl/quests/'; // ✅ Используем клиентский эндпоинт!
      final token =
          await secureStorage.read(key: SharedPreferencesKeys.accessToken);

      print('🔍 DEBUG: getAllQuestsForUsers() - Starting request...');
      print('🔍 DEBUG: getAllQuestsForUsers() - URL: $url');
      print(
          '🔍 DEBUG: getAllQuestsForUsers() - Token: ${token != null ? "Present (${token.length} chars)" : "NULL"}');
      if (token != null) {
        print(
            '🔍 DEBUG: getAllQuestsForUsers() - Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      }

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      print('🔍 DEBUG: getAllQuestsForUsers() - Response received');
      print(
          '🔍 DEBUG: getAllQuestsForUsers() - Response status: ${response.statusCode}');
      print(
          '🔍 DEBUG: getAllQuestsForUsers() - Response headers: ${response.headers}');
      print(
          '🔍 DEBUG: getAllQuestsForUsers() - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
            '🔍 DEBUG: getAllQuestsForUsers() - Parsed data type: ${data.runtimeType}');
        print('🔍 DEBUG: getAllQuestsForUsers() - Parsed data: $data');

        // Бэкенд возвращает список квестов напрямую для клиентского эндпоинта
        if (data is List) {
          print(
              '🔍 DEBUG: getAllQuestsForUsers() - Success! Returning ${data.length} quests');
          return List<Map<String, dynamic>>.from(data);
        } else {
          print(
              '🔍 DEBUG: getAllQuestsForUsers() - Error: Invalid response format');
          throw ServerException(
              'Invalid response format from server: expected List, got ${data.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        print('🔍 DEBUG: getAllQuestsForUsers() - Error: Unauthorized (401)');
        throw UnauthorizedException('Unauthorized access to quests');
      } else if (response.statusCode == 403) {
        print('🔍 DEBUG: getAllQuestsForUsers() - Error: Forbidden (403)');
        throw UnauthorizedException(
            'Access forbidden - insufficient permissions');
      } else {
        print(
            '🔍 DEBUG: getAllQuestsForUsers() - Error: HTTP ${response.statusCode}');
        throw ServerException(
            'Failed to get quests: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔍 DEBUG: getAllQuestsForUsers() - Exception caught: $e');
      print(
          '🔍 DEBUG: getAllQuestsForUsers() - Exception type: ${e.runtimeType}');
      if (e is ServerException) rethrow;
      if (e is UnauthorizedException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createQuest(
      Map<String, dynamic> questData) async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      final baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
          .replaceAll(RegExp(r'/$'), '');

      // Логируем данные перед отправкой
      print('🔍 DEBUG: createQuest() - Отправляем данные:');
      print('  - URL: $baseUrl/quests/admin/create');
      print('  - Data: ${json.encode(questData)}');
      print('  - Data type: ${questData.runtimeType}');

      // Получаем токен
      final token =
          await secureStorage.read(key: SharedPreferencesKeys.accessToken);
      print(
          '  - Token: ${token != null ? "Present (${token.length} chars)" : "NULL"}');

      final response = await client.post(
        Uri.parse('$baseUrl/quests/admin/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(questData),
      );

      print(
          '🔍 DEBUG: createQuest() - Response status: ${response.statusCode}');
      print('🔍 DEBUG: createQuest() - Response headers: ${response.headers}');
      print('🔍 DEBUG: createQuest() - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print(
            '🔍 DEBUG: createQuest() - Error response: ${response.statusCode} - ${response.body}');
        throw ServerException(
            'Failed to create quest: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateQuest(
      int questId, Map<String, dynamic> questData) async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      final baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
          .replaceAll(RegExp(r'/$'), '');
      final response = await client.patch(
        Uri.parse('$baseUrl/quests/$questId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await secureStorage.read(key: SharedPreferencesKeys.accessToken)}'
        },
        body: json.encode(questData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        // Логируем детали ошибки
        print('🔍 DEBUG: updateQuest HTTP ${response.statusCode}');
        print('🔍 DEBUG: Response body: ${response.body}');
        throw ServerException(
            'Failed to update quest: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<void> deleteQuest(int questId) async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      final baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
          .replaceAll(RegExp(r'/$'), '');
      final response = await client.delete(
        Uri.parse('$baseUrl/quests/admin/delete/$questId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await secureStorage.read(key: SharedPreferencesKeys.accessToken)}'
        },
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to delete quest: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  // Новые методы для админской панели согласно ТЗ
  Future<Map<String, dynamic>> getQuestAnalytics() async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      final baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
          .replaceAll(RegExp(r'/$'), '');
      final response = await client.get(
        Uri.parse('$baseUrl/quests/admin/analytics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await secureStorage.read(key: SharedPreferencesKeys.accessToken)}'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw ServerException(
            'Failed to get analytics: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> bulkActionQuests(
      String action, List<int> questIds) async {
    try {
      // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
      final baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
          .replaceAll(RegExp(r'/$'), '');
      final response = await client.post(
        Uri.parse('$baseUrl/quests/admin/bulk-action'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${await secureStorage.read(key: SharedPreferencesKeys.accessToken)}'
        },
        body: json.encode({
          'action': action,
          'quest_ids': questIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw ServerException(
            'Failed to perform bulk action: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  @override
  Future<List<QuestParameterEntity>> getLevels() async =>
      await _getQuestParameter(query: 'quests/types', key: 'levels');

  @override
  Future<List<QuestParameterEntity>> getMiles() async =>
      await _getQuestParameter(query: 'quests/types', key: 'miles');

  @override
  Future<List<QuestParameterEntity>> getPlaces() async =>
      await _getQuestParameter(query: 'quests/places', key: 'places');

  @override
  Future<List<QuestParameterEntity>> getPrices() async =>
      await _getQuestParameter(query: 'quests/types', key: 'prices');

  @override
  Future<List<QuestParameterEntity>> getVehicles() async =>
      await _getQuestParameter(query: 'quests/vehicles', key: 'vehicles');

  Future<List<QuestParameterEntity>> _getQuestParameter(
      {required String query, required String key}) async {
    // Убираем trailing slash из BASE_URL чтобы избежать двойного слэша
    String baseUrl = (dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1')
        .replaceAll(RegExp(r'/$'), '');

    print(
        '🔍 DEBUG: QuestRemoteDataSource._getQuestParameter() - Загружаем $key');
    print(
        '🔍 DEBUG: QuestRemoteDataSource._getQuestParameter() - BASE_URL: ${dotenv.env['BASE_URL']}');
    print(
        '🔍 DEBUG: QuestRemoteDataSource._getQuestParameter() - Cleaned baseUrl: $baseUrl');
    print(
        '🔍 DEBUG: QuestRemoteDataSource._getQuestParameter() - Final URL: $baseUrl/$query');

    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    if (serverToken == null || serverToken.isEmpty) {
      print(
          '❌ ERROR: QuestRemoteDataSource._getQuestParameter() - Токен отсутствует для $key');
      throw UnauthorizedException('Access token is required for $key');
    }

    print(
        '🔍 DEBUG: QuestRemoteDataSource._getQuestParameter() - Токен присутствует для $key');

    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken'
        },
      );

      print(
          '🔍 DEBUG: QuestRemoteDataSource._getQuestParameter() - $key - Status: ${response.statusCode}');
      print(
          '🔍 DEBUG: QuestRemoteDataSource._getQuestParameter() - $key - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseJson = json.decode(response.body);
        final result = responseJson
            .map((parameter) => QuestParameterModel.fromJson(parameter))
            .toList();

        print(
            '✅ DEBUG: QuestRemoteDataSource._getQuestParameter() - $key успешно загружен: ${result.length} элементов');
        return result;
      } else {
        print(
            '❌ ERROR: QuestRemoteDataSource._getQuestParameter() - $key - HTTP ${response.statusCode}: ${response.body}');
        throw ServerException();
      }
    } catch (e) {
      print(
          '❌ ERROR: QuestRemoteDataSource._getQuestParameter() - $key - Исключение: $e');
      print(
          '❌ ERROR: QuestRemoteDataSource._getQuestParameter() - $key - Тип: ${e.runtimeType}');
      rethrow;
    }
  }
}
