# 🔧 ТЕХНИЧЕСКОЕ ЗАДАНИЕ: Исправление архитектурных проблем авторизации

**Дата создания:** 29 января 2025  
**Автор:** AI Assistant  
**Приоритет:** 🔴 КРИТИЧЕСКИЙ  
**Статус:** 📋 К выполнению  

---

## 🎯 ЦЕЛЬ ЗАДАНИЯ

Устранить архитектурные конфликты в системе авторизации, которые могут привести к сбоям авторизации и несовместимости с backend API.

---

## 🔍 АНАЛИЗ ТЕКУЩЕГО СОСТОЯНИЯ

### ✅ **ИСПРАВЛЕНО: Проблема с бесконечной загрузкой**

Основная проблема была решена:
- Исправлена критическая ошибка в `_loadCategories()`
- Добавлены HTTP таймауты (30 секунд)
- Улучшена обработка ошибок с логированием
- Исправлена архитектурная проблема инициализации

### 🚨 **НАЙДЕННЫЕ ПРОБЛЕМЫ (требуют исправления):**

#### **1. КОНФЛИКТ DATASOURCE ИНТЕРФЕЙСОВ**
- **Старый**: `auth_remote_data_source_impl.dart` (возвращает `void` + исключения)
- **Новый**: `auth/auth_remote_data_source.dart` (возвращает `Either<Failure, T>`)
- **Проблема**: Зарегистрирован в DI только старый интерфейс

#### **2. НЕСОВМЕСТИМОСТЬ КЛЮЧЕЙ ТОКЕНОВ**
- **Backend возвращает**: `access_token`, `refresh_token`
- **Старый код ожидает**: `persons['accessToken']`, `persons['refreshToken']`
- **Новый код правильно обрабатывает**: `json['access_token']` → `refreshToken`

#### **3. HARDCODED VALUES В WEBSOCKET**
- Захардкожены URL и Bearer токены в WebSocket сервисах
- Нет использования переменных окружения

#### **4. ОТСУТСТВИЕ .env КОНФИГУРАЦИИ**
- Код пытается читать `dotenv.env['BASE_URL']` но файла может не быть

---

## 📋 ЗАДАЧИ К ВЫПОЛНЕНИЮ

### **ЗАДАЧА 1: Унификация AuthRemoteDataSource** 
**Приоритет:** 🔴 КРИТИЧЕСКИЙ  
**Время:** 60 минут  

#### **1.1. Выбор архитектуры**
- **Решение**: Использовать новый `AuthRemoteDataSource` с `Either<Failure, T>`
- **Обоснование**: Лучшая обработка ошибок, совместимость с современной архитектурой

#### **1.2. Обновление зависимостей**

**Файл:** `lib/locator_service.dart`
```dart
// УДАЛИТЬ (строка 281-283):
sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(client: sl(), secureStorage: sl()),
);

// ЗАМЕНИТЬ НА:
sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(
    httpClient: sl<HttpClient>(), 
    networkInfo: sl(),
  ),
);

// ДОБАВИТЬ РЕГИСТРАЦИЮ HttpClient:
sl.registerLazySingleton(() => HttpClient());
```

#### **1.3. Обновление AuthRepository**

**Файл:** `lib/features/data/repositories/auth_repository_impl.dart`
- Изменить возвращаемые типы с `Future<Either<Failure, void>>` на `Future<Either<Failure, TokenResponseModel>>`
- Обновить методы `login()` для возврата токенов

#### **1.4. Обновление Domain Repository**

**Файл:** `lib/features/domain/repositories/auth_repository.dart`
- Изменить сигнатуру методов для поддержки новых типов

---

### **ЗАДАЧА 2: Исправление ключей токенов**
**Приоритет:** 🔴 КРИТИЧЕСКИЙ  
**Время:** 30 минут  

#### **2.1. Проверка совместимости с Backend**

**Backend API возвращает:**
```json
{
  "access_token": "...",
  "refresh_token": "..."
}
```

#### **2.2. Исправление старого AuthRemoteDataSource**

**Файл:** `lib/features/data/datasources/auth_remote_data_source_impl.dart`
```dart
// ЗАМЕНИТЬ (строки 59-63):
await secureStorage.write(
    key: SharedPreferencesKeys.accessToken, value: persons['accessToken']);
await secureStorage.write(
    key: SharedPreferencesKeys.refreshToken, value: persons['refreshToken']);

// НА:
await secureStorage.write(
    key: SharedPreferencesKeys.accessToken, value: persons['access_token']);
await secureStorage.write(
    key: SharedPreferencesKeys.refreshToken, value: persons['refresh_token']);
```

