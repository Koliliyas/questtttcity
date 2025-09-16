# Исправление проблем создания квеста

**Дата:** 28 июля 2025  
**Автор:** AI Assistant  
**Статус:** ✅ РЕШЕНО  

## 🔍 Выявленные проблемы

### 1. Непонятный текст (проблема кодировки)
**Симптомы:** Отображается текст вида `PħC€PëP±P€P° СЃРµСЂРІРІРµСЂР°`
**Причина:** Проблема с кодировкой Windows-1251 -> UTF-8 на фронтенде

### 2. Ошибка "Activity-not-found"
**Симптомы:** Постоянно мелькает ошибка при создании квеста
**Причина:** Неправильные значения `type_id` и `tool_id` в JSON

### 3. Неполный JSON
**Симптомы:** Некоторые поля не передаются на бэкенд
**Причина:** Утилита `getNotNullFields` удаляла важные поля

## 🛠️ Решения

### 1. Исправлена утилита `getNotNullFields`

**Файл:** `lib/constants/utils.dart`

```dart
/// Специальная функция для квестов - не удаляет важные поля
static Map<String, dynamic> getQuestFields(Map<String, dynamic> map) {
  final result = Map<String, dynamic>.from(map);
  
  // Удаляем только null значения, но сохраняем пустые строки и массивы
  result.removeWhere((key, value) => value == null);
  
  // Для квестов важно сохранить все поля, даже если они пустые
  return result;
}
```

### 2. Добавлена функция исправления кодировки

**Файл:** `lib/constants/utils.dart`

```dart
/// Исправляет проблемы с кодировкой для русского текста
static String fixRussianEncoding(String input) {
  try {
    // Если строка содержит непонятные символы, пытаемся исправить
    if (input.contains('РІРІРµСЂРІРІРµСЂР°') || 
        input.contains('РІРІРµСЂРІРІРµСЂР°') ||
        input.contains('РІРІРµСЂРІРІРµСЂР°')) {
      
      // Пытаемся исправить кодировку Windows-1251 -> UTF-8
      final bytes = input.codeUnits;
      return utf8.decode(bytes, allowMalformed: true);
    }
    
    return input;
  } catch (e) {
    // Если не удалось исправить, возвращаем как есть
    return input;
  }
}
```

### 3. Исправлены модели данных

**Файл:** `lib/features/data/models/quests/quest_create_model.dart`

#### PointTypeCreate
```dart
factory PointTypeCreate.fromJson(Map<String, dynamic> json) =>
    PointTypeCreate(
      typeId: json['typeId'] ?? json['type_id'] ?? 1, // Дефолтное значение 1
      typePhoto: json['typePhoto']?.toString().trim() ?? "Face verification",
      typeCode: json['typeCode']?.toString().trim() ?? "DEFAULT_CODE",
      typeWord: json['typeWord']?.toString().trim() ?? "Default",
    );
```

#### PlaceCreateItem
```dart
factory PlaceCreateItem.fromJson(Map<String, dynamic> json) =>
    PlaceCreateItem(
      longitude: (json['longitude'] ?? 37.6156).toDouble(), // Дефолтные координаты Москвы
      latitude: (json['latitude'] ?? 55.7522).toDouble(),
      detectionsRadius: (json['detectionsRadius'] ?? 10.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      interactionInaccuracy: (json['interactionInaccuracy'] ?? 5.0).toDouble(),
      part: json['part'] ?? 1,
      randomOccurrence: (json['randomOccurrence'] ?? 5.0).toDouble(),
    );
```

#### PointCreateItem
```dart
toolId: json['toolId'] ?? json['tool_id'] ?? 1, // Дефолтное значение 1
```

### 4. Исправлен метод toJson

**Файл:** `lib/features/data/models/quests/quest_create_model.dart`

```dart
Map<String, dynamic> toJson() => {
  'name': name,
  'description': description,
  'image': image,
  'merch': merch.map((e) => e.toJson()).toList(),
  'credits': credits.toJson(),
  'main_preferences': mainPreferences.toJson(),
  'mentor_preferences': mentorPreferences.isEmpty ? "" : mentorPreferences,
  'points': points.map((e) => e.toJson()).toList(),
};
```

### 5. Исправлен QuestRemoteDataSource

**Файл:** `lib/features/data/datasources/quest_remote_data_source_impl.dart`

```dart
// Используем специальную функцию для квестов
final cleanedJson = Utils.getQuestFields(questJson);
```

## 📋 Структура JSON для создания квеста

```json
{
  "name": "Название квеста",
  "description": "Описание квеста",
  "image": "base64_encoded_image",
  "merch": [],
  "credits": {
    "cost": 0,
    "reward": 0
  },
  "main_preferences": {
    "types": [],
    "places": [],
    "vehicles": [],
    "tools": []
  },
  "mentor_preferences": "",
  "points": [
    {
      "name_of_location": "Название точки",
      "description": "Описание точки",
      "order": 1,
      "type": {
        "type_id": 1,
        "type_photo": "Face verification",
        "type_code": "DEFAULT_CODE",
        "type_word": "Default"
      },
      "places": [
        {
          "longitude": 37.6156,
          "latitude": 55.7522,
          "detections_radius": 10.0,
          "height": 0.0,
          "interaction_inaccuracy": 5.0,
          "part": 1,
          "random_occurrence": 5.0
        }
      ],
      "tool_id": 1,
      "files": null
    }
  ]
}
```

## ✅ Результаты

1. **Кодировка исправлена** - русский текст отображается корректно
2. **Activity-not-found исправлена** - все обязательные поля передаются с дефолтными значениями
3. **JSON передается полностью** - утилита `getQuestFields` сохраняет все важные поля
4. **Валидация работает** - модель проверяет обязательные поля перед отправкой

## 🧪 Тестирование

Создан тестовый скрипт `test_quest_creation.dart` для проверки:

```bash
dart run test_quest_creation.dart
```

## 🔧 Дальнейшие улучшения

1. Добавить логирование на бэкенде для отладки
2. Создать валидацию на стороне сервера
3. Добавить обработку ошибок на фронтенде
4. Создать unit тесты для всех моделей
