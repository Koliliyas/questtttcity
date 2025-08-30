import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/utils/logger.dart';

import '../../domain/repositories/auth_repository_new.dart';
import '../datasources/auth/auth_remote_data_source_new.dart';
import '../models/auth/token_response_model.dart';
import '../models/auth/login_request_model.dart';
import '../models/auth/register_request_model.dart';

class AuthRepositoryNewImpl implements AuthRepositoryNew {
  final AuthRemoteDataSourceNew remoteDataSource;
  final FlutterSecureStorage secureStorage;

  const AuthRepositoryNewImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, TokenResponseModel>> login(
      String email, String password) async {
    appLogger.d('Repository: Starting login for $email');

    final request = LoginRequestModel(login: email, password: password);
    final result = await remoteDataSource.login(request);

    return result.fold(
      (failure) {
        appLogger.e('Repository: Login failed with $failure');
        return Left(failure);
      },
      (tokens) async {
        appLogger.i('Repository: Login successful, saving tokens');
        await _saveTokensToStorage(tokens);
        return Right(tokens);
      },
    );
  }

  @override
  Future<Either<Failure, void>> register(RegisterRequestModel request) async {
    appLogger.d('Repository: Starting registration for ${request.email}');
    return await remoteDataSource.register(request);
  }

  @override
  Future<Either<Failure, TokenResponseModel>> refreshTokens() async {
    appLogger.d('Repository: Refreshing tokens');

    final refreshToken =
        await secureStorage.read(key: SharedPreferencesKeys.refreshToken);
    if (refreshToken == null) {
      appLogger.e('Repository: No refresh token found');
      return Left(UnauthorizedFailure());
    }

    final result = await remoteDataSource.refreshToken(refreshToken);

    return result.fold(
      (failure) {
        appLogger.e('Repository: Token refresh failed with $failure');
        return Left(failure);
      },
      (tokens) async {
        appLogger.i('Repository: Tokens refreshed successfully');
        await _saveTokensToStorage(tokens);
        return Right(tokens);
      },
    );
  }

  @override
  Future<Either<Failure, String?>> getAccessToken() async {
    try {
      final token =
          await secureStorage.read(key: SharedPreferencesKeys.accessToken);
      return Right(token);
    } catch (e) {
      appLogger.e('Repository: Error reading access token: $e');
      return Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getRefreshToken() async {
    try {
      final token =
          await secureStorage.read(key: SharedPreferencesKeys.refreshToken);
      return Right(token);
    } catch (e) {
      appLogger.e('Repository: Error reading refresh token: $e');
      return Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveTokens(TokenResponseModel tokens) async {
    try {
      await _saveTokensToStorage(tokens);
      return Right(null);
    } catch (e) {
      appLogger.e('Repository: Error saving tokens: $e');
      return Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    try {
      await secureStorage.delete(key: SharedPreferencesKeys.accessToken);
      await secureStorage.delete(key: SharedPreferencesKeys.refreshToken);
      appLogger.i('Repository: Tokens cleared');
      return Right(null);
    } catch (e) {
      appLogger.e('Repository: Error clearing tokens: $e');
      return Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    appLogger.d('Repository: Logging out');
    return await clearTokens();
  }

  @override
  Future<bool> get isLoggedIn async {
    final accessToken =
        await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    final refreshToken =
        await secureStorage.read(key: SharedPreferencesKeys.refreshToken);
    return accessToken != null && refreshToken != null;
  }

  @override
  Future<bool> get hasValidTokens async {
    // TODO: Добавить проверку срока действия токенов
    return await isLoggedIn;
  }

  Future<void> _saveTokensToStorage(TokenResponseModel tokens) async {
    await secureStorage.write(
      key: SharedPreferencesKeys.accessToken,
      value: tokens.accessToken,
    );
    await secureStorage.write(
      key: SharedPreferencesKeys.refreshToken,
      value: tokens.refreshToken,
    );
    appLogger.d('Repository: Tokens saved to storage');
  }

  // Методы для обратной совместимости со старыми UseCases
  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    // TODO: Реализовать через новый DataSource
    return Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, void>> verifyResetPassword(
      String email, String password, String code) async {
    // TODO: Реализовать через новый DataSource
    return Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, void>> getVerificationCode(String email) async {
    // TODO: Реализовать через новый DataSource
    return Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, void>> verifyCode(
      String email, String password, String code) async {
    // TODO: Реализовать через новый DataSource
    return Left(NotImplementedFailure());
  }
}
