import 'package:los_angeles_quest/utils/logger.dart';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/data/models/user_model.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/create_user.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';


abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAll({
    String? search,
    bool banned = false,
    int page = 1,
    int size = 50,
  });
  Future<void> ban(String id);
  Future<void> edit(EditUserParams params);
  Future<void> createUser(CreateUserParams params);
  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  UserRemoteDataSourceImpl({required this.client, required this.secureStorage});

  @override
  Future<List<UserModel>> getAll({
    String? search,
    bool banned = false,
    int page = 1,
    int size = 50,
  }) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.get(
      Uri.parse(
          '${baseUrl}users?page=$page&size=$size&is_banned=$banned${search != null ? "&search=$search" : ""}'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseJson = json.decode(response.body)['items'];
      return responseJson.map((user) => UserModel.fromJson(user)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> ban(String id) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.post(
      Uri.parse('${baseUrl}users/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
      body: json.encode({
        'isActive': false,
      }),
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }
  }

  @override
  Future<void> edit(EditUserParams user) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    final changesMap = {
      'email': user.email,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'password1': user.password,
      'password2': user.password,
      'username': user.username,
    };

    if ((user.instagram != null && user.instagram!.isNotEmpty) || user.image != null) {
      final profileResponse = await client.patch(
        Uri.parse('${baseUrl}profiles/${user.profileId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken',
        },
        body: json.encode({
          'instagramUsername': user.instagram,
          'image': user.image,
        }),
      );

      appLogger.d(profileResponse.statusCode);
    }
    if (changesMap.values.every((element) => element == null)) {
      return;
    }
    final response = await client.patch(
      Uri.parse('${baseUrl}users/${user.id}'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
      body: json.encode(changesMap.nonNullValues),
    );

    if (response.statusCode != 204) {
      throw ServerException();
    }
  }

  @override
  Future<void> createUser(CreateUserParams params) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.post(
      Uri.parse('${baseUrl}users'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
      body: json.encode({
        'password2': params.password,
        'password1': params.password,
        'email': params.email,
        'firstName': params.firstName,
        'lastName': params.lastName,
        'role': params.role,
        'username': params.username,
        'isActive': true,
        'isVerified': false,
        'instagram': params.instagram,
        'image': params.image,
      }),
    );

    if (response.statusCode != 204) {
      throw ServerException();
    }
  }

  @override
  Future<void> changePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.post(
      Uri.parse('${baseUrl}users/me/change-password'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
      body: json.encode({
        'oldPassword': oldPassword,
        'password1': newPassword,
        'password2': confirmPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw ServerException();
    }
  }
}