#### **2.3. Проверка refreshToken метода**

**Файл:** `lib/features/data/datasources/auth_remote_data_source_impl.dart`
```dart
// ЗАМЕНИТЬ (строки 192-198):
await secureStorage.write(
  key: SharedPreferencesKeys.accessToken,
  value: persons['accessToken'],
);
await secureStorage.write(
    key: SharedPreferencesKeys.refreshToken, value: persons['refreshToken']);

// НА:
await secureStorage.write(
  key: SharedPreferencesKeys.accessToken,
  value: persons['access_token'],
);
await secureStorage.write(
    key: SharedPreferencesKeys.refreshToken, value: persons['refresh_token']);
```

---

### **ЗАДАЧА 3: Исправление WebSocket конфигурации**
**Приоритет:** 🟡 СРЕДНИЙ  
**Время:** 45 минут  

#### **3.1. Удаление hardcoded значений**

**Файл:** `lib/core/web_socket_service.dart`
```dart
// ЗАМЕНИТЬ (строки 9-16):
_channel = IOWebSocketChannel.connect(
  Uri.parse(
      'wss://questicity.com/api/v1.0/chats/b89d37c1-4e56-407b-80d4-cab96cf6be75ff29dadd-b918-4703-9f0b-cecfa2eea7e0'),
  headers: {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmYmlkIjoiZmJpZCIsImlkX3VzZXIiOjIwLCJleHBpcmVfdGltZSI6MjU5MjAwMCwiZXhwIjoxNzI2NTE3OTE0fQ.VmPTMKMS0Uh-RRRoG97_yvN-T5-cofG27e06Fjuplwk',
  },
);

// НА:
final baseWsUrl = dotenv.env['BASE_URL']!.replaceFirst('https', 'wss');
final token = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
_channel = IOWebSocketChannel.connect(
  Uri.parse('${baseWsUrl}chats/$chatId'),
  headers: {
    'Authorization': 'Bearer $token',
  },
);
```

#### **3.2. Исправление WebSocketRemoteDataSource**

**Файл:** `lib/features/data/datasources/web_socket_remote_data_source_impl.dart`
```dart
// ЗАМЕНИТЬ (строки 29-32):
channel = IOWebSocketChannel.connect(
    Uri.parse(
        'wss://questicity.com/api/v1.0/chats/37e880cc-f1e9-4268-a5bc-86c5c5b62f99d9473c45-c6cb-4cb8-903a-0628766b65cc'),
    headers: {'Authorization': 'Bearer $serverToken'});

// НА:
final baseWsUrl = dotenv.env['BASE_URL']!.replaceFirst('https', 'wss');
channel = IOWebSocketChannel.connect(
    Uri.parse('${baseWsUrl}chats/$token'),
    headers: {'Authorization': 'Bearer $serverToken'});
```

---

### **ЗАДАЧА 4: Создание .env файла**
**Приоритет:** 🟡 СРЕДНИЙ  
**Время:** 15 минут  

#### **4.1. Создание конфигурации**

**Файл:** `.env` (создать в корне проекта)
```env
# API Configuration
BASE_URL=http://10.0.2.2:8000/api/v1/

# Firebase Configuration  
FIREBASE_ENABLED=true

# Debug Configuration
DEBUG_MODE=true

# Network Configuration
NETWORK_TIMEOUT=30
CONNECTION_TIMEOUT=15
```

#### **4.2. Обновление .gitignore**
```gitignore
# Environment variables
.env
.env.local
.env.*.local
```

---

## 🔄 ПРОВЕРКА СОВМЕСТИМОСТИ

### **Анализ влияния изменений:**

#### **✅ Безопасные изменения:**
1. **Исправление ключей токенов** - меняет только парсинг JSON ответов
2. **Создание .env файла** - добавляет отсутствующую конфигурацию
3. **WebSocket исправления** - убирает hardcode, улучшает архитектуру

#### **⚠️ Требуют внимания:**
1. **Замена AuthRemoteDataSource** - затрагивает DI регистрацию
2. **Изменение AuthRepository интерфейса** - может затронуть UseCase

### **КРИТИЧЕСКАЯ ПРОВЕРКА: Затронутые компоненты**

