import 'package:los_angeles_quest/utils/logger.dart';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getAll();
  Future<void> update(CategoryModel category);
  Future<void> create(CategoryModel category);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  CategoryRemoteDataSourceImpl(
      {required this.client, required this.secureStorage});

  @override
  Future<List<CategoryModel>> getAll() async {
    try {
      String baseUrl =
          dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
      final String? serverToken =
          await secureStorage.read(key: SharedPreferencesKeys.accessToken);

      print('🔍 DEBUG: Fetching categories from: ${baseUrl}quests/categories/');
      print('🔍 DEBUG: Token available: ${serverToken != null ? 'Yes' : 'No'}');

      final response = await client.get(
        Uri.parse('${baseUrl}quests/categories/'),
        headers: {
          'Content-Type': 'application/json',
          if (serverToken != null) 'Authorization': 'Bearer $serverToken'
        },
      );

      print('🔍 DEBUG: Categories response status: ${response.statusCode}');
      print('🔍 DEBUG: Categories response body: ${response.body}');

      if (response.statusCode < 300) {
        final List<dynamic> responseJson = json.decode(response.body);
        final categories = responseJson
            .map((categories) => CategoryModel.fromJson(categories))
            .toList();
        print('🔍 DEBUG: Categories parsed successfully: ${categories.length}');
        return categories;
      } else {
        print(
            '🔍 DEBUG: Categories API error: ${response.statusCode} - ${response.body}');
        throw ServerException();
      }
    } catch (e) {
      print('🔍 DEBUG: Categories exception: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  @override
  Future<void> create(CategoryModel category) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.post(
      Uri.parse('${baseUrl}quests/categories/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverToken'
      },
      body: json.encode(
        Utils.getNotNullFields(
          category.toJson(),
        ),
      ),
    );
    appLogger.d(category.image);
    if (response.statusCode != 204) {
      throw ServerException();
    }
  }

  @override
  Future<void> update(CategoryModel category) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.put(
      Uri.parse('${baseUrl}admins/category/${category.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverToken'
      },
      body: json.encode(
        Utils.getNotNullFields(
          category.toJson(),
        ),
      ),
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }
  }
}
