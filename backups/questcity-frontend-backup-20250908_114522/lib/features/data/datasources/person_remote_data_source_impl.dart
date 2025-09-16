import 'package:los_angeles_quest/utils/logger.dart';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/constants/utils.dart';
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/data/models/notification_model.dart';
import 'package:los_angeles_quest/features/data/models/person_model.dart';
import 'package:los_angeles_quest/features/domain/usecases/user/edit_user.dart';

abstract class PersonRemoteDataSource {
  Future<PersonModel> getMe();
  Future<void> updateMe(EditUserParams person);
  Future<void> deleteMe();
  Future<NotificationModel> getNotifications({int? limit, int? offset});
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  PersonRemoteDataSourceImpl({required this.client, required this.secureStorage});

  @override
  Future<void> deleteMe() async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.post(
      Uri.parse('${baseUrl}users/delete_me'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
    );

    if (response.statusCode != 200) ServerException();
  }

  @override
  Future<PersonModel> getMe() async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.get(
      Uri.parse('${baseUrl}users/me'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
    );

    if (response.statusCode == 200) {
      appLogger.d(response.body);
      final person = json.decode(response.body);
      return PersonModel.fromJson(person);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<NotificationModel> getNotifications({int? limit, int? offset}) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.post(
      Uri.parse('${baseUrl}users/notification'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
    );

    if (response.statusCode == 200) {
      final notifications = json.decode(response.body);
      return NotificationModel.fromJson(notifications);
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> updateMe(EditUserParams person) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final changesMap = {
      'username': person.username,
      'email': person.email,
      'firstName': person.firstName,
      'lastName': person.lastName,
    };

    final response = await client.patch(Uri.parse('${baseUrl}users/me'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
        body: jsonEncode(changesMap.nonNullValues));

    if (response.statusCode != 204) ServerException();
  }
}