#### **1. Auth Use Cases (ВЫСОКИЙ РИСК)**
Обнаружены следующие Use Case, которые ОБЯЗАТЕЛЬНО нужно протестировать:

**Зависимые файлы:**
- `lib/features/domain/usecases/auth/auth_login.dart`
- `lib/features/domain/usecases/auth/auth_register.dart` 
- `lib/features/domain/usecases/auth/reload_token.dart`
- `lib/features/domain/usecases/auth/verify_code.dart`
- `lib/features/domain/usecases/auth/get_verification_code.dart`
- `lib/features/domain/usecases/auth/reset_password.dart`
- `lib/features/domain/usecases/auth/verify_reset_password.dart`

**Используются в Cubit:**
- `LoginScreenCubit` (строки 94-100 в locator_service.dart)
- `SignInScreenCubit` (строка 101-103)
- `EnterTheCodeScreenCubit` (строки 107-116)
- `SplashScreenCubit` (строки 132-137)
- `ForgetPasswordScreenCubit` (строки 104-106)

#### **2. Auth Repository интерфейсы (ВЫСОКИЙ РИСК)**

**⚠️ ОБНАРУЖЕН КОНФЛИКТ в questcity-frontend-current-broken:**
- Есть новый `AuthRepository` с расширенными методами (строка 11-34 в repositories/auth_repository_impl.dart)
- Есть старый `AuthRepository` (строка 4 в domain/repositories/auth_repository.dart)

**ОБЯЗАТЕЛЬНАЯ ПРОВЕРКА:**
- Сравнить интерфейсы двух AuthRepository
- Убедиться что все методы совместимы
- Проверить возвращаемые типы

#### **3. Новый Auth Bloc (КРИТИЧЕСКИЙ)**

**⚠️ НАЙДЕН AuthBloc в current-broken версии:**
```dart
// В questcity-frontend-current-broken/lib/features/presentation/bloc/auth/auth_bloc.dart
final AuthRepository authRepository;
// Использует методы: isLoggedIn, hasValidTokens, getAccessToken, login, register, etc.
```

**ЭТОТ BLOC НЕ ЗАРЕГИСТРИРОВАН В ОСНОВНОЙ ВЕРСИИ!**

### **Проверки перед внедрением:**

#### **1. ОБЯЗАТЕЛЬНАЯ проверка AuthRepository интерфейсов**
```bash
# Сравнить domain repository
diff questcity-frontend/lib/features/domain/repositories/auth_repository.dart \
     questcity-frontend-current-broken/lib/features/domain/repositories/auth_repository.dart

# Сравнить data repository  
diff questcity-frontend/lib/features/data/repositories/auth_repository_impl.dart \
     questcity-frontend-current-broken/lib/features/repositories/auth_repository_impl.dart
```

#### **2. Проверить все Use Cases**
```bash
grep -r "authRepository\." lib/features/domain/usecases/auth/
```

#### **3. Проверить DI регистрации**
```bash
grep -A5 -B5 "AuthRepository\|AuthRemoteDataSource" lib/locator_service.dart
```

#### **4. Проверить missing AuthBloc**
```bash
# Проверить нужно ли добавить AuthBloc в основную версию
ls questcity-frontend-current-broken/lib/features/presentation/bloc/auth/
```

---

## 📝 ПЛАН ВЫПОЛНЕНИЯ

### **Этап 1: Подготовка (15 мин)**
1. Создать .env файл
2. Обновить .gitignore
3. Создать backup текущего кода

### **Этап 2: Исправление токенов (30 мин)**  
1. Исправить ключи в auth_remote_data_source_impl.dart
2. Протестировать login/refresh flows
3. Проверить сохранение токенов

### **Этап 3: WebSocket исправления (45 мин)**
1. Убрать hardcoded значения
2. Использовать динамические токены  
3. Протестировать подключение

### **Этап 4: Унификация DataSource (60 мин)**
1. Обновить DI регистрации
2. Адаптировать Repository
3. Обновить интерфейсы
4. Проверить совместимость

### **Этап 5: Тестирование (30 мин)**
1. Полный цикл авторизации
2. Обновление токенов
3. WebSocket подключение
4. Загрузка главной страницы

---

## ⚠️ КРИТИЧЕСКИЕ МОМЕНТЫ

### **1. Порядок выполнения**
- **ОБЯЗАТЕЛЬНО** выполнять в указанном порядке
- Каждый этап тестировать отдельно
- При ошибках - откатиться к предыдущему этапу

