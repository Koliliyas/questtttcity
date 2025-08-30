-- Простой скрипт для исправления таблицы point

-- Удаляем старую таблицу point
DROP TABLE IF EXISTS point;

-- Создаем новую таблицу point с правильной структурой
CREATE TABLE point (
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
    is_divide BOOLEAN DEFAULT false,
    quest_id INTEGER NOT NULL
);

-- Создаем таблицу point_type
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

-- Создаем таблицу place_settings
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

-- Создаем индексы
CREATE INDEX IF NOT EXISTS idx_point_quest_id ON point(quest_id);
CREATE INDEX IF NOT EXISTS idx_point_type_id ON point(type_id);
CREATE INDEX IF NOT EXISTS idx_place_settings_point_id ON place_settings(point_id);

-- Проверяем результат
SELECT 'point' as table_name, COUNT(*) as record_count FROM point
UNION ALL
SELECT 'point_type', COUNT(*) FROM point_type
UNION ALL
SELECT 'place_settings', COUNT(*) FROM place_settings
ORDER BY table_name;

