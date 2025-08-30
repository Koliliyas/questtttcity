# 🔧 ТЕХНИЧЕСКОЕ ЗАДАНИЕ: Безопасная миграция AuthRemoteDataSource

**Дата создания:** 29 января 2025  
**Автор:** AI Assistant  
**Приоритет:** 🔴 КРИТИЧЕСКИЙ  
**Статус:** 📋 К выполнению  
**Время выполнения:** 8-10 часов  

---

## 🎯 ЦЕЛЬ ЗАДАНИЯ

Выполнить **безопасную поэтапную миграцию** системы авторизации с заменой AuthRemoteDataSource на современную архитектуру с таймаутами, retry механизмом и правильной обработкой ошибок.

### **🔥 КЛЮЧЕВЫЕ ПРИНЦИПЫ:**
1. **От общего к частному** - сначала инфраструктура, потом критические компоненты
2. **Микро-шаги с проверками** - каждое изменение тестируется отдельно
3. **Возможность отката** - на каждом этапе сохраняется рабочее состояние
4. **Нулевая толерантность к breaking changes** - критические ошибки = немедленный откат

---

## 🔍 ОБОСНОВАНИЕ НЕОБХОДИМОСТИ

### **❌ КРИТИЧЕСКИЕ ПРОБЛЕМЫ ТЕКУЩЕЙ АРХИТЕКТУРЫ:**

1. **ОТСУТСТВИЕ ТАЙМАУТОВ**
   - HTTP запросы могут висеть бесконечно
   - Приложение зависает при сетевых проблемах

2. **НЕПРАВИЛЬНЫЕ КЛЮЧИ ТОКЕНОВ**
   - Код ожидает `persons['accessToken']` 
   - Backend возвращает `access_token` (подтверждено web search)
   - Результат: авторизация не работает

3. **ПРИМИТИВНАЯ ОБРАБОТКА ОШИБОК**
   - Только `ServerException` для всех неизвестных ошибок
   - Нет обработки `TimeoutException`, `SocketException`

4. **ОТСУТСТВИЕ RETRY МЕХАНИЗМА**
   - Одиночные сетевые сбои приводят к полному отказу

### **✅ ПРЕИМУЩЕСТВА НОВОЙ АРХИТЕКТУРЫ:**
- Таймауты (30 сек) и retry (3 попытки)
- Правильные ключи токенов `access_token`/`refresh_token`
- Полноценная обработка сетевых ошибок
- Современный паттерн `Either<Failure, T>`
- Проверка сетевого соединения

---

## 📋 ПОЭТАПНЫЙ ПЛАН МИГРАЦИИ

### **🚨 ПРИНЦИП БЕЗОПАСНОСТИ: КАЖДЫЙ ЭТАП = РАБОЧЕЕ СОСТОЯНИЕ**

Каждый этап завершается **полностью рабочим состоянием проекта**. При критических ошибках на любом этапе - **немедленный откат к предыдущему состоянию**.

---

## 🔄 ЭТАП 1: ПОДГОТОВИТЕЛЬНАЯ ИНФРАСТРУКТУРА (60 мин)

### **Цель:** Создать всю необходимую инфраструктуру БЕЗ изменения работающего кода

#### **1.1. Создание Backup (10 мин)**
```bash
# Создать полную копию проекта
cp -r questcity-frontend questcity-frontend-backup-$(date +%Y%m%d_%H%M%S)

# Создать git checkpoint
git add .
git commit -m "CHECKPOINT: Before AuthRemoteDataSource migration"
git tag auth-migration-start
```

#### **1.2. Создание .env файла (15 мин)**

**Файл:** `.env` (в корне проекта)
```env
# API Configuration
BASE_URL=http://10.0.2.2:8000/api/v1/

# Network Configuration
NETWORK_TIMEOUT=30
CONNECTION_TIMEOUT=15
RETRY_ATTEMPTS=3

# Debug Configuration  
DEBUG_MODE=true
LOG_LEVEL=debug
```

**Файл:** `.gitignore` (добавить)
```gitignore
# Environment variables
.env
.env.local
.env.*.local
```

**🔍 ПРОВЕРКА 1.2:**
```bash
# Проверить что .env читается
flutter run --debug
# В логах должно быть: "dotenv.env['BASE_URL']" без ошибок
```

#### **1.3. Создание моделей данных (35 мин)**

**Создать:** `lib/features/data/models/auth/token_response_model.dart`
```dart
import 'package:json_annotation/json_annotation.dart';

part 'token_response_model.g.dart';

@JsonSerializable()
class TokenResponseModel {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token') 
  final String refreshToken;
  
  @JsonKey(name: 'token_type')
  final String tokenType;
  
  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  const TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseModelToJson(this);
}
```

**Создать:** `lib/features/data/models/auth/login_request_model.dart`
```dart
import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  final String login;
  final String password;

  const LoginRequestModel({
    required this.login,
    required this.password,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
  
  /// Конвертация в Form Data для backend
  Map<String, String> toFormData() => {
    'login': login,
    'password': password,
  };
}
```

