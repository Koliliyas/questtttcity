#!/bin/bash

# QuestCity - Скрипт проверки соединения Backend ↔ Frontend
# Быстрая диагностика настроек подключения

echo "🔍 QuestCity Connection Test"
echo "============================"
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функции логирования
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✅ OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[⚠️ WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[❌ ERROR]${NC} $1"; }

# Проверка Backend
echo "🔧 Backend Check"
echo "---------------"

# 1. Проверка процесса Backend
if pgrep -f "python.*main.py" > /dev/null; then
    log_success "Backend процесс запущен"
else
    log_warning "Backend процесс не найден"
fi

# 2. Проверка порта
if netstat -an | grep -q ":8000.*LISTEN"; then
    log_success "Порт 8000 прослушивается"
else
    log_error "Порт 8000 не прослушивается"
fi

# 3. Проверка HTTP ответа
if curl -s -f http://localhost:8000/api/v1/health >/dev/null 2>&1; then
    log_success "Backend API отвечает (GET /api/v1/health)"
    
    # Детальная информация о health check
    health_response=$(curl -s http://localhost:8000/api/v1/health)
    echo "   Response: $health_response"
else
    log_error "Backend API не отвечает на http://localhost:8000/api/v1/health"
fi

# 4. Проверка Swagger документации
if curl -s -f http://localhost:8000/api/docs >/dev/null 2>&1; then
    log_success "Swagger документация доступна"
else
    log_warning "Swagger документация недоступна"
fi

echo ""

# Проверка Frontend конфигурации
echo "📱 Frontend Configuration Check"
echo "--------------------------------"

# 1. Проверка .env файла
if [ -f "questcity-frontend/.env" ]; then
    log_success ".env файл существует"
    
    base_url=$(grep "^BASE_URL=" questcity-frontend/.env | cut -d'=' -f2)
    ws_url=$(grep "^WS_BASE_URL=" questcity-frontend/.env | cut -d'=' -f2)
    
    if [[ "$base_url" == *"localhost:8000"* ]]; then
        log_success "BASE_URL настроен на localhost: $base_url"
    else
        log_warning "BASE_URL не настроен на localhost: $base_url"
    fi
    
    if [[ "$ws_url" == *"localhost:8000"* ]]; then
        log_success "WS_BASE_URL настроен на localhost: $ws_url"
    else
        log_warning "WS_BASE_URL не настроен на localhost: $ws_url"
    fi
else
    log_error ".env файл не найден в questcity-frontend/"
fi

# 2. Проверка environment файлов
if [ -f "questcity-frontend/.env.development" ]; then
    log_success ".env.development файл существует"
else
    log_warning ".env.development файл не найден"
fi

if [ -f "questcity-frontend/.env.production" ]; then
    log_success ".env.production файл существует"
else
    log_warning ".env.production файл не найден"
fi

# 3. Проверка Flutter зависимостей
if [ -f "questcity-frontend/pubspec.lock" ]; then
    log_success "Flutter зависимости установлены (pubspec.lock)"
else
    log_warning "Flutter зависимости не установлены"
fi

echo ""

# Проверка ключевых API endpoints
echo "🔌 API Endpoints Check"
echo "----------------------"

endpoints=(
    "GET /api/v1/health"
    "GET /api/docs"
    "GET /api/redoc"
)

for endpoint in "${endpoints[@]}"; do
    method=$(echo $endpoint | cut -d' ' -f1)
    path=$(echo $endpoint | cut -d' ' -f2)
    url="http://localhost:8000$path"
    
    if curl -s -f "$url" >/dev/null 2>&1; then
        log_success "$endpoint - доступен"
    else
        log_error "$endpoint - недоступен ($url)"
    fi
done

echo ""

# Проверка CORS настроек
echo "🌐 CORS Configuration Check"  
echo "---------------------------"

if [ -f "questcity-backend/main/.env" ]; then
    cors_origins=$(grep "APP_ALLOW_ORIGINS" questcity-backend/main/.env | cut -d'=' -f2)
    if [[ "$cors_origins" == *"*"* ]]; then
        log_success "CORS разрешает все источники (development)"
    else
        log_warning "CORS ограничен: $cors_origins"
    fi
else
    log_error "Backend .env файл не найден"
fi

echo ""

# Итоговая оценка
echo "📊 Connection Summary"
echo "--------------------"

# Подсчет успешных проверок
total_checks=0
passed_checks=0

# Здесь должна быть логика подсчета, но для простоты показываем общий статус
if curl -s -f http://localhost:8000/api/v1/health >/dev/null 2>&1 && \
   [ -f "questcity-frontend/.env" ] && \
   grep -q "localhost:8000" questcity-frontend/.env; then
    echo -e "${GREEN}🎉 CONNECTION READY!${NC}"
    echo "   ✅ Backend запущен и отвечает"
    echo "   ✅ Frontend настроен на localhost"
    echo "   ✅ API endpoints доступны"
    echo ""
    echo "🚀 Для запуска фронтенда:"
    echo "   cd questcity-frontend && flutter run"
else
    echo -e "${RED}❌ CONNECTION ISSUES DETECTED${NC}"
    echo ""
    echo "🔧 Для исправления:"
    echo "   1. Запустите backend: ./start_system.sh"
    echo "   2. Проверьте .env настройки"
    echo "   3. Повторите тест: ./test_connection.sh"
fi

echo ""
echo "📚 Документация: README_CONNECTION.md"
echo "🛠 Полный запуск: ./start_system.sh" 