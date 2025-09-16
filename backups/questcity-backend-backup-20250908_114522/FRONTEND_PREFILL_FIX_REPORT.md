# Отчет: Исправление предзаполнения type и tool во фронтенде

## Проблема
Бэкенд корректно возвращает `typeId` и `toolId` в JSON ответе, но фронтенд не предзаполняет эти значения в экране редактирования точки квеста.

## Диагностика
1. **Проверка бэкенда**: ✅ Бэкенд корректно возвращает `typeId` и `toolId` в JSON
2. **Проверка моделей данных**: ❌ `PointDetailModel` не содержал поля `typeId` и `toolId`
3. **Проверка инициализации**: ❌ `EditQuestPointScreenCubit` не получал данные для предзаполнения
4. **Проверка маппинга**: ❌ Неправильные названия полей в `PointUpdateItem.fromJson`

## Исправления

### 1. Обновление PointDetailModel
**Файл**: `questcity-frontend/lib/features/data/models/quests/quest_detail_model.dart`

```dart
class PointDetailModel extends Equatable {
  final int id;
  final String nameOfLocation;
  final int order;
  final String description;  // Добавлено
  final int? typeId;         // Добавлено
  final int? toolId;         // Добавлено
  final List<PlaceModel> places;
  
  // Обновлены методы fromJson, toJson и props
}
```

### 2. Исправление маппинга в PointUpdateItem
**Файл**: `questcity-frontend/lib/features/data/models/quests/quest_update_model.dart`

```dart
factory PointUpdateItem.fromJson(Map<String, dynamic> json) =>
    PointUpdateItem(
      // ...
      type: PointTypeUpdate(typeId: json['typeId'] ?? 1), // camelCase из бэкенда
      toolId: json['toolId'], // camelCase из бэкенда
      nameOfLocation: json['name'] ?? '', // camelCase из бэкенда
      // ...
    );
```

### 3. Добавление инициализации в EditQuestPointScreenCubit
**Файл**: `questcity-frontend/lib/features/presentation/pages/common/quest_edit_point/cubit/edit_quest_point_screen_cubit.dart`

```dart
class EditQuestPointScreenCubit extends Cubit<EditQuestPointScreenState> {
  EditQuestPointScreenCubit({required this.pointIndex, PointEditData? editData})
      : super(EditQuestPointScreenInitial()) {
    _initializeData();
    if (editData != null) {
      _initializeFromEditData(editData);
    }
  }
  
  // Добавлены методы:
  // - _initializeFromEditData()
  // - _initializeTypeFromId()
  // - _initializeToolFromId()
  // - _updateChipNames()
}
```

### 4. Обновление QuestEditScreenCubit
**Файл**: `questcity-frontend/lib/features/presentation/pages/admin/quest_edit_screen/cubit/quest_edit_screen_cubit.dart`

```dart
List<QuestEditLocationItem> _getPointsData(QuestDetailModel quest) {
  if (quest.points.isNotEmpty) {
    return quest.points
        .map((point) => QuestEditLocationItem(
              point.nameOfLocation,
              typeId: point.typeId,  // Добавлено
              toolId: point.toolId,  // Добавлено
            ))
        .toList();
  }
  // ...
}
```

### 5. Обновление EditQuestPointScreen
**Файл**: `questcity-frontend/lib/features/presentation/pages/common/quest_edit_point/edit_quest_point_screen.dart`

```dart
class EditQuestPointScreen extends StatelessWidget {
  const EditQuestPointScreen({
    super.key, 
    required this.pointIndex,
    this.editData,  // Добавлено
  });

  final int pointIndex;
  final PointEditData? editData;  // Добавлено
}
```

### 6. Обновление передачи данных
**Файл**: `questcity-frontend/lib/features/presentation/pages/admin/quest_edit_screen/quest_edit_screen.dart`

```dart
EditQuestPointScreen(
  pointIndex: index,
  editData: PointEditData(
    pointIndex: index,
    typeId: pointData[index].typeId,
    toolId: pointData[index].toolId,
  ),
)
```

## Маппинг ID на UI элементы

### Типы активности (typeId):
- `1` → "Catch a ghost" (GHOST)
- `2` → "Take a photo" (PHOTO)  
- `3` → "Download file" (DOWNLOAD_FILE)
- `4` → "Scan QR code" (QR)
- `5` → "Enter code" (CODE)
- `6` → "Enter word" (WORD)
- `7` → "Pick artifact" (ARTIFACTS)

### Инструменты (toolId):
- `1` → "None"
- `2` → "Screen illustration descriptor"
- `3` → "Beeping radar"
- `4` → "Orbital radar"
- `5` → "Mile orbital radar"
- `6` → "Unlim orbital radar"
- `7` → "Target compass"
- `8` → "Rangefinder"
- `9` → "Rangefinder unlim"
- `10` → "Echolocation screen"
- `11` → "QR scanner"
- `12` → "Camera tool"
- `13` → "Word locker"

## Результат
✅ **ИСПРАВЛЕНО** - При редактировании точки квеста теперь корректно предзаполняются:
- Выбранный тип активности (type)
- Выбранный инструмент (tool)

Данные берутся из бэкенда и правильно маппятся на UI элементы.