### **2. Проверки совместимости**
- После каждого изменения проверять компиляцию
- Тестировать основные флоу (login, splash, main screen)
- Проверять логи на предмет ошибок

### **3. Rollback план**
- Сохранить backup перед началом
- При критических ошибках - откат к рабочей версии
- Документировать все изменения

---

## 🎯 КРИТЕРИИ УСПЕХА

### **Функциональные:**
- ✅ Успешная авторизация пользователя
- ✅ Корректное сохранение и чтение токенов
- ✅ Автоматическое обновление токенов
- ✅ Работающее WebSocket соединение
- ✅ Загрузка главной страницы без ошибок

### **Технические:**
- ✅ Отсутствие конфликтов в DI
- ✅ Единая архитектура обработки ошибок
- ✅ Отсутствие hardcoded значений
- ✅ Наличие таймаутов для всех HTTP запросов
- ✅ Централизованная конфигурация через .env

### **Качественные:**
- ✅ Код проходит статический анализ
- ✅ Отсутствие warning'ов и error'ов
- ✅ Структурированное логирование
- ✅ Документированные изменения

---

## 📚 ДОПОЛНИТЕЛЬНЫЕ МАТЕРИАЛЫ

### **Связанные файлы:**
- `HIGH_PRIORITY_FRONTEND_INTEGRATION_TASKS.md` - История проблемы
- `FRONTEND_CODE_REVIEW_TASKS.md` - Дополнительные задачи
- `docs/reports/DEBUG_REPORT.md` - Предыдущие исправления

### **Backend API документация:**
- `/api/v1/auth/login` - возвращает `access_token`, `refresh_token`
- `/api/v1/auth/refresh-token` - обновление токенов
- `/api/v1/users/me` - получение данных пользователя

---

## 🚨 КРИТИЧЕСКИЕ ПРЕДУПРЕЖДЕНИЯ

### **ОБЯЗАТЕЛЬНЫЕ ДЕЙСТВИЯ ПЕРЕД НАЧАЛОМ:**

#### **1. Полный Backup**
```bash
# Создать полную копию проекта
cp -r questcity-frontend questcity-frontend-backup-$(date +%Y%m%d_%H%M%S)
```

#### **2. Проверка версий репозиториев**
```bash
# ОБЯЗАТЕЛЬНО сравнить AuthRepository между версиями
# questcity-frontend VS questcity-frontend-current-broken
# Если интерфейсы кардинально отличаются - ОСТАНОВИТЬ выполнение
```

#### **3. Тестирование на каждом этапе**
- После каждой задачи ОБЯЗАТЕЛЬНО проверять компиляцию
- Тестировать login/splash/main screen flow
- При ошибках - НЕМЕДЛЕННЫЙ откат к предыдущему состоянию

### **СТОП-ФАКТОРЫ (при которых НЕ продолжать):**

1. **❌ Если AuthRepository интерфейсы кардинально разные**
2. **❌ Если обнаружены критические ошибки компиляции**  
3. **❌ Если основной поток авторизации сломался**
4. **❌ Если найдены неучтенные зависимости от AuthRepository**

### **План отката:**
1. Остановить выполнение ТЗ
2. Восстановить из backup
3. Создать отдельное ТЗ для разрешения конфликтов
4. Повторить анализ совместимости

---

## 📞 ПОДДЕРЖКА И ВОПРОСЫ

### **При возникновении проблем:**

1. **Документировать** каждую найденную проблему
2. **Сохранить логи** ошибок компиляции/выполнения
3. **Создать новый анализ** для неожиданных сценариев
4. **Остановить выполнение** при критических ошибках

### **Контрольные точки:**
- ✅ Компиляция проекта без ошибок
- ✅ Успешный запуск приложения  
- ✅ Работающий login flow
- ✅ Загрузка splash screen
- ✅ Переход на main screen после авторизации

---

**⚠️ ВАЖНО:** Данное ТЗ основано на глубоком анализе кода и архитектуры. Все изменения спроектированы для минимального влияния на существующий функционал при максимальном исправлении выявленных проблем.

**🔥 КРИТИЧЕСКИ ВАЖНО:** Обнаружены потенциальные архитектурные конфликты между версиями проекта. ОБЯЗАТЕЛЬНО выполнить все проверки совместимости перед началом работ.

---

