import 'package:los_angeles_quest/utils/logger.dart';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/features/data/models/friend_model.dart';

abstract class FriendsDatasource {
  Future<List<FriendModel>> getFriends(String username);
  Future<List<FriendRequestModel>> getSentRequests();
  Future<List<FriendRequestModel>> getReceivedRequests();
  Future<void> deleteRequest(int requestId);
  Future<void> updateRequest(int requestId, String status);
  Future<void> createRequest(String friendId);
}

class FriendsDatasourceImpl implements FriendsDatasource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  FriendsDatasourceImpl({required this.client, required this.secureStorage});

  @override
  Future<List<FriendModel>> getFriends(String username) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    final response = await client.get(
      Uri.parse('${baseUrl}friends/me?search=$username'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
    );

    final List<FriendModel> friends = [];
    final List<dynamic> friendsJson = jsonDecode(response.body)['items'];
    for (var friend in friendsJson) {
      friends.add(FriendModel.fromJson(friend));
    }
    return friends;
  }

  @override
  Future<List<FriendRequestModel>> getSentRequests() async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    final response = await client.get(
      Uri.parse('${baseUrl}friend-requests/sent/me'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
    );

    final List<FriendRequestModel> requests = [];
    final List<dynamic> requestsJson = jsonDecode(response.body)['items'];
    for (var request in requestsJson) {
      if (request['status'] == 'sended') {
        requests.add(FriendRequestModel.fromJson(request));
      }
    }
    return requests;
  }

  @override
  Future<List<FriendRequestModel>> getReceivedRequests() async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    final response = await client.get(
      Uri.parse('${baseUrl}friend-requests/received/me'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
    );

    final List<FriendRequestModel> requests = [];
    final List<dynamic> requestsJson = jsonDecode(response.body)['items'];
    for (var request in requestsJson) {
      if (request['status'] == 'sended') {
        requests.add(FriendRequestModel.fromJson(request));
      }
    }
    return requests;
  }

  @override
  Future<void> deleteRequest(int requestId) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    await client.delete(
      Uri.parse('${baseUrl}friend-requests/sent/me/$requestId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
    );
  }

  @override
  Future<void> updateRequest(int requestId, String status) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    await client.patch(
      Uri.parse('${baseUrl}friend-requests/received/me/$requestId'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
      body: jsonEncode({'status': status}),
    );
  }

  @override
  Future<void> createRequest(String friendId) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    final response = await client.post(
      Uri.parse('${baseUrl}friend-requests/me/'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $serverToken'},
      body: jsonEncode({'recipientEmail': friendId}),
    );

    appLogger.d(response.statusCode);
  }
}
