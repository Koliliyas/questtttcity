-- SQL скрипт для исправления структуры серверной базы данных QuestCity
-- Версия 2.0 - исправлены синтаксические ошибки

-- ============================================================================
-- 1. ИСПРАВЛЕНИЕ СТРУКТУРЫ ТАБЛИЦЫ point
-- ============================================================================

-- Создаем временную таблицу для сохранения данных
CREATE TABLE IF NOT EXISTS point_temp (
    id SERIAL PRIMARY KEY,
    name_of_location VARCHAR NOT NULL,
    "order" INTEGER NOT NULL,
    description TEXT NOT NULL,
    type_id INTEGER NOT NULL,
    type_photo VARCHAR,
    type_code INTEGER,
    type_word VARCHAR,
    tool_id INTEGER,
    file VARCHAR,
    is_divide BOOLEAN,
    quest_id INTEGER NOT NULL
);

-- Копируем существующие данные в временную таблицу (если есть)
INSERT INTO point_temp (id, name_of_location, "order", description, type_id, tool_id, quest_id)
SELECT 
    id,
    COALESCE(name, 'Unknown Location') as name_of_location,
    COALESCE(order_index, 1) as "order",
    COALESCE(description, 'No description') as description,
    1 as type_id,
    NULL as tool_id,
    quest_id
FROM point;

-- Удаляем старую таблицу point
DROP TABLE IF EXISTS point;

-- Переименовываем временную таблицу
ALTER TABLE point_temp RENAME TO point;

-- ============================================================================
-- 2. СОЗДАНИЕ ТАБЛИЦЫ point_type
-- ============================================================================

-- Создаем таблицу point_type на основе данных из activity
CREATE TABLE IF NOT EXISTS point_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Заполняем point_type данными из activity
INSERT INTO point_type (id, name, description)
SELECT id, name, description FROM activity
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 3. СОЗДАНИЕ ТАБЛИЦЫ place_settings
-- ============================================================================

CREATE TABLE IF NOT EXISTS place_settings (
    id SERIAL PRIMARY KEY,
    point_id INTEGER NOT NULL,
    longitude REAL NOT NULL,
    latitude REAL NOT NULL,
    detections_radius INTEGER DEFAULT 5,
    height INTEGER DEFAULT 0,
    interaction_inaccuracy INTEGER DEFAULT 5,
    part INTEGER DEFAULT 1,
    random_occurrence INTEGER DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 4. ОБНОВЛЕНИЕ ДАННЫХ СПРАВОЧНЫХ ТАБЛИЦ
-- ============================================================================

-- Обновляем данные категорий
UPDATE category SET 
    name = CASE 
        WHEN id = 1 THEN 'Adventure'
        WHEN id = 2 THEN 'Mystery'
        WHEN id = 3 THEN 'Historical'
        WHEN id = 4 THEN 'Cultural'
        WHEN id = 5 THEN 'Nature'
        WHEN id = 6 THEN 'Urban'
        WHEN id = 7 THEN 'Technology'
        WHEN id = 8 THEN 'Art'
        ELSE name
    END
WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8);

-- Добавляем недостающие категории
INSERT INTO category (id, name, image_url) VALUES
(7, 'Technology', 'https://example.com/technology.jpg'),
(8, 'Art', 'https://example.com/art.jpg')
ON CONFLICT (id) DO NOTHING;

-- Обновляем данные транспортных средств
UPDATE vehicle SET 
    name = CASE 
        WHEN id = 1 THEN 'On Foot'
        WHEN id = 2 THEN 'Bicycle'
        WHEN id = 3 THEN 'Car'
        WHEN id = 4 THEN 'Public Transport'
        WHEN id = 5 THEN 'Motorcycle'
        WHEN id = 6 THEN 'Boat'
        ELSE name
    END
WHERE id IN (1, 2, 3, 4, 5, 6);

-- Добавляем недостающие транспортные средства
INSERT INTO vehicle (id, name) VALUES
(5, 'Motorcycle'),
(6, 'Boat')
ON CONFLICT (id) DO NOTHING;

-- Обновляем данные мест
UPDATE place SET 
    name = CASE 
        WHEN id = 1 THEN 'City Center'
        WHEN id = 2 THEN 'Park'
        WHEN id = 3 THEN 'Museum'
        WHEN id = 4 THEN 'Shopping Center'
        WHEN id = 5 THEN 'Restaurant'
        WHEN id = 6 THEN 'Library'
        WHEN id = 7 THEN 'University'
        WHEN id = 8 THEN 'Hospital'
        WHEN id = 9 THEN 'Airport'
        WHEN id = 10 THEN 'Beach'
        ELSE name
    END
WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

-- Добавляем недостающие места
INSERT INTO place (id, name) VALUES
(6, 'Library'),
(7, 'University'),
(8, 'Hospital'),
(9, 'Airport'),
(10, 'Beach')
ON CONFLICT (id) DO NOTHING;

