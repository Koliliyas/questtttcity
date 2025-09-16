# 🔧 ТЕХНИЧЕСКОЕ ЗАДАНИЕ: Исправление бесконечной загрузки в системе авторизации

## 📋 Общая информация
- **Проект:** QuestCity Frontend
- **Версия:** 1.0
- **Дата создания:** 2025-01-16
- **Статус:** В разработке
- **Приоритет:** Критический (P0)

## 🎯 Цель проекта
Устранить проблему бесконечной загрузки после авторизации пользователя, которая возникает из-за отсутствия правильной обработки состояний в UI и ошибок в коде авторизации.

## 🔍 Анализ проблемы

### Выявленные критические ошибки:

1. **Отсутствие состояния загрузки в LoginScreenCubit**
   - Местоположение: `lib/features/presentation/pages/login/login_screen/cubit/login_screen_state.dart`
   - Проблема: Нет состояния `LoginScreenLoading`
   - Последствие: UI не показывает индикатор загрузки

2. **Ошибка в методе getVerifyCode**
   - Местоположение: `lib/features/presentation/pages/login/login_screen/cubit/login_screen_cubit.dart:75-76`
   - Проблема: Пропущена переменная `failureOrLoads`
   - Код с ошибкой:
     ```dart
     final failureOrLoads =
         await getVerificationCode(AuthenticationParams(email: emailController.text));
     ```

3. **Неправильная обработка состояний в UI**
   - Местоположение: `lib/features/presentation/pages/login/login_screen/log_in_screen.dart:46`
   - Проблема: UI всегда ожидает `LoginScreenInitial`
   - Код: `LoginScreenInitial loadedState = state as LoginScreenInitial;`

4. **Отсутствие состояний загрузки в методах авторизации**
   - Методы: `login()`, `getMeData()`
   - Проблема: Не эмитятся состояния загрузки

5. **Ошибка в SplashScreenCubit**
   - Местоположение: `lib/features/presentation/splash_screen/cubit/splash_screen_cubit.dart:27`
   - Проблема: Отсутствует объявление переменной `isRememberUser`

## 📐 Техническое решение

### Этап 1: Добавление состояний загрузки

#### 1.1 Обновить LoginScreenState
**Файл:** `lib/features/presentation/pages/login/login_screen/cubit/login_screen_state.dart`

**Добавить новое состояние:**
```dart
class LoginScreenLoading extends LoginScreenState {
  final String? message; // Опциональное сообщение для пользователя
  
  const LoginScreenLoading({this.message});
  
  @override
  List<Object?> get props => [message];
}
```

#### 1.2 Обновить EnterTheCodeScreenState
**Файл:** `lib/features/presentation/pages/login/enter_the_code_screen/cubit/enter_the_code_screen_state.dart`

**Добавить состояние загрузки:**
```dart
class EnterTheCodeScreenLoading extends EnterTheCodeScreenState {
  final String? message;
  
  const EnterTheCodeScreenLoading({this.message});
  
  @override
  List<Object?> get props => [message];
}
```

### Этап 2: Исправление логики в кубитах

#### 2.1 Исправить LoginScreenCubit
**Файл:** `lib/features/presentation/pages/login/login_screen/cubit/login_screen_cubit.dart`

**Изменения в методе login:**
```dart
Future login(BuildContext context) async {
  // 1. Эмитим состояние загрузки
  emit(const LoginScreenLoading(message: "Авторизация..."));
  
  try {
    final failureOrLoads = await authLogin(
      AuthenticationParams(
          email: emailController.text,
          password: passwordController.text,
          fbid: await firebaseMessaging.getToken()),
    );

    return failureOrLoads.fold(
      (error) async {
        // 2. Возвращаем начальное состояние при ошибке
        emit(LoginScreenInitial(
          rememberUser: sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ?? false
        ));
        
        if (error is UserNotVerifyFailure) {
          await getVerifyCode(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mapFailureToMessage(error)),
            ),
          );
        }
      },
      (_) async => await getMeData(context),
    );
  } catch (e) {
    // 3. Обработка неожиданных ошибок
    emit(LoginScreenInitial(
      rememberUser: sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ?? false
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Произошла неожиданная ошибка")),
    );
  }
}
```

