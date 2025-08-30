import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/data/models/chat_model.dart' as ce;
import 'package:los_angeles_quest/features/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ce.ChatModel>> getAll();
  Future<List<MessageModel>> getMessages(
      {required int chatId, int? limit, int? offset});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  ChatRemoteDataSourceImpl({required this.client, required this.secureStorage});

  @override
  Future<List<ce.ChatModel>> getAll() async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.get(
      Uri.parse('${baseUrl}chats/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverToken'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseJson = json.decode(response.body);
      return responseJson.map((chat) => ce.ChatModel.fromJson(chat)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MessageModel>> getMessages(
      {required int chatId, int? limit, int? offset}) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);

    final response = await client.post(
      Uri.parse('${baseUrl}chats/get_messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverToken'
      },
      body: json.encode(
        {
          'id_chat': chatId,
          'offset': offset,
          'limit': limit,
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseJson = json.decode(response.body)['messages'];
      return responseJson
          .map((message) => MessageModel.fromJson(message))
          .toList();
    } else {
      throw ServerException();
    }
  }
}
