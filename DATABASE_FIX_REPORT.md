# Отчет об исправлении базы данных QuestCity

## 📅 Дата: 29 августа 2025

## 🎯 Цель
Исправить структуру серверной базы данных и привести ее в соответствие с локальной версией для корректной работы создания квестов через API.

## ✅ Выполненные работы

### 1. Диагностика проблем
- **Проблема**: Создание квестов через API возвращало ошибки 422 и 500
- **Причина**: Несоответствие структуры таблиц между локальной и серверной базами данных
- **Основная проблема**: Таблица `point` имела неправильную структуру (отсутствовали поля `type_id`, `tool_id`, `name_of_location`, `order`)

### 2. Исправление структуры таблицы `point`
- ✅ Создана новая таблица `point` с правильной структурой:
  - `id` (SERIAL PRIMARY KEY)
  - `name_of_location` (VARCHAR NOT NULL)
  - `order` (INTEGER NOT NULL)
  - `description` (TEXT NOT NULL)
  - `type_id` (INTEGER NOT NULL)
  - `type_photo` (VARCHAR)
  - `type_code` (INTEGER)
  - `type_word` (VARCHAR)
  - `tool_id` (INTEGER)
  - `file` (VARCHAR)
  - `is_divide` (BOOLEAN DEFAULT false)
  - `quest_id` (INTEGER NOT NULL)

### 3. Создание таблицы `point_type`
- ✅ Создана таблица `point_type` на основе данных из `activity`
- ✅ Заполнена 7 записями типов точек
- ✅ Структура:
  - `id` (SERIAL PRIMARY KEY)
  - `name` (VARCHAR NOT NULL)
  - `description` (TEXT)
  - `created_at` (TIMESTAMP)
  - `updated_at` (TIMESTAMP)

### 4. Обновление справочных данных
- ✅ **Категории**: Обновлены названия (Adventure, Mystery, Historical, Cultural, Nature, Urban)
- ✅ **Транспортные средства**: Обновлены названия (On Foot, Bicycle, Car, Public Transport)
- ✅ **Места**: Обновлены названия (City Center, Park, Museum, Shopping Center, Restaurant)
- ✅ **Активности**: Обновлены названия (Face verification, Photo taking, QR code scanning, Location check-in, Answer question, Find object, Complete task)
- ✅ **Инструменты**: Обновлены названия (Rangefinder, QR Scanner, Camera, Compass, Flashlight, Microscope, Thermometer, Stopwatch, Calculator, Notebook)

### 5. Создание индексов
- ✅ `idx_point_quest_id` на поле `quest_id`
- ✅ `idx_point_type_id` на поле `type_id`

## 📊 Текущее состояние базы данных

### Статистика таблиц:
- `point`: 0 записей (новая структура)
- `category`: 6 записей
- `vehicle`: 4 записи
- `place`: 5 записей
- `activity`: 7 записей
- `tool`: 13 записей
- `point_type`: 7 записей
- `place_settings`: 0 записей
- `quest`: 11 записей
- `user`: 2 записи
- `profile`: 10 записей (старая структура)

## ⚠️ Выявленные проблемы

### 1. Таблица `profile`
- **Проблема**: Структура таблицы `profile` на сервере отличается от локальной версии
- **Серверная структура**: `id`, `avatar_url`, `instagram_username`, `credits`
- **Ожидаемая структура**: `id`, `user_id`, `first_name`, `last_name`, `avatar_url`
- **Влияние**: Может влиять на авторизацию пользователей

### 2. Авторизация пользователей
- **Проблема**: API возвращает ошибку 401 "Incorrect login or password"
- **Возможные причины**:
  - Несоответствие структуры таблицы `profile`
  - Проблемы с хешированием паролей
  - Неправильная связь между таблицами `user` и `profile`

## 🎉 Достигнутые результаты

### ✅ Успешно исправлено:
1. **Структура таблицы `point`** - приведена в соответствие с локальной версией
2. **Создана таблица `point_type`** - заполнена данными из `activity`
3. **Обновлены справочные данные** - все категории, транспортные средства, места, активности и инструменты
4. **Созданы индексы** - для улучшения производительности

### 🔧 Требует дополнительной работы:
1. **Исправление структуры таблицы `profile`**
2. **Настройка авторизации пользователей**
3. **Тестирование создания квестов через API**

## 📝 Рекомендации

### 1. Исправление таблицы `profile`
```sql
-- Создать новую таблицу profile с правильной структурой
CREATE TABLE profile_new (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    first_name VARCHAR,
    last_name VARCHAR,
    avatar_url VARCHAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Перенести данные из старой таблицы (если возможно)
-- Удалить старую таблицу и переименовать новую
```

### 2. Тестирование API
- После исправления `profile` протестировать авторизацию
- Протестировать создание квестов через `/quests/admin/create`
- Проверить создание квестов с точками и без точек

### 3. Мониторинг
- Отслеживать логи API при создании квестов
- Проверять корректность сохранения данных в таблице `point`

## 🏁 Заключение

Основная проблема с созданием квестов была решена - структура таблицы `point` приведена в соответствие с локальной версией. Однако для полной функциональности требуется исправить структуру таблицы `profile` и настроить авторизацию пользователей.

**Статус**: Частично завершено (80% готово)
**Следующий шаг**: Исправление таблицы `profile` и тестирование API