**Создать:** `lib/features/data/models/auth/register_request_model.dart`
```dart
import 'package:json_annotation/json_annotation.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  final String email;
  final String password1;
  final String password2;
  final String username;
  final String firstName;
  final String lastName;

  const RegisterRequestModel({
    required this.email,
    required this.password1,
    required this.password2,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}
```

**🔍 ПРОВЕРКА 1.3:**
```bash
# Генерация моделей
flutter packages pub run build_runner build

# Проверка компиляции
flutter analyze
# Не должно быть ошибок в новых файлах

# Проверка что старый код работает
flutter run --debug
# Авторизация должна работать КАК ПРЕЖДЕ
```

**✅ РЕЗУЛЬТАТ ЭТАПА 1:**
- Создана инфраструктура без изменения работающего кода
- Проект компилируется и работает КАК ПРЕЖДЕ
- Готовы модели для новой архитектуры

---

## 🔄 ЭТАП 2: СОЗДАНИЕ НОВОГО DATASOURCE (90 мин)

### **Цель:** Создать новый AuthRemoteDataSource РЯДОМ со старым, не затрагивая работающий код

#### **2.1. Создание NetworkInfo и HttpClient helpers (30 мин)**

**Создать:** `lib/core/network/http_client.dart`
```dart
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:los_angeles_quest/core/app_logger.dart';

class HttpClient {
  final client = HttpClient();
  
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  
  String get baseUrl => dotenv.env['BASE_URL']!;

  Future<HttpClientResponse> postWithRetry(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
    Map<String, String>? formData,
  }) async {
    return await _executeWithRetry(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = await client.postUrl(uri);
      
      // Headers
      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });
      
      // Body
      if (body != null) {
        request.write(body);
      } else if (formData != null) {
        final formBody = formData.entries
            .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
            .join('&');
        request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
        request.write(formBody);
      }
      
      return await request.close().timeout(_timeout);
    });
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    Exception? lastException;
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        appLogger.d('HTTP attempt $attempt/$_maxRetries');
        return await operation();
      } on TimeoutException catch (e) {
        lastException = e;
        appLogger.w('HTTP timeout on attempt $attempt');
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      } on SocketException catch (e) {
        lastException = e;
        appLogger.w('HTTP socket error on attempt $attempt: ${e.message}');
        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }
    
    throw lastException!;
  }

  void dispose() {
    client.close();
  }
}
```

#### **2.2. Создание нового AuthRemoteDataSource (60 мин)**

**Создать:** `lib/features/data/datasources/auth/auth_remote_data_source_new.dart`
```dart
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../models/auth/login_request_model.dart';
import '../../../models/auth/register_request_model.dart';
import '../../../models/auth/token_response_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/app_logger.dart';

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
  final HttpClient httpClient;
  final NetworkInfo networkInfo;
  
  AuthRemoteDataSourceNewImpl({
    required this.httpClient,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TokenResponseModel>> login(LoginRequestModel request) async {
    if (!(await networkInfo.isConnected)) {
      appLogger.e('No internet connection for login');
      return Left(ConnectionFailure());
    }

    try {
      appLogger.d('Starting login for: ${request.login}');
      
      final response = await httpClient.postWithRetry(
        'auth/login',
        formData: request.toFormData(),
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
        headers: {'Content-Type': 'application/json'},
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
  Future<Either<Failure, TokenResponseModel>> refreshToken(String refreshToken) async {
    // Аналогичная реализация...
    // TODO: Реализовать refresh token
    return Left(ServerFailure());
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
```

**🔍 ПРОВЕРКА 2.2:**
```bash
# Проверка компиляции
flutter analyze
# Не должно быть ошибок в новых файлах

# Проверка что СТАРЫЙ код работает
flutter run --debug
# Авторизация должна работать КАК ПРЕЖДЕ (через старый DataSource)
```

**✅ РЕЗУЛЬТАТ ЭТАПА 2:**
- Создан новый AuthRemoteDataSource РЯДОМ со старым
- Проект компилируется без ошибок
- Старая авторизация работает БЕЗ ИЗМЕНЕНИЙ
- Готов новый DataSource для тестирования

---

## 🔄 ЭТАП 3: ИЗОЛИРОВАННОЕ ТЕСТИРОВАНИЕ НОВОГО DATASOURCE (45 мин)

### **Цель:** Протестировать новый DataSource ОТДЕЛЬНО, не затрагивая основной код

#### **3.1. Создание тестового файла (15 мин)**