-- Обновляем данные активностей
UPDATE activity SET 
    name = CASE 
        WHEN id = 1 THEN 'Face verification'
        WHEN id = 2 THEN 'Photo taking'
        WHEN id = 3 THEN 'QR code scanning'
        WHEN id = 4 THEN 'Location check-in'
        WHEN id = 5 THEN 'Answer question'
        WHEN id = 6 THEN 'Find object'
        WHEN id = 7 THEN 'Complete task'
        WHEN id = 8 THEN 'Take video'
        WHEN id = 9 THEN 'Record audio'
        WHEN id = 10 THEN 'Solve puzzle'
        ELSE name
    END,
    description = CASE 
        WHEN id = 1 THEN 'Verify your face at the location'
        WHEN id = 2 THEN 'Take a photo at the location'
        WHEN id = 3 THEN 'Scan QR code at the location'
        WHEN id = 4 THEN 'Check in at the location'
        WHEN id = 5 THEN 'Answer a question about the location'
        WHEN id = 6 THEN 'Find a specific object at the location'
        WHEN id = 7 THEN 'Complete a specific task'
        WHEN id = 8 THEN 'Record a video at the location'
        WHEN id = 9 THEN 'Record audio at the location'
        WHEN id = 10 THEN 'Solve a puzzle at the location'
        ELSE description
    END
WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

-- Добавляем недостающие активности
INSERT INTO activity (id, name, description) VALUES
(8, 'Take video', 'Record a video at the location'),
(9, 'Record audio', 'Record audio at the location'),
(10, 'Solve puzzle', 'Solve a puzzle at the location')
ON CONFLICT (id) DO NOTHING;

-- Обновляем данные инструментов
UPDATE tool SET 
    name = CASE 
        WHEN id = 1 THEN 'Rangefinder'
        WHEN id = 2 THEN 'QR Scanner'
        WHEN id = 3 THEN 'Camera'
        WHEN id = 4 THEN 'Compass'
        WHEN id = 5 THEN 'Flashlight'
        WHEN id = 6 THEN 'Microscope'
        WHEN id = 7 THEN 'Thermometer'
        WHEN id = 8 THEN 'Stopwatch'
        WHEN id = 9 THEN 'Calculator'
        WHEN id = 10 THEN 'Notebook'
        ELSE name
    END
WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

-- Добавляем недостающие инструменты
INSERT INTO tool (id, name, image_url) VALUES
(11, 'Microscope', 'https://example.com/microscope.jpg'),
(12, 'Thermometer', 'https://example.com/thermometer.jpg'),
(13, 'Stopwatch', 'https://example.com/stopwatch.jpg')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 5. ФИНАЛЬНЫЕ ИСПРАВЛЕНИЯ
-- ============================================================================

-- Обновляем type_id в таблице point на основе данных из point_type
UPDATE point SET type_id = 1 WHERE type_id IS NULL OR type_id = 0;

-- Устанавливаем правильные значения по умолчанию
UPDATE point SET 
    type_photo = NULL,
    type_code = NULL,
    type_word = NULL,
    tool_id = NULL,
    file = NULL,
    is_divide = false
WHERE type_photo IS NULL OR type_code IS NULL OR type_word IS NULL OR tool_id IS NULL OR file IS NULL OR is_divide IS NULL;

-- ============================================================================
-- 6. СОЗДАНИЕ ИНДЕКСОВ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- ============================================================================

-- Создаем индексы для улучшения производительности
CREATE INDEX IF NOT EXISTS idx_point_quest_id ON point(quest_id);
CREATE INDEX IF NOT EXISTS idx_point_type_id ON point(type_id);
CREATE INDEX IF NOT EXISTS idx_place_settings_point_id ON place_settings(point_id);
CREATE INDEX IF NOT EXISTS idx_quest_category_id ON quest(category_id);
CREATE INDEX IF NOT EXISTS idx_quest_place_id ON quest(place_id);

-- ============================================================================
-- 7. ПРОВЕРКА РЕЗУЛЬТАТОВ
-- ============================================================================

-- Выводим статистику после исправлений
SELECT 'point' as table_name, COUNT(*) as record_count FROM point
UNION ALL
SELECT 'category', COUNT(*) FROM category
UNION ALL
SELECT 'vehicle', COUNT(*) FROM vehicle
UNION ALL
SELECT 'place', COUNT(*) FROM place
UNION ALL
SELECT 'activity', COUNT(*) FROM activity
UNION ALL
SELECT 'tool', COUNT(*) FROM tool
UNION ALL
SELECT 'point_type', COUNT(*) FROM point_type
UNION ALL
SELECT 'place_settings', COUNT(*) FROM place_settings
UNION ALL
SELECT 'quest', COUNT(*) FROM quest
ORDER BY table_name;

