#!/bin/bash

# QuestCity - Скрипт запуска локальной системы
# Запускает бекенд и подготавливает фронтенд для разработки

set -e

echo "🚀 Запуск QuestCity Development System"
echo "======================================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для логирования
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверяем наличие необходимых инструментов
check_requirements() {
    log_info "Проверка требований..."
    
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 не найден!"
        exit 1
    fi
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter не найден!"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_warning "Docker не найден - база данных может быть недоступна"
    fi
    
    log_success "Все требования выполнены"
}

# Настройка environment для фронтенда
setup_frontend_env() {
    log_info "Настройка environment для фронтенда..."
    
    cd questcity-frontend
    
    # Копируем development конфигурацию
    if [ -f ".env.development" ]; then
        cp .env.development .env
        log_success "Скопирован .env.development -> .env"
    else
        log_warning ".env.development не найден"
    fi
    
    cd ..
}

# Запуск бекенда
start_backend() {
    log_info "Запуск QuestCity Backend..."
    
    cd questcity-backend/main
    
    # Проверяем наличие .env файла
    if [ ! -f ".env" ]; then
        log_error "Файл .env не найден в questcity-backend/main/"
        log_info "Скопируйте .env.example в .env и настройте его"
        exit 1
    fi
    
    # Запускаем бекенд через Poetry или Docker
    if [ -f "pyproject.toml" ]; then
        log_info "Запуск через Poetry..."
        if ! command -v poetry &> /dev/null; then
            log_error "Poetry не найден!"
            log_info "Установите Poetry: curl -sSL https://install.python-poetry.org | python3 -"
            exit 1
        fi
        
        # Устанавливаем зависимости если нужно
        poetry install
        
        # Запускаем в фоне
        log_info "Запуск бекенда на http://localhost:8000"
        poetry run python3 main.py &
        BACKEND_PID=$!
        log_success "Backend запущен (PID: $BACKEND_PID)"
        
    elif [ -f "docker-compose.yml" ]; then
        log_info "Запуск через Docker Compose..."
        docker-compose up -d
        log_success "Backend запущен в Docker"
    else
        log_error "Не найден способ запуска бекенда (Poetry или Docker)"
        exit 1
    fi
    
    cd ../..
}

# Подготовка фронтенда
prepare_frontend() {
    log_info "Подготовка QuestCity Frontend..."
    
    cd questcity-frontend
    
    # Получаем зависимости
    log_info "Получение Flutter зависимостей..."
    flutter pub get
    
    # Генерируем код если нужно
    if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
        log_info "Генерация кода..."
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    log_success "Frontend подготовлен"
    log_info "Для запуска выполните: cd questcity-frontend && flutter run"
    
    cd ..
}

# Проверка соединения
test_connection() {
    log_info "Проверка соединения с бекендом..."
    
    # Ждем запуска бекенда
    sleep 5
    
    if curl -s http://localhost:8000/api/v1/health >/dev/null; then
        log_success "✅ Бекенд отвечает на http://localhost:8000"
    else
        log_warning "❌ Бекенд не отвечает, проверьте логи"
    fi
}

# Вывод инструкций
show_instructions() {
    echo ""
    echo "🎯 СИСТЕМА ГОТОВА К РАБОТЕ!"
    echo "=========================="
    echo ""
    echo "📡 Backend API: http://localhost:8000/api/v1/"
    echo "📚 API Docs: http://localhost:8000/api/docs"
    echo "🔧 Health Check: http://localhost:8000/api/v1/health"
    echo ""
    echo "📱 Для запуска фронтенда:"
    echo "   cd questcity-frontend"
    echo "   flutter run"
    echo ""
    echo "🛑 Для остановки бекенда:"
    if [ ! -z "$BACKEND_PID" ]; then
        echo "   kill $BACKEND_PID"
    else
        echo "   docker-compose down (если используется Docker)"
    fi
    echo ""
}

# Основная функция
main() {
    check_requirements
    setup_frontend_env
    start_backend
    prepare_frontend
    test_connection
    show_instructions
}

# Обработка сигналов для graceful shutdown
cleanup() {
    log_info "Остановка системы..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

# Запуск основной функции
main

# Если запущен локально, держим скрипт активным
if [ ! -z "$BACKEND_PID" ]; then
    log_info "Система запущена. Нажмите Ctrl+C для остановки."
    wait $BACKEND_PID
fi 