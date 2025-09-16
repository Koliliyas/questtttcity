# Отчет: Диагностика маппинга typeId и toolId

## Проблема
Пользователь сообщил, что при редактировании квеста:
- Выбрал "Download the file" (typeId = 3)
- Но в UI подставляется "Catch a ghost" (typeId = 1)

## Диагностика

### 1. Проверка данных в бэкенде ✅
Запущен скрипт `check_activity_tool_data.py`:

**Таблица 'activity':**
- ID 1: "Catch a ghost"
- ID 2: "Take a photo"  
- ID 3: "Download the file" ← Правильно
- ID 4: "Scan Qr-code"
- ID 5: "Enter the code"
- ID 6: "Enter the word"
- ID 7: "Pick up an artifact"

**Таблица 'tool':**
- ID 1: "None"
- ID 2: "Screen illustration descriptor"
- ID 3: "Beeping radar"
- ID 4: "Orbital radar"
- ID 5: "Mile orbital radar"
- ID 6: "Unlim orbital radar"
- ID 7: "Target compass"
- ID 8: "Rangefinder"
- ID 9: "Rangefinder unlim"
- ID 10: "Echolocation screen"
- ID 11: "QR scanner"
- ID 12: "Camera tool"
- ID 13: "Word locker"

### 2. Проверка маппинга во фронтенде ✅
**typeData[0].items:**
- Индекс 0: "Catch a ghost" (LocaleKeys.kTextCatchGhost.tr())
- Индекс 1: "Take a photo" (LocaleKeys.kTextTakePhoto.tr())
- Индекс 2: "Download the file" (LocaleKeys.kTextDownloadFile.tr()) ← Правильно
- Индекс 3: "Scan QR code" (LocaleKeys.kTextScanQRCode.tr())
- Индекс 4: "Enter the code" (LocaleKeys.kTextEnterCode.tr())
- Индекс 5: "Enter the word" (LocaleKeys.kTextEnterWord.tr())
- Индекс 6: "Pick artifact" (LocaleKeys.kTextPickArtifact.tr())

### 3. Проверка логики маппинга ✅
**Метод `_initializeTypeFromId`:**
```dart
case 3:
  typeArtefact = TypeArtefact.DOWNLOAD_FILE;
  selectedTypeIndexes = [[2, 0]];  // Индекс 2 = "Download the file"
  break;
```

**Метод `_initializeToolFromId`:**
```dart
int toolIndex = toolId - 1;  // Правильно: ID 1 → индекс 0
```

## Выявленные проблемы

### 1. Проблема с обновлением UI ❌
В методах `_initializeTypeFromId` и `_initializeToolFromId` не было вызова `emit()` для обновления UI после изменения состояния.

### 2. Порядок инициализации ❌
В конструкторе:
```dart
_initializeData();  // Устанавливает дефолтные значения
if (editData != null) {
  _initializeFromEditData(editData);  // Перезаписывает значения
}
```

Но UI мог не обновляться после `_initializeFromEditData`.

## Исправления

### 1. Добавлены emit() вызовы ✅
**В `_initializeTypeFromId`:**
```dart
// Обновляем UI после изменения состояния
emit(EditQuestPointScreenUpdating());
emit(EditQuestPointScreenInitial());
```

**В `_initializeToolFromId`:**
```dart
// Обновляем UI после изменения состояния
emit(EditQuestPointScreenUpdating());
emit(EditQuestPointScreenInitial());
```

### 2. Добавлена отладочная информация ✅
Добавлены print() вызовы для отслеживания:
- Значений typeId и toolId при инициализации
- Установленных selectedTypeIndexes и selectedToolsIndexes
- Состояния после каждого этапа инициализации

## Ожидаемый результат
После исправлений:
- ✅ typeId = 3 должен правильно маппиться на "Download the file" (индекс 2)
- ✅ UI должен обновляться и показывать правильный выбранный тип
- ✅ Отладочная информация поможет отследить процесс инициализации

## Тестирование
После перезапуска фронтенда нужно проверить:
1. Открыть редактирование квеста с typeId = 3
2. Убедиться, что в UI выбран "Download the file"
3. Проверить логи для подтверждения правильной инициализации
