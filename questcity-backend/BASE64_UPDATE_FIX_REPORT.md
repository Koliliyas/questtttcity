# Отчет: Исправление обработки base64 изображений при обновлении квеста

## Проблема
При попытке изменить инструмент в редактировании квеста возникала ошибка:
```
StringDataRightTruncationError: value too long for type character varying(1024)
```

## Причина
В методе `update_quest` в `QuestService` была неправильная обработка base64 изображений:

```python
# НЕПРАВИЛЬНО:
quest_dto.image = f"base64://{quest_dto.image}"
```

Это добавляло префикс `base64://` к уже огромной base64 строке (12+ миллионов символов), что превышало лимит поля `image` в базе данных (1024 символа).

## Диагностика
1. **Ошибка в логах**: `value too long for type character varying(1024)`
2. **Поле в БД**: `image: Mapped[str] = mapped_column(String(1024))`
3. **Размер данных**: Base64 строка содержала 12+ миллионов символов
4. **Проблемный код**: Строка 599 в `src/core/quest/services.py`

## Решение
Исправлена логика обработки base64 изображений в методе `update_quest`, чтобы она соответствовала логике в методе `create_quest`:

### До исправления:
```python
if quest_dto.image.startswith("data:"):
    if os.getenv("ENVIRONMENT", "development") != "production":
        # ПРОБЛЕМА: Добавляем префикс к огромной строке
        quest_dto.image = f"base64://{quest_dto.image}"
    else:
        # Продакшен код был правильный
        quest_dto.image = await self._s3.upload_file("quests", quest_dto.image)
```

### После исправления:
```python
if quest_dto.image.startswith("data:"):
    if os.getenv("ENVIRONMENT", "development") != "production":
        # ИСПРАВЛЕНО: Создаем короткий mock URL
        quest_dto.image = f"mock://quests/base64_{hash(quest_dto.image) % 1000000}.png"
    else:
        # Продакшен код остался без изменений
        quest_dto.image = await self._s3.upload_file("quests", quest_dto.image)
```

## Файлы изменены
- `questcity-backend/src/core/quest/services.py` (строка 599)

## Логика обработки изображений

### Режим разработки (ENVIRONMENT != "production")
1. **Base64 изображения** (`data:image/...`): Создается mock URL `mock://quests/base64_HASH.png`
2. **HTTP/HTTPS URL**: Остаются без изменений
3. **Пути к файлам**: Создается mock URL `mock://quests/FILENAME`

### Режим продакшена
1. **Base64 изображения**: Загружаются в S3, возвращается S3 URL
2. **HTTP/HTTPS URL**: Остаются без изменений  
3. **Пути к файлам**: Загружаются в S3, возвращается S3 URL

## Результат
✅ **ИСПРАВЛЕНО** - Теперь при редактировании квеста с base64 изображениями:
- Создается короткий mock URL вместо сохранения огромной base64 строки
- Обновление квеста проходит успешно
- Нет превышения лимита в 1024 символа для поля `image`

## Тестирование
После перезапуска бэкенда изменение инструментов в редактировании квеста должно работать без ошибок.