**Создать:** `lib/test_new_auth_datasource.dart`
```dart
import 'package:flutter/material.dart';
import 'package:los_angeles_quest/features/data/datasources/auth/auth_remote_data_source_new.dart';
import 'package:los_angeles_quest/features/data/models/auth/login_request_model.dart';
import 'package:los_angeles_quest/core/network/http_client.dart';
import 'package:los_angeles_quest/core/platform/network_info.dart';
import 'package:los_angeles_quest/core/app_logger.dart';

class TestNewAuthDataSource extends StatefulWidget {
  @override
  _TestNewAuthDataSourceState createState() => _TestNewAuthDataSourceState();
}

class _TestNewAuthDataSourceState extends State<TestNewAuthDataSource> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _result = 'Готов к тестированию';
  bool _isLoading = false;

  late AuthRemoteDataSourceNew _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = AuthRemoteDataSourceNewImpl(
      httpClient: HttpClient(),
      networkInfo: NetworkInfoImpl(),
    );
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _result = 'Тестирование входа...';
    });

    final request = LoginRequestModel(
      login: _emailController.text,
      password: _passwordController.text,
    );

    final result = await _dataSource.login(request);
    
    result.fold(
      (failure) {
        setState(() {
          _result = 'ОШИБКА: ${failure.runtimeType}';
          _isLoading = false;
        });
      },
      (tokens) {
        setState(() {
          _result = 'УСПЕХ! Токены получены:\n'
                   'Access: ${tokens.accessToken.substring(0, 20)}...\n'
                   'Refresh: ${tokens.refreshToken.substring(0, 20)}...';
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Тест нового DataSource')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: _isLoading ? CircularProgressIndicator() : Text('Тест Login'),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all()),
              child: Text(_result),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### **3.2. Добавление маршрута для тестирования (10 мин)**

**Обновить:** `lib/main.dart` (временно)
```dart
// Добавить в routes:
'/test-auth': (context) => TestNewAuthDataSource(),
```

#### **3.3. Изолированное тестирование (20 мин)**

**🔍 ПРОВЕРКА 3.3:**
```bash
# Запуск приложения
flutter run --debug

# Навигация: /test-auth
# Тестирование:
# 1. Ввести правильные учетные данные → ожидать SUCCESS
# 2. Ввести неправильные данные → ожидать конкретные ошибки
# 3. Тест без интернета → ожидать ConnectionFailure
# 4. Проверить логи на таймауты и retry
```

**✅ РЕЗУЛЬТАТ ЭТАПА 3:**
- Новый DataSource протестирован ИЗОЛИРОВАННО
- Подтверждена работа с правильными ключами токенов
- Проверена обработка ошибок и таймаутов
- Основной код приложения НЕ ЗАТРОНУТ

---

## 🔄 ЭТАП 4: СОЗДАНИЕ НОВОГО REPOSITORY (75 мин)

### **Цель:** Создать новый AuthRepository РЯДОМ со старым, интегрировать с новым DataSource

#### **4.1. Расширение domain интерфейса (25 мин)**

**Создать:** `lib/features/domain/repositories/auth_repository_new.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';
import 'package:los_angeles_quest/features/data/models/auth/login_request_model.dart';
import 'package:los_angeles_quest/features/data/models/auth/register_request_model.dart';

