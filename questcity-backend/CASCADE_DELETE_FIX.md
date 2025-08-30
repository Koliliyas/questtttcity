# Исправление каскадного удаления квестов

## Проблема
При попытке удалить квест с ID 48 возникает ошибка:
```
ForeignKeyViolationError: update or delete on table "quest" violates foreign key constraint "fk_point_quest_id_quest" on table "point"
```

## Причина
В базе данных внешние ключи для связанных таблиц (`point`, `merch`, `review`) не имеют каскадного удаления.

## Решение

### 1. Применить SQL скрипт для исправления БД

Выполните SQL скрипт `fix_cascade_delete.sql` в вашей базе данных:

```bash
# Для PostgreSQL
psql -h localhost -U your_username -d your_database -f fix_cascade_delete.sql

# Или через pgAdmin/DBeaver
# Скопируйте содержимое файла fix_cascade_delete.sql и выполните
```

### 2. Проверка исправления

После выполнения скрипта проверьте, что ограничения созданы правильно:

```sql
SELECT 
    tc.table_name, 
    tc.constraint_name, 
    rc.delete_rule
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.referential_constraints AS rc
      ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name IN ('merch', 'point', 'review')
    AND rc.delete_rule = 'CASCADE';
```

Должны быть результаты для всех трех таблиц с `delete_rule = 'CASCADE'`.

### 3. Тестирование

После применения исправления попробуйте удалить квест через API:

```bash
curl -X DELETE "http://localhost:8000/api/v1/quests/admin/delete/48" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## Измененные файлы

1. **`create_tables.sql`** - обновлена схема для новых развертываний
2. **`fix_cascade_delete.sql`** - скрипт для исправления существующей БД
3. **`src/core/quest/services.py`** - упрощен метод delete_quest
4. **`src/db/models/quest/quest.py`** - обновлен cascade в модели

## Результат

После применения исправления:
- ✅ Квесты можно удалять без ошибок
- ✅ Связанные точки удаляются автоматически
- ✅ Связанный мерч удаляется автоматически  
- ✅ Связанные отзывы удаляются автоматически
- ✅ Все операции выполняются в одной транзакции








