import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';
import 'package:los_angeles_quest/features/data/models/auth/login_request_model.dart';
import 'package:los_angeles_quest/features/data/models/auth/register_request_model.dart';

abstract class AuthRepositoryNew {
  // Базовая аутентификация
  Future<Either<Failure, TokenResponseModel>> login(
      String email, String password);
  Future<Either<Failure, void>> register(RegisterRequestModel request);
  Future<Either<Failure, void>> logout();

  // Управление токенами
  Future<Either<Failure, TokenResponseModel>> refreshTokens();
  Future<Either<Failure, String?>> getAccessToken();
  Future<Either<Failure, String?>> getRefreshToken();
  Future<Either<Failure, void>> saveTokens(TokenResponseModel tokens);
  Future<Either<Failure, void>> clearTokens();

  // Проверка состояния авторизации
  Future<bool> get isLoggedIn;
  Future<bool> get hasValidTokens;

  // Сброс пароля (старые методы для совместимости)
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> verifyResetPassword(
      String email, String password, String code);
  Future<Either<Failure, void>> getVerificationCode(String email);
  Future<Either<Failure, void>> verifyCode(
      String email, String password, String code);
}