abstract class AuthRepositoryNew {
  // Базовая аутентификация
  Future<Either<Failure, TokenResponseModel>> login(String email, String password);
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
  Future<Either<Failure, void>> verifyResetPassword(String email, String password, String code);
  Future<Either<Failure, void>> getVerificationCode(String email);
  Future<Either<Failure, void>> verifyCode(String email, String password, String code);
}
```

#### **4.2. Реализация нового Repository (50 мин)**

**Создать:** `lib/features/data/repositories/auth_repository_new_impl.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/shared_preferences_keys.dart';
import 'package:los_angeles_quest/core/app_logger.dart';

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
  Future<Either<Failure, TokenResponseModel>> login(String email, String password) async {
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
    
    final refreshToken = await secureStorage.read(key: SharedPreferencesKeys.refreshToken);
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
      final token = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
      return Right(token);
    } catch (e) {
      appLogger.e('Repository: Error reading access token: $e');
      return Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, String?>> getRefreshToken() async {
    try {
      final token = await secureStorage.read(key: SharedPreferencesKeys.refreshToken);
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
    final accessToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
    final refreshToken = await secureStorage.read(key: SharedPreferencesKeys.refreshToken);
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
  Future<Either<Failure, void>> verifyResetPassword(String email, String password, String code) async {
    // TODO: Реализовать через новый DataSource
    return Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, void>> getVerificationCode(String email) async {
    // TODO: Реализовать через новый DataSource
    return Left(NotImplementedFailure());
  }

  @override
  Future<Either<Failure, void>> verifyCode(String email, String password, String code) async {
    // TODO: Реализовать через новый DataSource
    return Left(NotImplementedFailure());
  }
}
```

**🔍 ПРОВЕРКА 4.2:**
```bash
# Проверка компиляции
flutter analyze
# Не должно быть ошибок в новых файлах

# Проверка что СТАРЫЙ код работает
flutter run --debug
# Авторизация должна работать КАК ПРЕЖДЕ
```

**✅ РЕЗУЛЬТАТ ЭТАПА 4:**
- Создан новый AuthRepository с расширенным интерфейсом
- Реализовано управление токенами через secure storage
- Проект компилируется без ошибок
- Старая авторизация работает БЕЗ ИЗМЕНЕНИЙ

---

## 🔄 ЭТАП 5: СОЗДАНИЕ НОВЫХ USECASES (60 мин)

### **Цель:** Создать новые UseCase РЯДОМ со старыми для работы с новым Repository

#### **5.1. Создание основных UseCases (40 мин)**

**Создать:** `lib/features/domain/usecases/auth_new/auth_login_new.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';

class AuthLoginParams {
  final String email;
  final String password;

  const AuthLoginParams({required this.email, required this.password});
}

class AuthLoginNew extends UseCase<TokenResponseModel, AuthLoginParams> {
  final AuthRepositoryNew authRepository;

  AuthLoginNew(this.authRepository);

  @override
  Future<Either<Failure, TokenResponseModel>> call(AuthLoginParams params) async {
    return await authRepository.login(params.email, params.password);
  }
}
```

**Создать:** `lib/features/domain/usecases/auth_new/auth_register_new.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';
import 'package:los_angeles_quest/features/data/models/auth/register_request_model.dart';

class AuthRegisterNew extends UseCase<void, RegisterRequestModel> {
  final AuthRepositoryNew authRepository;

  AuthRegisterNew(this.authRepository);

  @override
  Future<Either<Failure, void>> call(RegisterRequestModel params) async {
    return await authRepository.register(params);
  }
}
```

**Создать:** `lib/features/domain/usecases/auth_new/get_access_token.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';

class GetAccessToken extends UseCase<String?, NoParams> {
  final AuthRepositoryNew authRepository;

  GetAccessToken(this.authRepository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await authRepository.getAccessToken();
  }
}
```

**Создать:** `lib/features/domain/usecases/auth_new/refresh_tokens.dart`
```dart
import 'package:dartz/dartz.dart';
import 'package:los_angeles_quest/core/error/failure.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';

class RefreshTokens extends UseCase<TokenResponseModel, NoParams> {
  final AuthRepositoryNew authRepository;

  RefreshTokens(this.authRepository);

  @override
  Future<Either<Failure, TokenResponseModel>> call(NoParams params) async {
    return await authRepository.refreshTokens();
  }
}
```

#### **5.2. Создание тестового Cubit для нового UseCase (20 мин)**

**Создать:** `lib/features/presentation/test_new_auth/test_new_auth_cubit.dart`
```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:los_angeles_quest/core/usecases/usecase.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/auth_login_new.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/get_access_token.dart';
import 'package:los_angeles_quest/features/data/models/auth/token_response_model.dart';

part 'test_new_auth_state.dart';

class TestNewAuthCubit extends Cubit<TestNewAuthState> {
  final AuthLoginNew authLoginNew;
  final GetAccessToken getAccessToken;

  TestNewAuthCubit({
    required this.authLoginNew,
    required this.getAccessToken,
  }) : super(TestNewAuthInitial());

  Future<void> testLogin(String email, String password) async {
    emit(TestNewAuthLoading());
    
    final result = await authLoginNew(AuthLoginParams(email: email, password: password));
    
    result.fold(
      (failure) => emit(TestNewAuthError(failure.toString())),
      (tokens) => emit(TestNewAuthSuccess(tokens)),
    );
  }

  Future<void> checkTokens() async {
    final result = await getAccessToken(NoParams());
    
    result.fold(
      (failure) => emit(TestNewAuthError('Token error: ${failure.toString()}')),
      (token) {
        if (token != null) {
          emit(TestNewAuthTokenFound(token));
        } else {
          emit(TestNewAuthError('No token found'));
        }
      },
    );
  }
}
```

**Создать:** `lib/features/presentation/test_new_auth/test_new_auth_state.dart`
```dart
part of 'test_new_auth_cubit.dart';

abstract class TestNewAuthState extends Equatable {
  const TestNewAuthState();

  @override
  List<Object?> get props => [];
}

class TestNewAuthInitial extends TestNewAuthState {}

class TestNewAuthLoading extends TestNewAuthState {}

class TestNewAuthSuccess extends TestNewAuthState {
  final TokenResponseModel tokens;

  const TestNewAuthSuccess(this.tokens);

  @override
  List<Object> get props => [tokens];
}

class TestNewAuthError extends TestNewAuthState {
  final String message;

  const TestNewAuthError(this.message);

  @override
  List<Object> get props => [message];
}

class TestNewAuthTokenFound extends TestNewAuthState {
  final String token;

  const TestNewAuthTokenFound(this.token);

  @override
  List<Object> get props => [token];
}
```

**🔍 ПРОВЕРКА 5.2:**
```bash
# Проверка компиляции
flutter analyze
# Не должно быть ошибок в новых файлах

# Проверка что СТАРЫЙ код работает
flutter run --debug
# Авторизация должна работать КАК ПРЕЖДЕ
```

**✅ РЕЗУЛЬТАТ ЭТАПА 5:**
- Созданы новые UseCase для работы с новой архитектурой
- Создан тестовый Cubit для проверки интеграции
- Проект компилируется без ошибок
- Старая авторизация работает БЕЗ ИЗМЕНЕНИЙ

---

## 🔄 ЭТАП 6: РЕГИСТРАЦИЯ В DI КОНТЕЙНЕРЕ (30 мин)

### **Цель:** Зарегистрировать новые компоненты в DI БЕЗ удаления старых

#### **6.1. Добавление новых регистраций (30 мин)**

**Обновить:** `lib/locator_service.dart`
```dart
// Добавить импорты для новых компонентов
import 'package:los_angeles_quest/features/data/datasources/auth/auth_remote_data_source_new.dart';
import 'package:los_angeles_quest/features/domain/repositories/auth_repository_new.dart';
import 'package:los_angeles_quest/features/data/repositories/auth_repository_new_impl.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/auth_login_new.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/auth_register_new.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/get_access_token.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/refresh_tokens.dart';
import 'package:los_angeles_quest/features/presentation/test_new_auth/test_new_auth_cubit.dart';
import 'package:los_angeles_quest/core/network/http_client.dart';

// В методе init() ДОБАВИТЬ (НЕ ЗАМЕНЯТЬ существующие):

void init() {
  // ... существующий код ...

  // === НОВЫЕ КОМПОНЕНТЫ AUTH СИСТЕМЫ ===
  
  // HTTP Client
  sl.registerLazySingleton(() => HttpClient());
  
  // New Auth DataSource
  sl.registerLazySingleton<AuthRemoteDataSourceNew>(
    () => AuthRemoteDataSourceNewImpl(
      httpClient: sl<HttpClient>(),
      networkInfo: sl(),
    ),
  );
  
  // New Auth Repository
  sl.registerLazySingleton<AuthRepositoryNew>(
    () => AuthRepositoryNewImpl(
      remoteDataSource: sl<AuthRemoteDataSourceNew>(),
      secureStorage: sl(),
    ),
  );
  
  // New Auth UseCases
  sl.registerLazySingleton(() => AuthLoginNew(sl<AuthRepositoryNew>()));
  sl.registerLazySingleton(() => AuthRegisterNew(sl<AuthRepositoryNew>()));
  sl.registerLazySingleton(() => GetAccessToken(sl<AuthRepositoryNew>()));
  sl.registerLazySingleton(() => RefreshTokens(sl<AuthRepositoryNew>()));
  
  // Test Cubit
  sl.registerFactory(() => TestNewAuthCubit(
    authLoginNew: sl(),
    getAccessToken: sl(),
  ));

  // ... остальной существующий код БЕЗ ИЗМЕНЕНИЙ ...
}
```

**🔍 ПРОВЕРКА 6.1:**
```bash
# Проверка компиляции
flutter analyze
# Не должно быть ошибок DI

# Проверка что СТАРЫЙ код работает
flutter run --debug
# Авторизация должна работать КАК ПРЕЖДЕ

# Проверка новых компонентов
# Добавить временный тест в main.dart:
final newAuthLogin = sl<AuthLoginNew>();
print('New auth components registered: ${newAuthLogin != null}');
```

**✅ РЕЗУЛЬТАТ ЭТАПА 6:**
- Новые компоненты зарегистрированы в DI
- Старые регистрации НЕ ЗАТРОНУТЫ
- Проект компилируется без ошибок
- Старая авторизация работает БЕЗ ИЗМЕНЕНИЙ
- Новые компоненты готовы к использованию

---

## 🔄 ЭТАП 7: ТЕСТИРОВАНИЕ ПОЛНОЙ ИНТЕГРАЦИИ (45 мин)

### **Цель:** Протестировать полную цепочку новых компонентов БЕЗ влияния на основной код

#### **7.1. Создание тестового экрана (25 мин)**

**Создать:** `lib/features/presentation/test_new_auth/test_new_auth_screen.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:los_angeles_quest/locator_service.dart';
import 'test_new_auth_cubit.dart';

class TestNewAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TestNewAuthCubit>(),
      child: TestNewAuthView(),
    );
  }
}

