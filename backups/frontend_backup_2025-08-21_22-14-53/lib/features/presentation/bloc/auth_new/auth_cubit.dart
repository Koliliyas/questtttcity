import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/data/models/auth/login_request_model.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/auth_login_new.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/auth_register_new.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/get_access_token.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/refresh_tokens.dart';
import 'package:los_angeles_quest/core/params/no_param.dart';
import 'package:los_angeles_quest/utils/logger.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthNewCubit extends Bloc<AuthNewEvent, AuthNewState> {
  final AuthLoginNew authLoginNew;
  final AuthRegisterNew authRegisterNew;
  final GetAccessToken getAccessToken;
  final RefreshTokens refreshTokens;

  AuthNewCubit({
    required this.authLoginNew,
    required this.authRegisterNew,
    required this.getAccessToken,
    required this.refreshTokens,
  }) : super(AuthNewInitial()) {
    on<AuthNewLoginRequested>(_onLoginRequested);
    on<AuthNewRegisterRequested>(_onRegisterRequested);
    on<AuthNewRefreshTokensRequested>(_onRefreshTokensRequested);
    on<AuthNewGetAccessTokenRequested>(_onGetAccessTokenRequested);
    on<AuthNewLogoutRequested>(_onLogoutRequested);
    on<AuthNewResetRequested>(_onResetRequested);
  }

  Future<void> _onLoginRequested(
    AuthNewLoginRequested event,
    Emitter<AuthNewState> emit,
  ) async {
    emit(AuthNewLoading());

    try {
      appLogger.d('AuthNewCubit: Starting login for ${event.email}');

      final loginRequest = LoginRequestModel(
        login: event.email,
        password: event.password,
      );

      final result = await authLoginNew(AuthLoginParams(
        email: event.email,
        password: event.password,
      ));

      result.fold(
        (failure) {
          appLogger.e('AuthNewCubit: Login failed - ${failure.toString()}');
          emit(_handleFailure(failure));
        },
        (tokenResponse) {
          appLogger.i('AuthNewCubit: Login successful for ${event.email}');
          emit(AuthNewLoginSuccess(
            tokenResponse: tokenResponse,
            message: 'Авторизация успешна',
          ));
        },
      );
    } catch (e) {
      appLogger.e('AuthNewCubit: Login unexpected error - $e');
      emit(AuthNewError(
        message: 'Неожиданная ошибка при авторизации',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onRegisterRequested(
    AuthNewRegisterRequested event,
    Emitter<AuthNewState> emit,
  ) async {
    emit(AuthNewLoading());

    try {
      appLogger
          .d('AuthNewCubit: Starting registration for ${event.request.email}');

      final result = await authRegisterNew(event.request);

      result.fold(
        (failure) {
          appLogger
              .e('AuthNewCubit: Registration failed - ${failure.toString()}');
          emit(_handleFailure(failure));
        },
        (_) {
          appLogger.i(
              'AuthNewCubit: Registration successful for ${event.request.email}');
          emit(AuthNewRegisterSuccess(
            message: 'Регистрация успешна',
          ));
        },
      );
    } catch (e) {
      appLogger.e('AuthNewCubit: Registration unexpected error - $e');
      emit(AuthNewError(
        message: 'Неожиданная ошибка при регистрации',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshTokensRequested(
    AuthNewRefreshTokensRequested event,
    Emitter<AuthNewState> emit,
  ) async {
    emit(AuthNewLoading());

    try {
      appLogger.d('AuthNewCubit: Starting token refresh');

      final result = await refreshTokens(NoParams());

      result.fold(
        (failure) {
          appLogger
              .e('AuthNewCubit: Token refresh failed - ${failure.toString()}');
          emit(_handleFailure(failure));
        },
        (tokenResponse) {
          appLogger.i('AuthNewCubit: Token refresh successful');
          emit(AuthNewRefreshSuccess(
            tokenResponse: tokenResponse,
            message: 'Токены обновлены',
          ));
        },
      );
    } catch (e) {
      appLogger.e('AuthNewCubit: Token refresh unexpected error - $e');
      emit(AuthNewError(
        message: 'Неожиданная ошибка при обновлении токенов',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onGetAccessTokenRequested(
    AuthNewGetAccessTokenRequested event,
    Emitter<AuthNewState> emit,
  ) async {
    emit(AuthNewLoading());

    try {
      appLogger.d('AuthNewCubit: Getting access token');

      final result = await getAccessToken(NoParams());

      result.fold(
        (failure) {
          appLogger.e(
              'AuthNewCubit: Get access token failed - ${failure.toString()}');
          emit(_handleFailure(failure));
        },
        (accessToken) {
          appLogger.i('AuthNewCubit: Access token retrieved');
          emit(AuthNewTokenRetrieved(
            accessToken: accessToken,
            message: 'Токен получен',
          ));
        },
      );
    } catch (e) {
      appLogger.e('AuthNewCubit: Get access token unexpected error - $e');
      emit(AuthNewError(
        message: 'Неожиданная ошибка при получении токена',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthNewLogoutRequested event,
    Emitter<AuthNewState> emit,
  ) async {
    emit(AuthNewLoading());

    try {
      appLogger.d('AuthNewCubit: Starting logout');

      // TODO: Добавить UseCase для logout
      // final result = await logout(NoParams());

      appLogger.i('AuthNewCubit: Logout successful');
      emit(AuthNewInitial());
    } catch (e) {
      appLogger.e('AuthNewCubit: Logout unexpected error - $e');
      emit(AuthNewError(
        message: 'Неожиданная ошибка при выходе',
        details: e.toString(),
      ));
    }
  }

  Future<void> _onResetRequested(
    AuthNewResetRequested event,
    Emitter<AuthNewState> emit,
  ) async {
    emit(AuthNewInitial());
  }

  AuthNewState _handleFailure(Failure failure) {
    if (failure is ConnectionFailure) {
      return AuthNewNetworkError(message: 'Ошибка подключения к серверу');
    } else if (failure is TimeoutFailure) {
      return AuthNewTimeoutError(message: 'Превышено время ожидания');
    } else if (failure is ValidationFailure) {
      return AuthNewValidationError(
          errors: {'general': 'Ошибка валидации данных'});
    } else if (failure is UnauthorizedFailure) {
      return AuthNewError(message: 'Неверные учетные данные');
    } else if (failure is PasswordUncorrectedFailure) {
      return AuthNewError(message: 'Неверный пароль');
    } else if (failure is UserNotVerifyFailure) {
      return AuthNewError(message: 'Пользователь не подтвержден');
    } else if (failure is UserNotFoundFailure) {
      return AuthNewError(message: 'Пользователь не найден');
    } else if (failure is EmailAlreadyExistsFailure) {
      return AuthNewError(message: 'Пользователь с таким email уже существует');
    } else if (failure is NotFoundFailure) {
      return AuthNewError(message: 'Ресурс не найден');
    } else if (failure is NotImplementedFailure) {
      return AuthNewError(message: 'Функция не реализована');
    } else if (failure is StorageFailure) {
      return AuthNewError(message: 'Ошибка сохранения данных');
    } else {
      return AuthNewError(message: 'Ошибка сервера');
    }
  }
}
