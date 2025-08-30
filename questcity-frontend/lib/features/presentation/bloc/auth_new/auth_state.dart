import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';

abstract class AuthNewState extends Equatable {
  const AuthNewState();

  @override
  List<Object?> get props => [];
}

// Начальное состояние
class AuthNewInitial extends AuthNewState {}

// Загрузка
class AuthNewLoading extends AuthNewState {}

// Успешная авторизация
class AuthNewLoginSuccess extends AuthNewState {
  final TokenResponseModel tokenResponse;
  final String message;

  const AuthNewLoginSuccess({
    required this.tokenResponse,
    this.message = 'Авторизация успешна',
  });

  @override
  List<Object?> get props => [tokenResponse, message];
}

// Успешная регистрация
class AuthNewRegisterSuccess extends AuthNewState {
  final String message;

  const AuthNewRegisterSuccess({
    this.message = 'Регистрация успешна',
  });

  @override
  List<Object?> get props => [message];
}

// Успешное обновление токенов
class AuthNewRefreshSuccess extends AuthNewState {
  final TokenResponseModel tokenResponse;
  final String message;

  const AuthNewRefreshSuccess({
    required this.tokenResponse,
    this.message = 'Токены обновлены',
  });

  @override
  List<Object?> get props => [tokenResponse, message];
}

// Получение токена
class AuthNewTokenRetrieved extends AuthNewState {
  final String? accessToken;
  final String message;

  const AuthNewTokenRetrieved({
    this.accessToken,
    this.message = 'Токен получен',
  });

  @override
  List<Object?> get props => [accessToken, message];
}

// Ошибка
class AuthNewError extends AuthNewState {
  final String message;
  final String? details;

  const AuthNewError({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}

// Ошибка валидации
class AuthNewValidationError extends AuthNewState {
  final Map<String, String> errors;

  const AuthNewValidationError({
    required this.errors,
  });

  @override
  List<Object?> get props => [errors];
}

// Ошибка сети
class AuthNewNetworkError extends AuthNewState {
  final String message;

  const AuthNewNetworkError({
    this.message = 'Ошибка сети',
  });

  @override
  List<Object?> get props => [message];
}

// Ошибка таймаута
class AuthNewTimeoutError extends AuthNewState {
  final String message;

  const AuthNewTimeoutError({
    this.message = 'Превышено время ожидания',
  });

  @override
  List<Object?> get props => [message];
}
