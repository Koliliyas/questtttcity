# Проблема с отображением квестов во фронтенде

## 🔍 Анализ проблемы

### Проблема
Обычные пользователи не видят квесты во фронтенде, хотя API возвращает данные.

### Причина
**Неправильный эндпоинт используется для обычных пользователей!**

## 📋 Детальный анализ

### 1. Текущая реализация

**Фронтенд использует:**
- `GetAllQuestsAdmin` use case для ВСЕХ пользователей (обычных и админов)
- Этот use case вызывает `questRemoteDataSource.getAllQuests()`
- `getAllQuests()` использует URL: `/quests/admin/list` (админский эндпоинт)

**Проблема:**
```dart
// questcity-frontend/lib/features/data/datasources/quest_remote_data_source_impl.dart:300
final url = '$baseUrl/quests/admin/list';  // ❌ Админский эндпоинт!
```

### 2. Правильная архитектура должна быть:

**Для обычных пользователей:**
- Эндпоинт: `/api/v1/quests/` (клиентский)
- Права: Доступен всем авторизованным пользователям
- Данные: Список квестов для просмотра

**Для админов:**
- Эндпоинт: `/api/v1/quests/admin/list` (админский)
- Права: Только для админов
- Данные: Полный список квестов с возможностью редактирования

### 3. Текущее поведение API (подтверждено тестами)

✅ **Обычные пользователи:**
- `/api/v1/quests/` → 200 OK (11 квестов)
- `/api/v1/quests/admin/list` → 403 Forbidden

✅ **Админы:**
- `/api/v1/quests/` → 200 OK (11 квестов)
- `/api/v1/quests/admin/list` → 200 OK (11 квестов)

### 4. Файлы, которые нужно исправить

1. **Создать новый use case для обычных пользователей:**
   - `questcity-frontend/lib/features/domain/usecases/quest/get_all_quests.dart`

2. **Создать новый метод в data source:**
   - `questcity-frontend/lib/features/data/datasources/quest_remote_data_source_impl.dart`

3. **Обновить cubit для обычных пользователей:**
   - `questcity-frontend/lib/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart`

4. **Обновить dependency injection:**
   - `questcity-frontend/lib/locator_service.dart`

## 🔧 Решение

### Шаг 1: Создать use case для обычных пользователей

```dart
// questcity-frontend/lib/features/domain/usecases/quest/get_all_quests.dart
class GetAllQuests extends UseCase<List<Map<String, dynamic>>, NoParams> {
  final QuestRepository questRepository;

  GetAllQuests(this.questRepository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(NoParams params) async {
    return await questRepository.getAllQuestsForUsers();
  }
}
```

### Шаг 2: Добавить метод в data source

```dart
// questcity-frontend/lib/features/data/datasources/quest_remote_data_source_impl.dart
Future<List<Map<String, dynamic>>> getAllQuestsForUsers() async {
  // Использовать /quests/ вместо /quests/admin/list
  final url = '$baseUrl/quests/';
  // ... остальная логика
}
```

### Шаг 3: Обновить cubit

```dart
// questcity-frontend/lib/features/presentation/pages/common/quests/quests_screen/cubit/quests_screen_cubit.dart
class QuestsScreenCubit extends Cubit<QuestsScreenState> {
  final GetAllCategories getAllCategoriesUC;
  final GetAllQuests getAllQuestsUC; // ❌ Сейчас GetAllQuestsAdmin
  // ...
}
```

## 📊 Результат после исправления

**Обычные пользователи:**
- ✅ Увидят список квестов
- ✅ Смогут просматривать квесты
- ✅ Не будут получать 403 ошибки

**Админы:**
- ✅ Продолжат видеть полный список
- ✅ Смогут редактировать квесты
- ✅ Будут использовать админский эндпоинт

## 🎯 Заключение

Проблема не в бэкенде - API работает корректно. Проблема в том, что фронтенд использует админский эндпоинт для обычных пользователей, что приводит к 403 ошибкам.

Нужно создать отдельный use case и data source метод для обычных пользователей, который будет использовать клиентский эндпоинт `/api/v1/quests/`.
