-- Создание таблиц для QuestCity
-- Этот скрипт создает все необходимые таблицы для работы приложения

-- Таблица активностей (типов заданий)
CREATE TABLE IF NOT EXISTS activity (
    id SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL
);

-- Таблица категорий
CREATE TABLE IF NOT EXISTS category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(16) UNIQUE NOT NULL,
    image VARCHAR(1024) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL
);

-- Таблица мест
CREATE TABLE IF NOT EXISTS place (
    id SERIAL PRIMARY KEY,
    name VARCHAR(16) UNIQUE NOT NULL
);

-- Таблица инструментов
CREATE TABLE IF NOT EXISTS tool (
    id SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL,
    image VARCHAR(1024) NOT NULL
);

-- Таблица типов транспорта
CREATE TABLE IF NOT EXISTS vehicle (
    id SERIAL PRIMARY KEY,
    name VARCHAR(16) UNIQUE NOT NULL
);

-- Таблица профилей пользователей (если не существует)
CREATE TABLE IF NOT EXISTS profile (
    id SERIAL PRIMARY KEY,
    instagram_username VARCHAR(1024) NOT NULL DEFAULT '',
    credits INTEGER NOT NULL DEFAULT 0
);

-- Таблица квестов
CREATE TABLE IF NOT EXISTS quest (
    id SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    image VARCHAR(1024) NOT NULL,
    mentor_preference VARCHAR(1024) NOT NULL,
    auto_accrual BOOLEAN NOT NULL,
    cost INTEGER NOT NULL,
    reward INTEGER NOT NULL,
    category_id INTEGER NOT NULL REFERENCES category(id),
    "group" VARCHAR(20) CHECK ("group" IN ('TWO', 'THREE', 'FOUR')),
    vehicle_id INTEGER NOT NULL REFERENCES vehicle(id),
    is_subscription BOOLEAN NOT NULL,
    pay_extra INTEGER NOT NULL,
    timeframe VARCHAR(20) CHECK (timeframe IN ('ONE_HOUR', 'THREE_HOURS', 'TEN_HOURS', 'DAY')),
    level VARCHAR(20) NOT NULL CHECK (level IN ('EASY', 'MIDDLE', 'HARD')),
    milage VARCHAR(30) NOT NULL CHECK (milage IN ('UP_TO_TEN', 'UP_TO_THIRTY', 'UP_TO_HUNDRED', 'MORE_THAN_HUNDRED')),
    place_id INTEGER NOT NULL REFERENCES place(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL
);

-- Таблица мерча
CREATE TABLE IF NOT EXISTS merch (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    price FLOAT NOT NULL,
    image VARCHAR(1024) NOT NULL,
    quest_id INTEGER NOT NULL REFERENCES quest(id) ON DELETE CASCADE
);

-- Таблица точек квеста
CREATE TABLE IF NOT EXISTS point (
    id SERIAL PRIMARY KEY,
    name_of_location VARCHAR(32) NOT NULL,
    "order" INTEGER NOT NULL,
    description TEXT NOT NULL,
    type_id INTEGER NOT NULL REFERENCES activity(id),
    type_photo VARCHAR(20) CHECK (type_photo IN ('FACE_VERIFICATION', 'DIRECTION_CHECK', 'MATCHING')),
    type_code INTEGER,
    type_word VARCHAR(32),
    tool_id INTEGER REFERENCES tool(id),
    file VARCHAR(1024),
    is_divide BOOLEAN,
    quest_id INTEGER NOT NULL REFERENCES quest(id) ON DELETE CASCADE
);

-- Таблица настроек мест
CREATE TABLE IF NOT EXISTS place_settings (
    id SERIAL PRIMARY KEY,
    longitude FLOAT NOT NULL,
    latitude FLOAT NOT NULL,
    detections_radius FLOAT NOT NULL,
    height FLOAT NOT NULL,
    random_occurrence FLOAT,
    interaction_inaccuracy FLOAT NOT NULL,
    part INTEGER,
    point_id INTEGER NOT NULL REFERENCES point(id)
);

-- Таблица отзывов
CREATE TABLE IF NOT EXISTS review (
    id SERIAL PRIMARY KEY,
    review TEXT NOT NULL,
    rating INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', now()) NOT NULL,
    owner_id INTEGER NOT NULL REFERENCES profile(id),
    quest_id INTEGER NOT NULL REFERENCES quest(id) ON DELETE CASCADE
);

-- Создание индексов для улучшения производительности
CREATE INDEX IF NOT EXISTS idx_quest_category_id ON quest(category_id);
CREATE INDEX IF NOT EXISTS idx_quest_vehicle_id ON quest(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_quest_place_id ON quest(place_id);
CREATE INDEX IF NOT EXISTS idx_point_quest_id ON point(quest_id);
CREATE INDEX IF NOT EXISTS idx_point_type_id ON point(type_id);
CREATE INDEX IF NOT EXISTS idx_point_tool_id ON point(tool_id);
CREATE INDEX IF NOT EXISTS idx_merch_quest_id ON merch(quest_id);
CREATE INDEX IF NOT EXISTS idx_review_quest_id ON review(quest_id);
CREATE INDEX IF NOT EXISTS idx_review_owner_id ON review(owner_id);

-- Комментарии к таблицам
COMMENT ON TABLE activity IS 'Типы активностей для точек квеста';
COMMENT ON TABLE category IS 'Категории квестов';
COMMENT ON TABLE place IS 'Места проведения квестов';
COMMENT ON TABLE tool IS 'Инструменты для выполнения заданий';
COMMENT ON TABLE vehicle IS 'Типы транспорта для квестов';
COMMENT ON TABLE quest IS 'Основная таблица квестов';
COMMENT ON TABLE merch IS 'Мерч квестов';
COMMENT ON TABLE point IS 'Точки квеста';
COMMENT ON TABLE place_settings IS 'Настройки мест для точек квеста';
COMMENT ON TABLE review IS 'Отзывы пользователей о квестах';
COMMENT ON TABLE profile IS 'Профили пользователей';
