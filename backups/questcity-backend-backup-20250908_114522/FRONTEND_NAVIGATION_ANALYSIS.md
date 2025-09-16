# Анализ навигации во фронтенде после авторизации

## 🔍 Как работает навигация после авторизации

### 1. Процесс авторизации и определения роли

**SplashScreen** → **SplashScreenCubit.checkData()** → **Определение роли** → **HomeScreen**

```dart
// questcity-frontend/lib/features/presentation/splash_screen/cubit/splash_screen_cubit.dart
Future checkData() async {
  // 1. Проверяем, запомнил ли пользователь логин
  bool? isRememberUser = sharedPreferences.getBool(SharedPreferencesKeys.isRememberUser);
  
  // 2. Получаем токен из secure storage
  final String? serverToken = await secureStorage.read(key: SharedPreferencesKeys.accessToken);
  
  // 3. Получаем данные пользователя через API
  var data = await _getUserData();
  
  // 4. Получаем роль из shared preferences
  int? role = sharedPreferences.getInt(SharedPreferencesKeys.role);
  
  // 5. Конвертируем роль в enum
  role: Utils.convertServerRoleToEnumItem(role)
}
```

### 2. Передача роли в HomeScreen

```dart
// questcity-frontend/lib/features/presentation/splash_screen/splash_screen.dart
Navigator.push(
  context,
  FadeInRoute(
    const HomeScreen(),
    Routes.homeScreen,
    arguments: {'role': state.role, 'username': state.username}, // ✅ Роль передается!
  ),
);
```

### 3. HomeScreen определяет экраны на основе роли

```dart
// questcity-frontend/lib/features/presentation/pages/home_screen/home_screen.dart
Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
Role role = (roleValue as Role?) ?? Role.USER;
context.read<HomeScreenCubit>().init(role);
```

### 4. HomeScreenController создает разные экраны для разных ролей

```dart
// questcity-frontend/lib/features/presentation/pages/home_screen/controller/home_screen_controller.dart
static List<List<Widget>> getNavigationScreensList(Role? role) {
  switch (role) {
    case Role.USER:
      return [
        [const QuestsScreen()],        // ✅ Обычные пользователи видят QuestsScreen
        [const FriendsScreen()],
        [const ChatScreen()],
        [const SettingsScreen()],
      ];
    case Role.ADMIN:
      return [
        [const QuestsListScreen()],    // ✅ Админы видят QuestsListScreen
        [const ChatScreen()],
        [const UsersScreen()],
        [const SettingsScreen()],
      ];
  }
}
```

## 📋 Ответ на вопрос пользователя

### ❌ **НЕТ, обычные пользователи и админы попадают на РАЗНЫЕ экраны!**

### 🔍 **Детальное сравнение:**

| Роль | Первый экран (вкладка "Quests") | Другие вкладки |
|------|----------------------------------|----------------|
| **USER** | `QuestsScreen` | Friends, Chat, Settings |
| **ADMIN** | `QuestsListScreen` | Chat, Users, Settings |

### 🎯 **Ключевые различия:**

1. **Обычные пользователи (USER):**
   - Видят `QuestsScreen` (экран для просмотра квестов)
   - Используют `GetAllQuestsAdmin` use case ❌ (это проблема!)
   - Получают 403 ошибку при обращении к админскому эндпоинту

2. **Админы (ADMIN):**
   - Видят `QuestsListScreen` (админский экран управления квестами)
   - Используют `GetAllQuestsAdmin` use case ✅ (правильно)
   - Получают доступ к админскому эндпоинту

## 🔧 **Проблема и решение**

### **Проблема:**
Обычные пользователи видят правильный экран (`QuestsScreen`), но этот экран использует неправильный use case (`GetAllQuestsAdmin`), который вызывает админский эндпоинт.

### **Решение:**
Нужно создать отдельный use case `GetAllQuests` для обычных пользователей, который будет использовать клиентский эндпоинт `/api/v1/quests/`.

## 📊 **Схема навигации**

```
SplashScreen
    ↓
SplashScreenCubit.checkData()
    ↓
Определение роли (USER/ADMIN)
    ↓
HomeScreen (с передачей роли)
    ↓
HomeScreenController.getNavigationScreensList(role)
    ↓
┌─────────────────┬─────────────────┐
│     USER        │     ADMIN       │
├─────────────────┼─────────────────┤
│ QuestsScreen    │ QuestsListScreen│
│ FriendsScreen   │ ChatScreen      │
│ ChatScreen      │ UsersScreen     │
│ SettingsScreen  │ SettingsScreen  │
└─────────────────┴─────────────────┘
```

## 🎯 **Заключение**

1. **Навигация работает правильно** - разные роли попадают на разные экраны
2. **Проблема в data layer** - обычные пользователи используют админский use case
3. **Нужно исправить** - создать `GetAllQuests` use case для обычных пользователей
4. **UI остается без изменений** - экраны уже правильные, проблема только в API вызовах
