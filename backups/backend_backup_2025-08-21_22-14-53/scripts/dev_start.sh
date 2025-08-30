#!/bin/bash

# QuestCity Backend - Development Startup Script
# Автоматический запуск всех сервисов для разработки

set -e

echo "🚀 Запуск QuestCity Backend Development Environment"
echo "=================================================="

# Переходим в правильную директорию
cd "$(dirname "$0")/.."
echo "📁 Рабочая директория: $(pwd)"

# Проверяем Poetry
if ! command -v poetry &> /dev/null; then
    echo "❌ Poetry не установлен! Установите: brew install poetry"
    exit 1
fi

echo "📦 Проверяем Poetry environment..."
poetry install --no-dev

# Запускаем PostgreSQL
echo "🗄️ Запуск PostgreSQL..."
docker-compose up -d database

# Ждем пока БД запустится
echo "⏳ Ожидание готовности базы данных..."
sleep 5

# Проверяем миграции
echo "🔧 Проверка миграций..."
PYTHONPATH=src poetry run alembic current

# Запускаем сервер
echo "🌐 Запуск FastAPI сервера..."
echo "   API: http://localhost:8000/api/docs"
echo "   Health: http://localhost:8000/api/v1/health/"
echo ""
echo "   Для остановки: Ctrl+C"
echo "   Для фонового режима: используйте dev_start_bg.sh"
echo ""

PYTHONPATH=src poetry run uvicorn app:create_app --factory --host 0.0.0.0 --port 8000 --reload 