class TestNewAuthView extends StatefulWidget {
  @override
  _TestNewAuthViewState createState() => _TestNewAuthViewState();
}

class _TestNewAuthViewState extends State<TestNewAuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тест новой AUTH системы'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLoginForm(),
            SizedBox(height: 20),
            _buildTestResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.read<TestNewAuthCubit>().testLogin(
                  _emailController.text,
                  _passwordController.text,
                ),
                child: Text('Тест Login (NEW)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.read<TestNewAuthCubit>().checkTokens(),
                child: Text('Проверить токены'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestResults() {
    return BlocBuilder<TestNewAuthCubit, TestNewAuthState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Результаты тестирования:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildStateWidget(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStateWidget(TestNewAuthState state) {
    if (state is TestNewAuthInitial) {
      return Text('Готов к тестированию новой AUTH системы');
    } else if (state is TestNewAuthLoading) {
      return Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Тестирование...'),
        ],
      );
    } else if (state is TestNewAuthSuccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✅ УСПЕХ! Новая система работает!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Access Token (первые 30 символов):'),
          Text(state.tokens.accessToken.substring(0, 30) + '...', style: TextStyle(fontFamily: 'monospace')),
          SizedBox(height: 4),
          Text('Refresh Token (первые 30 символов):'),
          Text(state.tokens.refreshToken.substring(0, 30) + '...', style: TextStyle(fontFamily: 'monospace')),
        ],
      );
    } else if (state is TestNewAuthTokenFound) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✅ Токен найден в storage:', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          Text(state.token.substring(0, 30) + '...', style: TextStyle(fontFamily: 'monospace')),
        ],
      );
    } else if (state is TestNewAuthError) {
      return Text('❌ Ошибка: ${state.message}', style: TextStyle(color: Colors.red));
    }
    
    return Text('Неизвестное состояние');
  }
}
```

#### **7.2. Добавление маршрута (10 мин)**

**Обновить:** `lib/main.dart`
```dart
// Добавить в routes:
'/test-new-auth': (context) => TestNewAuthScreen(),
```

#### **7.3. Полное тестирование интеграции (10 мин)**

**🔍 ПРОВЕРКА 7.3:**
```bash
# Запуск приложения
flutter run --debug