**Исправить метод getVerifyCode:**
```dart
Future getVerifyCode(BuildContext context) async {
  emit(const LoginScreenLoading(message: "Отправка кода..."));
  
  try {
    final failureOrLoads = await getVerificationCode(
      AuthenticationParams(email: emailController.text)
    );

    failureOrLoads.fold(
      (error) {
        // Возвращаем начальное состояние
        emit(LoginScreenInitial(
          rememberUser: sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ?? false
        ));
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_mapFailureToMessage(error)),
        ));
      },
      (_) async {
        // Возвращаем начальное состояние перед навигацией
        emit(LoginScreenInitial(
          rememberUser: sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ?? false
        ));
        
        Navigator.push(
          context,
          FadeInRoute(
            const EnterTheCodeScreen(),
            Routes.enterTheCodeScreen,
            arguments: {
              'email': emailController.text,
              'password': passwordController.text,
              'needUpdateData': false
            },
          ),
        );
      },
    );
  } catch (e) {
    emit(LoginScreenInitial(
      rememberUser: sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ?? false
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ошибка отправки кода")),
    );
  }
}
```

**Обновить метод getMeData:**
```dart
Future getMeData(BuildContext context) async {
  emit(const LoginScreenLoading(message: "Загрузка профиля..."));
  
  try {
    final failureOrLoads = await getMe(NoParams());

    return failureOrLoads.fold(
      (error) {
        emit(LoginScreenInitial(
          rememberUser: sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ?? false
        ));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mapFailureToMessage(error)),
          ),
        );
      },
      (person) {
        emit(LoginScreenLoaded(person));
        Navigator.push(
          context,
          FadeInRoute(
            const HomeScreen(),
            Routes.homeScreen,
            arguments: {
              'role': Utils.convertServerRoleToEnumItem(person.role),
              'username': person.username
            },
          ),
        );
      },
    );
  } catch (e) {
    emit(LoginScreenInitial(
      rememberUser: sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ?? false
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ошибка загрузки профиля")),
    );
  }
}
```

#### 2.2 Исправить SplashScreenCubit
**Файл:** `lib/features/presentation/splash_screen/cubit/splash_screen_cubit.dart`

**Исправить метод checkData:**
```dart
Future checkData() async {
  bool? isRememberUser = sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser);
  
  if (isRememberUser != true) {
    emit(const SplashScreenLoaded(isHasAppAuth: false));
    return; // Добавить return для избежания дальнейшего выполнения
  }
  
  final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
  if (serverToken == null) {
    emit(const SplashScreenLoaded(isHasAppAuth: false));
    return;
  }
  
  try {
    var data = await _getUserData();
    bool isTokenValid = data != null;
    
    if (!isTokenValid) {
      await reloadToken(NoParams());
      data = await _getUserData();
      isTokenValid = data != null;
    }
    
    int? role = sharedPreferences.getInt(SharedPreferencesKeys.role);

    if (isTokenValid && role != null) {
      emit(SplashScreenLoaded(
          username: data, 
          isHasAppAuth: true, 
          role: Utils.convertServerRoleToEnumItem(role)
      ));
    } else {
      emit(const SplashScreenLoaded(isHasAppAuth: false));
    }
  } catch (e) {
    // Обработка ошибок при проверке токена
    emit(const SplashScreenLoaded(isHasAppAuth: false));
  }
}
```

### Этап 3: Обновление UI

#### 3.1 Обновить LogInScreen
**Файл:** `lib/features/presentation/pages/login/login_screen/log_in_screen.dart`

**Изменить BlocBuilder:**
```dart
child: BlocBuilder<LoginScreenCubit, LoginScreenState>(
  builder: (context, state) {
    LoginScreenCubit cubit = context.read<LoginScreenCubit>();
    
    // Обработка состояния загрузки
    if (state is LoginScreenLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(Paths.backgroundLandscape),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(UiConstants.whiteColor),
                ),
                if (state.message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    state.message!,
                    style: UiConstants.textStyle16.copyWith(
                      color: UiConstants.whiteColor
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    
    // Для состояний Initial и Loaded
    final isInitialState = state is LoginScreenInitial;
    final loadedState = isInitialState 
        ? state as LoginScreenInitial
        : LoginScreenInitial(rememberUser: sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser) ?? false);
    
    // Остальной код UI...
  },
),
```

