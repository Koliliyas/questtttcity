# Отчет: Исправление проблемы с сохранением typeId и toolId

## Проблема
Пользователь сообщил, что при редактировании квеста:
- Выбирает "Download the file" (typeId = 3) в EditQuestPointScreen
- Но при сохранении квеста сохраняется typeId = 1 ("Catch a ghost")

## Диагностика

### 1. Анализ логов ✅
Из логов видно:
- Бэкенд возвращает правильные данные: `"typeId":1` для обеих точек
- Фронтенд правильно инициализирует: `typeId: 1` → `GHOST` → `selectedTypeIndexes: [[0, 0]]`
- Но проблема в том, что пользователь выбирает "Download the file" (typeId = 3), а сохраняется typeId = 1

### 2. Поиск проблемы ✅
Найдена основная проблема в `quest_edit_screen_cubit.dart`:

**В методе `_buildPointsUpdate()`:**
```dart
type: PointTypeUpdate(
  typeId: 1, // Catch a ghost - дефолтный тип ← ХАРДКОД!
  typePhoto: null,
  typeCode: null,
  typeWord: null,
),
```

Это означало, что при сохранении квеста **всегда** отправлялся `typeId: 1`, независимо от выбора пользователя.

### 3. Дополнительная проблема ✅
В `quest_edit_screen.dart` отсутствовала обработка результата из `EditQuestPointScreen`:

**QuestCreateScreen (правильно):**
```dart
onTap: () async {
  final result = await Navigator.push(...);
  if (result != null && result is PointEditData) {
    cubit.updatePointData(result);  // ✅ Обновляет данные
  }
}
```

**QuestEditScreen (неправильно):**
```dart
onTap: () => Navigator.push(...),  // ❌ Не обрабатывает результат
```

## Исправления

### 1. Исправлен хардкод в `_buildPointsUpdate()` ✅
**Было:**
```dart
type: PointTypeUpdate(
  typeId: 1, // Хардкод!
  ...
),
```

**Стало:**
```dart
// Получаем typeId и toolId из pointsData
final typeId = i < currentState.pointsData.length 
    ? currentState.pointsData[i].typeId ?? 1 
    : 1;
final toolId = i < currentState.pointsData.length 
    ? currentState.pointsData[i].toolId 
    : null;

type: PointTypeUpdate(
  typeId: typeId, // Используем реальный typeId из pointsData
  ...
),
toolId: toolId, // Используем реальный toolId из pointsData
```

### 2. Добавлена обработка результата в `quest_edit_screen.dart` ✅
**Было:**
```dart
onTap: () => Navigator.push(...),  // Не обрабатывает результат
```

**Стало:**
```dart
onTap: () async {
  final result = await Navigator.push(...);
  if (result != null && result is PointEditData) {
    cubit.updatePointData(result);  // Обрабатывает результат
  }
}
```

### 3. Добавлен метод `updatePointData()` в `QuestEditScreenCubit` ✅
```dart
void updatePointData(PointEditData data) {
  if (state is QuestEditScreenLoaded) {
    final currentState = state as QuestEditScreenLoaded;
    final updatedPointsData = List<QuestEditLocationItem>.from(currentState.pointsData);

    // Обновляем данные точки
    if (data.pointIndex < updatedPointsData.length) {
      updatedPointsData[data.pointIndex] = QuestEditLocationItem(
        updatedPointsData[data.pointIndex].title,
        typeId: data.typeId,
        toolId: data.toolId,
        // ... другие поля
      );
    }

    emit(currentState.copyWith(pointsData: updatedPointsData));
  }
}
```

## Ожидаемый результат
После исправлений:
- ✅ Пользователь выбирает "Download the file" (typeId = 3) в EditQuestPointScreen
- ✅ Данные сохраняются в `pointsData` через `updatePointData()`
- ✅ При сохранении квеста используется правильный `typeId = 3` из `pointsData`
- ✅ Бэкенд получает и сохраняет правильный `typeId = 3`

## Тестирование
После перезапуска фронтенда нужно проверить:
1. Открыть редактирование квеста
2. Выбрать точку и изменить тип на "Download the file"
3. Сохранить изменения в точке
4. Сохранить квест
5. Проверить, что в бэкенде сохранился правильный `typeId = 3`