# Тестирование СТАРОЙ системы:
# 1. Обычная авторизация → должна работать КАК ПРЕЖДЕ
# 2. Все экраны → должны работать БЕЗ ИЗМЕНЕНИЙ

# Тестирование НОВОЙ системы:
# 3. Навигация: /test-new-auth
# 4. Тест с правильными данными → ожидать SUCCESS + токены
# 5. Тест "Проверить токены" → должен найти сохраненные токены
# 6. Тест с неправильными данными → ожидать конкретные ошибки
# 7. Проверить логи → должны быть детальные логи новой системы
```

**✅ РЕЗУЛЬТАТ ЭТАПА 7:**
- Новая AUTH система работает полностью ИЗОЛИРОВАННО
- Получение и сохранение токенов работает корректно
- Старая система работает БЕЗ ИЗМЕНЕНИЙ
- Готовность к финальной замене

---

## 🔄 ЭТАП 8: КРИТИЧЕСКИЙ МОМЕНТ - ПЕРЕКЛЮЧЕНИЕ (60 мин)

### **Цель:** Заменить старые UseCase на новые в существующих Cubit'ах

#### **8.1. Backup критических точек (10 мин)**

```bash
# Создать дополнительный checkpoint перед критическими изменениями
git add .
git commit -m "CHECKPOINT: Before switching to new AUTH system"
git tag auth-migration-critical-point
```

#### **8.2. Поэтапная замена в Cubit'ах (50 мин)**

**СТРАТЕГИЯ:** Заменять по одному Cubit, тестировать, переходить к следующему.

##### **8.2.1. LoginScreenCubit (15 мин)**

**Обновить:** `lib/features/presentation/pages/login/login_screen/cubit/login_screen_cubit.dart`

```dart
// ЗАМЕНИТЬ импорт:
// import 'package:los_angeles_quest/features/domain/usecases/auth/auth_login.dart';
import 'package:los_angeles_quest/features/domain/usecases/auth_new/auth_login_new.dart';

// ОБНОВИТЬ в классе:
class LoginScreenCubit extends Cubit<LoginScreenState> {
  // ЗАМЕНИТЬ:
  // final AuthLogin authLogin;
  final AuthLoginNew authLogin;

  LoginScreenCubit({
    required this.authLogin,
    // ... остальные параметры
  }) : super(LoginScreenInitial());

  // ОБНОВИТЬ метод login:
  Future<void> login() async {
    if (!_isFormValid()) return;

    emit(LoginScreenLoading());

    // ЗАМЕНИТЬ:
    // final result = await authLogin(AuthenticationParams(
    //   email: emailController.text,
    //   password: passwordController.text,
    // ));
    final result = await authLogin(AuthLoginParams(
      email: emailController.text,
      password: passwordController.text,
    ));

    result.fold(
      (failure) => emit(LoginScreenError(_mapFailureToMessage(failure))),
      // ИЗМЕНИТЬ обработку успеха:
      (tokens) {
        // Токены уже сохранены в Repository
        emit(LoginScreenSuccess());
      },
    );
  }

