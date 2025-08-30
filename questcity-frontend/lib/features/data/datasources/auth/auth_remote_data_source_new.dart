import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:los_angeles_quest/features/data/models/auth/login_request_model.dart';
import 'package:los_angeles_quest/features/data/models/auth/register_request_model.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';

import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/network/http_client.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/utils/logger.dart';

abstract class AuthRemoteDataSourceNew {
  /// POST /api/v1/auth/login
  Future<Either<Failure, TokenResponseModel>> login(LoginRequestModel request);

  /// POST /api/v1/auth/register
  Future<Either<Failure, void>> register(RegisterRequestModel request);

  /// POST /api/v1/auth/refresh-token
  Future<Either<Failure, TokenResponseModel>> refreshToken(String refreshToken);

  // Добавить остальные методы...
}

class AuthRemoteDataSourceNewImpl implements AuthRemoteDataSourceNew {
  final CustomHttpClient httpClient;
  final NetworkInfo networkInfo;

  AuthRemoteDataSourceNewImpl({
    required this.httpClient,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TokenResponseModel>> login(
      LoginRequestModel request) async {
    if (!(await networkInfo.isConnected)) {
      appLogger.e('No internet connection for login');
      return Left(ConnectionFailure());
    }

    try {
      appLogger.d('Starting login for: ${request.login}');

      final response = await httpClient.postWithRetry(
        'auth/login',
        formData: {
          'login': request.login,
          'password': request.password,
        },
      );

      final responseBody = await response.transform(utf8.decoder).join();
      appLogger.d('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);
        final tokenResponse = TokenResponseModel.fromJson(jsonData);
        appLogger.i('Login successful for: ${request.login}');
        return Right(tokenResponse);
      } else {
        appLogger.e('Login failed with status: ${response.statusCode}');
        return Left(_handleHttpError(response.statusCode, responseBody));
      }
    } on TimeoutException {
      appLogger.e('Login timeout');
      return Left(TimeoutFailure());
    } on SocketException catch (e) {
      appLogger.e('Login socket error: ${e.message}');
      return Left(ConnectionFailure());
    } catch (e) {
      appLogger.e('Login unexpected error: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> register(RegisterRequestModel request) async {
    if (!(await networkInfo.isConnected)) {
      return Left(ConnectionFailure());
    }

    try {
      appLogger.d('Starting registration for: ${request.email}');

      final response = await httpClient.postWithRetry(
        'auth/register',
        body: json.encode(request.toJson()),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      appLogger.d('Register response status: ${response.statusCode}');

      if (response.statusCode == 204) {
        appLogger.i('Registration successful for: ${request.email}');
        return Right(null);
      } else {
        appLogger.e('Registration failed with status: ${response.statusCode}');
        return Left(_handleHttpError(response.statusCode, responseBody));
      }
    } on TimeoutException {
      appLogger.e('Registration timeout');
      return Left(TimeoutFailure());
    } on SocketException catch (e) {
      appLogger.e('Registration socket error: ${e.message}');
      return Left(ConnectionFailure());
    } catch (e) {
      appLogger.e('Registration unexpected error: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TokenResponseModel>> refreshToken(
      String refreshToken) async {
    if (!(await networkInfo.isConnected)) {
      appLogger.e('No internet connection for token refresh');
      return Left(ConnectionFailure());
    }

    try {
      appLogger.d('Starting token refresh');

      final response = await httpClient.postWithRetry(
        'auth/refresh-token',
        body: json.encode({'refresh_token': refreshToken}),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      appLogger.d('Refresh token response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);
        final tokenResponse = TokenResponseModel.fromJson(jsonData);
        appLogger.i('Token refresh successful');
        return Right(tokenResponse);
      } else {
        appLogger.e('Token refresh failed with status: ${response.statusCode}');
        return Left(_handleHttpError(response.statusCode, responseBody));
      }
    } on TimeoutException {
      appLogger.e('Token refresh timeout');
      return Left(TimeoutFailure());
    } on SocketException catch (e) {
      appLogger.e('Token refresh socket error: ${e.message}');
      return Left(ConnectionFailure());
    } catch (e) {
      appLogger.e('Token refresh unexpected error: $e');
      return Left(ServerFailure());
    }
  }

  Failure _handleHttpError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        return ValidationFailure();
      case 401:
        return UnauthorizedFailure();
      case 403:
        return PasswordUncorrectedFailure();
      case 404:
        return NotFoundFailure();
      case 405:
        return UserNotVerifyFailure();
      case 406:
        return UserNotFoundFailure();
      case 409:
        return EmailAlreadyExistsFailure();
      case 422:
        return ValidationFailure();
      case 500:
        return ServerFailure();
      default:
        appLogger.e('Unhandled HTTP error: $statusCode - $responseBody');
        return ServerFailure();
    }
  }
}
