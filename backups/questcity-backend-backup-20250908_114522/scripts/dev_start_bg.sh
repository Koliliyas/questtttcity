#!/bin/bash

# QuestCity Backend - Background Development Startup
# Запуск сервера в фоновом режиме

set -e

cd "$(dirname "$0")/.."

echo "🚀 Запуск QuestCity Backend в фоновом режиме..."

# Останавливаем предыдущие процессы
echo "🔄 Остановка предыдущих процессов..."
pkill -f "uvicorn app:create_app" 2>/dev/null || true

# Запускаем БД
docker-compose up -d database
sleep 3

# Запускаем сервер в фоне
echo "🌐 Запуск сервера в фоне..."
nohup PYTHONPATH=src poetry run uvicorn app:create_app --factory --host 0.0.0.0 --port 8000 > logs/server.log 2>&1 &

SERVER_PID=$!
echo "✅ Сервер запущен с PID: $SERVER_PID"
echo "📊 Логи: tail -f logs/server.log"
echo "🌐 API: http://localhost:8000/api/docs"
echo "🛑 Остановка: kill $SERVER_PID"

# Создаем файл с PID для удобства
echo $SERVER_PID > .server_pid 