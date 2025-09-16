#!/bin/bash

# QuestCity Backend - API Testing Script

cd "$(dirname "$0")/.."

echo "🧪 Тестирование QuestCity Backend API"
echo "==================================="

# Проверяем что сервер запущен
if ! curl -s http://localhost:8000/api/v1/health/ > /dev/null; then
    echo "❌ Сервер не запущен! Запустите: ./scripts/dev_start.sh"
    exit 1
fi

echo "✅ Сервер доступен"

# Запускаем тесты
echo "🔐 Тестирование авторизации..."
PYTHONPATH=src poetry run python test_auth.py

echo ""
echo "🌐 Полезные ссылки:"
echo "   API Docs: http://localhost:8000/api/docs"
echo "   Health: http://localhost:8000/api/v1/health/"
echo "   Health Detailed: http://localhost:8000/api/v1/health/detailed" 