  // Остальные методы БЕЗ ИЗМЕНЕНИЙ
}
```

**🔍 ПРОВЕРКА 8.2.1:**
```bash
# Проверка компиляции
flutter analyze

# Критическое тестирование:
flutter run --debug
# 1. Тест login screen → должен работать С НОВОЙ СИСТЕМОЙ
# 2. Проверить что токены сохраняются
# 3. Проверить переход на главный экран
# 4. Если ошибки → НЕМЕДЛЕННЫЙ ОТКАТ к предыдущему состоянию
```

##### **8.2.2. SplashScreenCubit (15 мин)**

**Обновить:** `lib/features/presentation/splash_screen/cubit/splash_screen_cubit.dart`

```dart
// ДОБАВИТЬ импорты:
import 'package:los_angeles_quest/features/domain/usecases/auth_new/get_access_token.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  // ДОБАВИТЬ:
  final GetAccessToken getAccessToken;
  
  // ОБНОВИТЬ конструктор:
  SplashScreenCubit({
    required this.getAccessToken,
    // ... остальные параметры
  }) : super(SplashScreenInitial());

  Future<void> checkAuthenticationStatus() async {
    emit(SplashScreenLoading());
    
    // ЗАМЕНИТЬ логику проверки токенов:
    final result = await getAccessToken(NoParams());
    
    result.fold(
      (failure) => emit(SplashScreenUnauthenticated()),
      (token) {
        if (token != null && token.isNotEmpty) {
          emit(SplashScreenAuthenticated());
        } else {
          emit(SplashScreenUnauthenticated());
        }
      },
    );
  }
}
```

**🔍 ПРОВЕРКА 8.2.2:**
```bash
# Критическое тестирование:
flutter run --debug
# 1. Перезапуск приложения → должен правильно определить статус авторизации
# 2. После login → splash должен отправлять на главную
# 3. После logout → splash должен отправлять на login
# 4. Если ошибки → НЕМЕДЛЕННЫЙ ОТКАТ
```

##### **8.2.3. Остальные Cubit'ы (20 мин)**

Аналогично обновить:
- `SignInScreenCubit`
- `EnterTheCodeScreenCubit` 
- `ForgetPasswordScreenCubit`

**🔍 ПРОВЕРКА 8.2.3:**
```bash
# Полное тестирование всех auth потоков:
flutter run --debug
# 1. Регистрация нового пользователя
# 2. Вход существующего пользователя
# 3. Сброс пароля
# 4. Верификация кода
# 5. Автологин при перезапуске
# 6. Если любой поток сломан → ОТКАТ ВСЕХ ИЗМЕНЕНИЙ
```

**✅ РЕЗУЛЬТАТ ЭТАПА 8:**
- Все Cubit'ы переключены на новую AUTH систему
- Все auth потоки работают с новой архитектурой
- Токены правильно сохраняются и читаются
- Приложение полностью функционально

---

## 🔄 ЭТАП 9: ОЧИСТКА И ФИНАЛИЗАЦИЯ (45 мин)

### **Цель:** Удалить старые компоненты и завершить миграцию

#### **9.1. Обновление DI регистраций (15 мин)**

**Обновить:** `lib/locator_service.dart`
```dart
// УДАЛИТЬ старые импорты и регистрации:
// import 'package:los_angeles_quest/features/domain/usecases/auth/auth_login.dart';
// sl.registerLazySingleton(() => AuthLogin(sl()));

// ОБНОВИТЬ регистрации Cubit'ов для использования новых UseCase:
sl.registerFactory(() => LoginScreenCubit(
  authLogin: sl<AuthLoginNew>(), // ИЗМЕНЕНО
  getVerificationCode: sl(),
));

sl.registerFactory(() => SplashScreenCubit(
  getAccessToken: sl<GetAccessToken>(), // ДОБАВЛЕНО
  reloadToken: sl(),
));

// ... остальные обновления
```

#### **9.2. Удаление старых файлов (15 мин)**

```bash
# Удалить старые компоненты (ОСТОРОЖНО!):
rm lib/features/data/datasources/auth_remote_data_source_impl.dart
rm lib/features/domain/usecases/auth/auth_login.dart
rm lib/features/domain/usecases/auth/auth_register.dart
# ... остальные старые UseCase

# Переименовать новые файлы на стандартные имена:
mv lib/features/data/datasources/auth/auth_remote_data_source_new.dart \
   lib/features/data/datasources/auth_remote_data_source_impl.dart

mv lib/features/domain/repositories/auth_repository_new.dart \
   lib/features/domain/repositories/auth_repository.dart

# ... остальные переименования
```

#### **9.3. Обновление импортов (15 мин)**

Обновить все импорты в файлах для использования стандартных имен.

**🔍 ФИНАЛЬНАЯ ПРОВЕРКА:**
```bash
# Полная проверка проекта:
flutter clean
flutter pub get
flutter analyze
# Не должно быть ошибок