## 🚨 КРИТИЧЕСКИЙ АНАЛИЗ РИСКОВ ВЫПОЛНЕНИЯ ТЗ

**Дата анализа:** 29 января 2025  
**Статус:** ⚠️ ТРЕБУЕТ ПРИНЯТИЯ РЕШЕНИЯ

### 📊 **СУММАРНАЯ ОЦЕНКА РИСКОВ:**

#### **🔴 КРИТИЧЕСКИЙ РИСК #1: ПОЛНАЯ ЗАМЕНА AuthRemoteDataSource**

**📋 ОПИСАНИЕ ПРОБЛЕМЫ:**
- **Старый интерфейс (рабочий)**: Возвращает `Future<void>` + бросает исключения
- **Новый интерфейс (из broken версии)**: Возвращает `Future<Either<Failure, T>>` + разные методы

**💥 МАСШТАБ ПОЛОМКИ:**
```dart
// СТАРЫЙ (рабочий):
Future<void> login(String email, String password)  // ПРОСТЫЕ ПАРАМЕТРЫ

// НОВЫЙ (из broken версии):  
Future<Either<Failure, TokenResponseModel>> login(LoginRequestModel request)  // MODEL ПАРАМЕТРЫ!
```

**🚨 ЧТО СЛОМАЕТСЯ:**
1. **AuthRepositoryImpl** - полностью несовместим, нужна ПОЛНАЯ переписка
2. **Все UseCases** - могут сломаться из-за изменения сигнатур  
3. **DI контейнер** - нужны новые зависимости (`HttpClient` вместо `http.Client`)
4. **Все 5 Cubit'ов** использующих auth функционал

**⚠️ ПРОБЛЕМА:** ТЗ предлагает заменить рабочую архитектуру на код из `current-broken` версии!

---

#### **🔴 КРИТИЧЕСКИЙ РИСК #2: ИЗМЕНЕНИЕ AuthRepository ИНТЕРФЕЙСА**

**📋 ОПИСАНИЕ ПРОБЛЕМЫ:**
```dart
// ТЕКУЩИЙ AuthRepository (рабочий):
Future<Either<Failure, void>> login(String email, String password);

// НОВЫЙ из ТЗ:
Future<Either<Failure, TokenResponseModel>> login(LoginRequestModel request);
```

**💥 ЧТО СЛОМАЕТСЯ:**
1. **ВСЕ 7 AUTH USECASES** - используют старые сигнатуры:
   - `AuthLogin`, `AuthRegister`, `VerifyCode`, `ReloadToken`
   - `ResetPassword`, `VerifyResetPassword`, `GetVerificationCode`
2. **5 CUBIT'ов** - ожидают старые возвращаемые типы:
   - `LoginScreenCubit`, `SignInScreenCubit`, `EnterTheCodeScreenCubit`
   - `SplashScreenCubit`, `ForgetPasswordScreenCubit`
3. **SplashScreenCubit** - может не обработать новые типы токенов

**⚠️ BREAKING CHANGES:** Потребует переписки 12+ критически важных файлов

---

#### **⚠️ ВЫСОКИЙ РИСК #3: ИСПРАВЛЕНИЕ КЛЮЧЕЙ ТОКЕНОВ**

**📋 ОПИСАНИЕ ПРОБЛЕМЫ:**
```dart
// ТЕКУЩИЙ КОД (может работать со старым backend):
persons['accessToken'], persons['refreshToken'] 

// ПРЕДЛАГАЕМОЕ ИЗМЕНЕНИЕ:  
persons['access_token'], persons['refresh_token']
```

**💥 КРИТИЧЕСКИЙ РИСК:**
- Если backend действительно возвращает `accessToken` → **ПОЛНАЯ ПОТЕРЯ АВТОРИЗАЦИИ**
- Нет подтверждения фактического формата ответа backend
- Может сломать сохранение токенов для всех пользователей

**🔍 ТРЕБУЕТСЯ:** Обязательная проверка реального ответа backend перед изменением

---

#### **✅ НИЗКИЙ РИСК #4: WebSocket И .env ИЗМЕНЕНИЯ**

**📋 ОПИСАНИЕ:**
- Создание .env файла
- Удаление hardcoded значений в WebSocket
- Использование переменных окружения

**⚡ ОЦЕНКА:** Относительно безопасны, не влияют на основной auth flow

---

### 🛑 **КРИТИЧЕСКИЕ СТОП-ФАКТОРЫ:**

