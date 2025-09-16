import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:los_angeles_quest/core/error/exception.dart';
import 'package:los_angeles_quest/core/params/register_param.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthRemoteDataSource {
  Future<void> register(RegisterParam param);
  Future<void> getVerificationCode(String email);
  Future<void> verifyCode(String email, String password, String code);
  Future<void> login(String email, String password);
  Future<void> resetPassword(String email);
  Future<void> verifyResetPassword(String email, String password, String code);
  Future<void> refreshToken();
  Future<void> resetPasswordByToken(String token, String password);
  Future<void> unblock(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSourceImpl({required this.client, required this.secureStorage});

  @override
  Future<void> getVerificationCode(String email) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final response = await client.post(
        Uri.parse('${baseUrl}auth/get_registration_code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}));

    switch (response.statusCode) {
      case 200:
        break;
      case 404:
        throw EmailUncorrectedException();
      default:
        throw ServerException();
    }
  }

  @override
  Future<void> login(String email, String password) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    print('🔍 DEBUG: Attempting login with URL: ${baseUrl}auth/login');
    print('🔍 DEBUG: Email: $email');
    print('🔍 DEBUG: Password: ${password.length} characters');

    try {
      final response = await client.post(
        Uri.parse('${baseUrl}auth/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'accept': 'application/json'
        },
        body: {'login': email, 'password': password},
      ).timeout(const Duration(seconds: 30)); // Добавить таймаут

      print('🔍 DEBUG: Response status: ${response.statusCode}');
      print('🔍 DEBUG: Response body: ${response.body}');

      switch (response.statusCode) {
        case 200:
          final persons = json.decode(response.body);
          await secureStorage.write(
              key: SharedPreferencesKeys.accessToken,
              value: persons['accessToken']);
          await secureStorage.write(
              key: SharedPreferencesKeys.refreshToken,
              value: persons['refreshToken']);
          break;
        case 403:
          throw PasswordUncorrectedException();
        case 405:
          throw UserNotVerifyException();
        case 406:
          throw UserNotFoundException();
        default:
          throw ServerException();
      }
    } catch (e) {
      print('🔍 DEBUG: Exception during login: $e');
      rethrow;
    }
  }

  @override
  Future<void> register(RegisterParam param) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final response = await client.post(Uri.parse('${baseUrl}auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': param.email,
          'password1': param.password,
          'username': param.nickname,
          'firstName': param.firstName,
          'lastName': param.lastName,
          'password2': param.password,
        }));

    switch (response.statusCode) {
      case 204:
        break;
      case 409:
        throw EmailAlreadyExistsException();
      case 422:
        throw RegisterValidationException();
      default:
        throw ServerException();
    }
  }

  @override
  Future<void> verifyCode(String email, String password, String code) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final response = await client.post(
        Uri.parse('${baseUrl}auth/register/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}));

    switch (response.statusCode) {
      case 204:
        return;
      case 400:
        throw UncorrectedVerifyCodeException();
      default:
        throw ServerException();
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final response = await client.post(
        Uri.parse('${baseUrl}auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}));

    switch (response.statusCode) {
      case 204:
        break;
      case 404:
        throw UserNotFoundException();
      default:
        throw ServerException();
    }
  }

  @override
  Future<void> verifyResetPassword(
      String email, String password, String code) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';

    final response = await client.post(
        Uri.parse('${baseUrl}auth/reset-password/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}));

    switch (response.statusCode) {
      case 200:
        final token = json.decode(response.body)['token'];
        await resetPasswordByToken(token, password);
      case 404:
        throw UncorrectedVerifyCodeException();
      default:
        throw ServerException();
    }
  }

  @override
  Future<void> resetPasswordByToken(String token, String password) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final response = await client.post(
      Uri.parse('${baseUrl}auth/reset-password/$token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        {'password1': password, 'password2': password},
      ),
    );

    switch (response.statusCode) {
      case 204:
        return;
      case 404:
        throw UncorrectedVerifyCodeException();
      default:
        throw ServerException();
    }
  }

  @override
  Future<void> refreshToken() async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final String? refreshToken =
        await secureStorage.read(key: SharedPreferencesKeys.refreshToken);

    final response =
        await client.post(Uri.parse('${baseUrl}auth/refresh-token'),
            headers: {
              'Content-Type': 'application/json',
              // 'Authorization': 'Bearer $serverToken'
            },
            body: jsonEncode({"refreshToken": refreshToken}));

    switch (response.statusCode) {
      case 200:
        final persons = json.decode(response.body);
        await secureStorage.write(
          key: SharedPreferencesKeys.accessToken,
          value: persons['accessToken'],
        );
        await secureStorage.write(
            key: SharedPreferencesKeys.refreshToken,
            value: persons['refreshToken']);
        break;
      default:
        throw ServerException();
    }
  }

  @override
  Future<void> unblock(String email) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1/';
    final response = await client.post(
      Uri.parse('${baseUrl}unlock_requests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'reason': 'I want to unblock',
        'message': 'I want to unblock'
      }),
    );

    switch (response.statusCode) {
      case 204:
        return;
      case 404:
        throw UncorrectedVerifyCodeException();
      default:
        throw ServerException();
    }
  }
}