### Этап 4: Дополнительные улучшения

#### 4.1 Добавить валидацию Firebase Token
**В методе login добавить проверку:**
```dart
// Проверка Firebase token
final fbToken = await firebaseMessaging.getToken();
if (fbToken == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Ошибка инициализации push-уведомлений")),
  );
  return;
}
```

#### 4.2 Добавить таймауты для HTTP запросов
**В AuthRemoteDataSourceImpl добавить timeout:**
```dart
final response = await client.post(
  Uri.parse('${baseUrl}auth/login'),
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
    'accept': 'application/json'
  },
  body: {
    'login': email,
    'password': password
  },
).timeout(const Duration(seconds: 30)); // Добавить таймаут
```

#### 4.3 Улучшить обработку ошибок
**Добавить кастомные исключения для таймаутов:**
```dart
// В core/error/exception.dart
class NetworkTimeoutException implements Exception {}

// В repositories
} on TimeoutException {
  return Left(NetworkTimeoutFailure());
} catch (e) {
  return Left(UnknownFailure(e.toString()));
}
```

## 📝 План выполнения

### Фаза 1: Критические исправления (1-2 дня)
- [ ] Добавить состояние `LoginScreenLoading`
- [ ] Исправить ошибку в `getVerifyCode`
- [ ] Исправить ошибку в `SplashScreenCubit.checkData`
- [ ] Обновить UI для обработки состояний загрузки

### Фаза 2: Улучшения UX (1 день)
- [ ] Добавить индикаторы загрузки с сообщениями
- [ ] Улучшить обработку ошибок
- [ ] Добавить валидацию Firebase Token

### Фаза 3: Тестирование (1 день)
- [ ] Юнит-тесты для кубитов
- [ ] Интеграционные тесты авторизации
- [ ] Ручное тестирование UI

### Фаза 4: Дополнительные улучшения (1 день)
- [ ] Добавить таймауты для HTTP запросов
- [ ] Добавить логирование ошибок
- [ ] Оптимизировать производительность

## 🧪 Критерии приемки

### Обязательные требования:
1. ✅ Отсутствие бесконечной загрузки после авторизации
2. ✅ Корректное отображение индикаторов загрузки
3. ✅ Правильная обработка всех ошибок авторизации
4. ✅ Навигация работает корректно после успешной авторизации

### Дополнительные требования:
1. ✅ Плавные переходы между состояниями
2. ✅ Информативные сообщения об ошибках
3. ✅ Таймауты для HTTP запросов
4. ✅ Логирование для отладки

## ⚠️ Риски и ограничения

### Технические риски:
- Изменение состояний может повлиять на другие экраны
- Необходимо тестирование на разных устройствах
- Возможны проблемы с Firebase в эмуляторах

### Временные ограничения:
- Критические исправления должны быть выполнены в течение 2 дней
- Полное тестирование может занять дополнительное время

## 📋 Checklist разработчика

### Перед началом работы:
- [ ] Создать отдельную ветку `fix/auth-infinite-loading`
- [ ] Сделать бэкап текущего кода
- [ ] Убедиться в работоспособности бэкенда

### Во время разработки:
- [ ] Следовать архитектуре Clean Architecture
- [ ] Использовать существующие паттерны кодирования
- [ ] Добавлять комментарии к сложным участкам кода
- [ ] Тестировать каждое изменение

### После завершения:
- [ ] Проверить все критерии приемки
- [ ] Запустить полное тестирование
- [ ] Обновить документацию
- [ ] Создать PR с подробным описанием изменений

## 📚 Дополнительные ресурсы

- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Clean Architecture in Flutter](https://medium.com/ruangguru/an-introduction-to-flutter-clean-architecture-ae00154001b0)
- [Error Handling Best Practices](https://docs.flutter.dev/cookbook/networking/error-handling)

---

**Создано:** 2025-01-16  
**Автор:** AI Assistant  
**Статус:** Готово к выполнению  
**Версия документа:** 1.0