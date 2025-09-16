#!/bin/bash

# QuestCity Backend - Stop Development Services

cd "$(dirname "$0")/.."

echo "🛑 Остановка QuestCity Backend services..."

# Останавливаем сервер
if [ -f .server_pid ]; then
    SERVER_PID=$(cat .server_pid)
    echo "🔄 Остановка сервера (PID: $SERVER_PID)..."
    kill $SERVER_PID 2>/dev/null || true
    rm .server_pid
fi

# Останавливаем все uvicorn процессы
pkill -f "uvicorn app:create_app" 2>/dev/null || true

# Останавливаем Docker контейнеры
echo "🐳 Остановка Docker контейнеров..."
docker-compose down

echo "✅ Все сервисы остановлены" 