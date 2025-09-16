#!/bin/bash

# Скрипт развертывания QuestCity Backend на Timeweb Cloud
# Использование: ./deploy.sh

set -e

echo "🚀 Начинаем развертывание QuestCity Backend на Timeweb Cloud..."

# Проверка наличия необходимых файлов
if [ ! -f "env.production.example" ]; then
    echo "❌ Файл env.production.example не найден"
    exit 1
fi

# Создание .env файла если его нет
if [ ! -f ".env.production" ]; then
    echo "📝 Создаем файл .env.production из примера..."
    cp env.production.example .env.production
    echo "⚠️  ВНИМАНИЕ: Отредактируйте .env.production с реальными данными от Timeweb Cloud"
    echo "   - Настройки базы данных PostgreSQL"
    echo "   - Настройки S3 хранилища"
    echo "   - Настройки домена и SSL"
    exit 1
fi

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен"
    exit 1
fi

# Сборка Docker образа
echo "🔨 Собираем Docker образ..."
docker build -f deploy/Dockerfile -t questcity-backend:latest .

echo "✅ Docker образ собран успешно"

# Создание docker-compose файла для production
cat > docker-compose.production.yml << EOF
version: '3.8'

services:
  questcity-backend:
    image: questcity-backend:latest
    container_name: questcity-backend
    restart: unless-stopped
    env_file:
      - .env.production
    ports:
      - "8000:8000"
    volumes:
      - ./logs:/app/logs
      - ./certs:/app/certs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
EOF

echo "📋 Создан docker-compose.production.yml"

# Запуск приложения
echo "🚀 Запускаем приложение..."
docker-compose -f docker-compose.production.yml up -d

echo "✅ Развертывание завершено!"
echo ""
echo "📊 Статус сервисов:"
docker-compose -f docker-compose.production.yml ps

echo ""
echo "📝 Следующие шаги:"
echo "1. Настройте домен и SSL в панели Timeweb Cloud"
echo "2. Настройте балансировщик нагрузки если необходимо"
echo "3. Настройте мониторинг и логирование"
echo "4. Выполните миграции базы данных:"
echo "   docker-compose -f docker-compose.production.yml exec questcity-backend alembic upgrade head"
echo ""
echo "🔗 API будет доступен по адресу: http://your-server-ip:8000"
echo "📚 Документация API: http://your-server-ip:8000/docs"