#### **1. ТЗ ОСНОВАНО НА СЛОМАННОЙ ВЕРСИИ**
- Новый `AuthRemoteDataSource` взят из `questcity-frontend-current-broken`
- Это версия проекта, которая **УЖЕ НЕ РАБОТАЕТ**!
- Замена рабочего кода на сломанный

#### **2. МАССИВНЫЕ BREAKING CHANGES**  
- Изменение интерфейсов затронет 12+ критически важных файлов
- Потребует полной переписки auth системы
- Высокий риск внести новые баги

#### **3. НЕПОДТВЕРЖДЕННАЯ ИНФОРМАЦИЯ**
- Нет проверки фактического формата ответов backend
- Предположения о ключах токенов могут быть неверными
- Может сломать работающую авторизацию

#### **4. АРХИТЕКТУРНАЯ НЕСОВМЕСТИМОСТЬ**
- Смешивание двух разных архитектурных подходов
- Exception-based vs Either-based error handling
- Разные модели данных и зависимости

---

### 🎯 **РЕКОМЕНДАЦИИ ПО СНИЖЕНИЮ РИСКОВ:**

#### **🚨 КРИТИЧЕСКОЕ РЕШЕНИЕ ТРЕБУЕТСЯ:**

**❌ ПОЛНОЕ ВЫПОЛНЕНИЕ ТЗ = ВЫСОКИЙ РИСК СЛОМАТЬ ВСЁ**

**✅ АЛЬТЕРНАТИВНЫЙ БЕЗОПАСНЫЙ ПОДХОД:**

#### **ЭТАП 1: ПРОВЕРКА И АНАЛИЗ**
1. **Проверить фактический ответ backend** на login запрос
2. **Сравнить архитектуры** между рабочей и broken версиями  
3. **Протестировать текущий auth flow** на предмет реальных проблем

#### **ЭТАП 2: БЕЗОПАСНЫЕ ИЗМЕНЕНИЯ**
1. **✅ Создать .env файл** (низкий риск)
2. **✅ Исправить WebSocket hardcode** (средний риск)
3. **⚠️ Исправить ключи токенов ТОЛЬКО после проверки backend**

#### **ЭТАП 3: АРХИТЕКТУРНЫЕ ИЗМЕНЕНИЯ (ОТЛОЖИТЬ)**
1. **🛑 НЕ МЕНЯТЬ AuthRemoteDataSource** без глубокого анализа
2. **🛑 НЕ МЕНЯТЬ AuthRepository интерфейс** без тестирования
3. **🛑 НЕ ИСПОЛЬЗОВАТЬ КОД из broken версии** без исправления

---

### 📋 **ПЛАН ПРИНЯТИЯ РЕШЕНИЯ:**

#### **ВАРИАНТ A: МИНИМАЛЬНЫЕ ИЗМЕНЕНИЯ (РЕКОМЕНДУЕТСЯ)**
- Исправить только WebSocket и .env
- Проверить токены и исправить при необходимости
- Сохранить рабочую архитектуру

#### **ВАРИАНТ B: ПОЭТАПНАЯ МИГРАЦИЯ**
- Сначала исправить код в broken версии
- Протестировать новую архитектуру отдельно
- Только потом мигрировать рабочую версию

#### **ВАРИАНТ C: ПОЛНОЕ ВЫПОЛНЕНИЕ ТЗ (НЕ РЕКОМЕНДУЕТСЯ)**
- Высокий риск сломать всю систему
- Требует недели тестирования и отладки
- Может привести к регрессии функционала

---

### ⚠️ **ИТОГОВОЕ ПРЕДУПРЕЖДЕНИЕ:**

**ДАННОЕ ТЗ В ТЕКУЩЕМ ВИДЕ СОДЕРЖИТ КРИТИЧЕСКИЕ РИСКИ!**

Выполнение всех пунктов ТЗ может привести к:
- Полной поломке системы авторизации
- Потере доступа пользователей к приложению  
- Необходимости экстренного отката изменений
- Длительному периоду отладки и исправлений

**НАСТОЯТЕЛЬНО РЕКОМЕНДУЕТСЯ пересмотреть подход и выполнить только безопасные изменения.**

---

**📅 СТАТУС:** Требует принятия решения перед началом выполнения  
**🎯 ЦЕЛЬ:** Обеспечить безопасное исправление проблем без регрессии функционала  
**⚡ ПРИОРИТЕТ:** Стабильность > Архитектурная чистота