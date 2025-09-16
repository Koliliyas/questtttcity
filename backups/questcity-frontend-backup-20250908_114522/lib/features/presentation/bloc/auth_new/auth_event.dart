import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/features/data/models/auth/register_request_model.dart';

abstract class AuthNewEvent extends Equatable {
  const AuthNewEvent();

  @override
  List<Object?> get props => [];
}

// Событие авторизации
class AuthNewLoginRequested extends AuthNewEvent {
  final String email;
  final String password;

  const AuthNewLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// Событие регистрации
class AuthNewRegisterRequested extends AuthNewEvent {
  final RegisterRequestModel request;

  const AuthNewRegisterRequested({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
}

// Событие обновления токенов
class AuthNewRefreshTokensRequested extends AuthNewEvent {}

// Событие получения токена
class AuthNewGetAccessTokenRequested extends AuthNewEvent {}

// Событие выхода
class AuthNewLogoutRequested extends AuthNewEvent {}

// Событие сброса состояния
class AuthNewResetRequested extends AuthNewEvent {}
