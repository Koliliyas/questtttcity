import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';

abstract class FileRemoteDataSource {
  Future<String> upload(File file);
  Future<String> get(String file);
}

class FileRemoteDataSourceImpl implements FileRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  FileRemoteDataSourceImpl({required this.client, required this.secureStorage});

  @override
  Future<String> get(String file) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.get(
      Uri.parse('${baseUrl}files/$file'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverToken'
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<String> upload(File file) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    // Создаем multipart request
    var request = http.MultipartRequest(
      'POST', // Или 'PUT' в зависимости от API
      Uri.parse('${baseUrl}files/upload_files'),
    );

    // Добавляем токен авторизации
    request.headers['Authorization'] = 'Bearer $serverToken';

    // Добавляем файл в запрос
    request.files.add(
      await http.MultipartFile.fromPath(
        'files', // Имя параметра, ожидаемое сервером
        file.path,
      ),
    );

    // Выполняем запрос и получаем ответ
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // Обрабатываем ответ
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final List<String> filePaths =
          List<String>.from(decodedResponse['files_path']);

      // Возвращаем первый путь к файлу
      return filePaths.isNotEmpty ? filePaths.first : '';
    } else {
      throw ServerException();
    }
  }
}