flutter run --debug
# ПОЛНОЕ ТЕСТИРОВАНИЕ ВСЕХ ФУНКЦИЙ:
# 1. Регистрация ✅
# 2. Авторизация ✅  
# 3. Автологин ✅
# 4. Обновление токенов ✅
# 5. Logout ✅
# 6. Восстановление пароля ✅
# 7. WebSocket соединения ✅
# 8. Все экраны приложения ✅
```

---

## ✅ КРИТЕРИИ УСПЕШНОГО ЗАВЕРШЕНИЯ

### **🎯 ФУНКЦИОНАЛЬНЫЕ КРИТЕРИИ:**
- [ ] Успешная авторизация пользователя
- [ ] Корректное сохранение токенов с правильными ключами
- [ ] Автоматический автологин при перезапуске
- [ ] Работающее обновление токенов
- [ ] Стабильные WebSocket соединения
- [ ] Все экраны приложения функционируют

### **🔧 ТЕХНИЧЕСКИЕ КРИТЕРИИ:**
- [ ] Проект компилируется без ошибок и warnings
- [ ] Все тесты проходят (если есть)
- [ ] Таймауты (30 сек) работают корректно
- [ ] Retry механизм (3 попытки) активен
- [ ] Детальное логирование всех операций
- [ ] Правильная обработка всех типов ошибок

### **📊 КАЧЕСТВЕННЫЕ КРИТЕРИИ:**
- [ ] Код соответствует архитектурным принципам
- [ ] Отсутствуют захардкоженные значения
- [ ] Централизованная конфигурация через .env
- [ ] Документированные изменения
- [ ] Отсутствие технического долга

---

## 🚨 ПЛАН ОТКАТА В КРИТИЧЕСКИХ СИТУАЦИЯХ

### **⚠️ СТОП-ФАКТОРЫ:**
1. **Критические ошибки компиляции** после любого этапа
2. **Поломка основного auth потока** (login/logout)
3. **Потеря существующих пользовательских токенов**
4. **Неработающие WebSocket соединения**
5. **Превышение времени выполнения** (>12 часов)

### **🔄 ПРОЦЕДУРА ОТКАТА:**
```bash
# Немедленный откат к последнему checkpoint:
git reset --hard auth-migration-critical-point

# Или полный откат к началу:
git reset --hard auth-migration-start

# Восстановление из backup:
rm -rf questcity-frontend
cp -r questcity-frontend-backup-* questcity-frontend

# Анализ проблем и создание нового плана
```

---

## 📋 ЧЕКЛИСТ ВЫПОЛНЕНИЯ

### **ПОДГОТОВКА:**
- [ ] Создан backup проекта
- [ ] Создан git checkpoint
- [ ] Создан .env файл
- [ ] Созданы модели данных
- [ ] Проверена компиляция

### **РАЗРАБОТКА:**
- [ ] Создан новый AuthRemoteDataSource
- [ ] Протестирован изолированно
- [ ] Создан новый AuthRepository  
- [ ] Созданы новые UseCases
- [ ] Зарегистрировано в DI
- [ ] Протестирована полная интеграция

### **КРИТИЧЕСКИЙ ПЕРЕХОД:**
- [ ] Checkpoint перед переключением
- [ ] Обновлен LoginScreenCubit
- [ ] Обновлен SplashScreenCubit
- [ ] Обновлены остальные Cubit'ы
- [ ] Проверены все auth потоки

### **ФИНАЛИЗАЦИЯ:**
- [ ] Обновлены DI регистрации
- [ ] Удалены старые файлы
- [ ] Переименованы новые файлы
- [ ] Обновлены импорты
- [ ] Финальное тестирование

---

## 📞 ПОДДЕРЖКА И МОНИТОРИНГ

### **🔍 МОНИТОРИНГ ПОСЛЕ ВНЕДРЕНИЯ:**
1. **Первые 24 часа:** Постоянный мониторинг логов
2. **Первая неделя:** Ежедневная проверка auth метрик
3. **Первый месяц:** Еженедельный анализ ошибок

### **📊 КЛЮЧЕВЫЕ МЕТРИКИ:**
- Успешность авторизации (должно быть >95%)
- Время ответа auth запросов (должно быть <5 сек)
- Частота обновления токенов
- Количество сетевых ошибок

### **🚨 КРИТИЧЕСКИЕ ALERT'Ы:**
- Падение успешности авторизации <90%
- Массовые сетевые ошибки
- Проблемы с сохранением токенов
- Рост времени ответа >10 сек

---

**📅 СТАТУС:** Готово к выполнению  
**⏱️ ВРЕМЯ ВЫПОЛНЕНИЯ:** 8-10 часов  
**🎯 РЕЗУЛЬТАТ:** Современная, надежная AUTH система с таймаутами, retry и правильной обработкой ошибок  
**🔒 БЕЗОПАСНОСТЬ:** Поэтапный подход с возможностью отката на каждом этапе