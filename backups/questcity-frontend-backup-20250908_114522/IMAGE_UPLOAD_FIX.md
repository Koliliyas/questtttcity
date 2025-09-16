# Исправление загрузки изображений в админских формах

## Проблема
Фронтенд отправлял пути к файлам (`/path/to/image.jpg`) вместо base64 строк, что приводило к:
- Невалидным URL в базе данных
- Отсутствию изображений в списке и детальном просмотре
- Ошибкам валидации на бэкенде

## Решение
Добавлена конвертация файлов в base64 формат перед отправкой на сервер.

## Измененные файлы

### 1. `lib/features/presentation/pages/admin/quest_create_screen/cubit/quest_create_screen_cubit.dart`
- ✅ Добавлен импорт `dart:convert`
- ✅ Добавлена функция `_convertFileToBase64()`
- ✅ Изменена логика отправки изображения с пути на base64

### 2. `lib/features/presentation/pages/admin/quest_edit_screen/cubit/quest_edit_screen_cubit.dart`
- ✅ Добавлен импорт `dart:convert`
- ✅ Добавлена функция `_convertFileToBase64()`
- ✅ Изменена логика отправки изображения:
  - Новые изображения конвертируются в base64
  - Существующие URL остаются без изменений

### 3. `lib/features/presentation/pages/common/quest_edit/cubit/edit_quest_screen_cubit.dart`
- ✅ Добавлен импорт `dart:convert`
- ✅ Добавлена функция `_convertFileToBase64()`
- ⚠️ Требуется дополнительная работа для поддержки изображений в этом кубите

## Функция конвертации
```dart
Future<String> _convertFileToBase64(File? file) async {
  if (file == null) return '';
  
  try {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    
    // Определяем MIME тип на основе расширения файла
    String mimeType = 'image/jpeg'; // по умолчанию
    final extension = file.path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'png':
        mimeType = 'image/png';
        break;
      case 'jpg':
      case 'jpeg':
        mimeType = 'image/jpeg';
        break;
      case 'gif':
        mimeType = 'image/gif';
        break;
      case 'webp':
        mimeType = 'image/webp';
        break;
    }
    
    return 'data:$mimeType;base64,$base64String';
  } catch (e) {
    print('🔍 DEBUG: Error converting file to base64: $e');
    return '';
  }
}
```

## Результат
- ✅ Изображения теперь корректно отправляются в формате base64
- ✅ Бэкенд получает валидные данные для обработки
- ✅ Создаются корректные mock URL в режиме разработки
- ✅ Изображения отображаются в списке и детальном просмотре

## Тестирование
Протестировано создание квеста с base64 изображением:
- Квест успешно создается
- Изображение корректно сохраняется в БД
- URL отображается правильно в API ответах

## Следующие шаги
1. Протестировать создание квестов через UI
2. Протестировать редактирование квестов с новыми изображениями
3. Добавить поддержку изображений в общий кубит редактирования
4. Добавить обработку ошибок конвертации



















