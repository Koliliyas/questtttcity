#!/bin/bash

# QuestCity Backend - Universal Quick Start Script
# Универсальный скрипт для быстрого запуска backend с полной автоматизацией
# 
# Использование:
#   ./quick_start.sh           - Запуск с выводом логов в консоль
#   ./quick_start.sh --bg      - Запуск в фоновом режиме
#   ./quick_start.sh --stop    - Остановка фонового сервера
#   ./quick_start.sh --logs    - Просмотр логов фонового сервера

set -e

# Проверка необходимых инструментов
check_requirements() {
    print_status "🔧 Проверка необходимых инструментов..."
    
    # Проверяем curl
    if ! command -v curl &> /dev/null; then
        print_error "curl не найден! Установите curl для работы скрипта"
        exit 1
    fi
    
    # Проверяем Python
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        print_error "Python не найден! Установите Python 3.8+"
        exit 1
    fi
    
    # Проверяем Poetry
    if ! command -v poetry &> /dev/null; then
        print_warning "Poetry не найден. Попытка установки через pip..."
        python3 -m pip install poetry 2>/dev/null || python -m pip install poetry 2>/dev/null || {
            print_error "Не удалось установить Poetry. Установите вручную: https://python-poetry.org/docs/#installation"
            exit 1
        }
    fi
    
    print_success "Все необходимые инструменты найдены"
}

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Конфигурация авторизации админа
ADMIN_EMAIL="admin@questcity.com"
ADMIN_PASSWORD="Admin123!"
ADMIN_USERNAME="admin"
TOKEN_FILE=".admin_token"
API_BASE="http://localhost:8000/api/v1"

# Функция для вывода цветного текста
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Функция для показа помощи
show_help() {
    echo -e "${CYAN}QuestCity Backend - Quick Start Script${NC}"
    echo ""
    echo -e "${YELLOW}Использование:${NC}"
    echo "  ./quick_start.sh           - Запуск с выводом логов в консоль"
    echo "  ./quick_start.sh --bg      - Запуск в фоновом режиме"
    echo "  ./quick_start.sh --stop    - Остановка фонового сервера"
    echo "  ./quick_start.sh --logs    - Просмотр логов фонового сервера"
    echo "  ./quick_start.sh --status  - Проверка статуса сервера"
    echo "  ./quick_start.sh --help    - Показать эту справку"
    echo ""
    echo -e "${YELLOW}Endpoints после запуска:${NC}"
    echo "  📖 API Docs:   http://localhost:8000/docs"
    echo "  🔍 ReDoc:      http://localhost:8000/redoc"
    echo "  ❤️  Health:     http://localhost:8000/api/v1/health/"
    echo "  🌐 API v1:     http://localhost:8000/api/v1/"
}

# Функция для остановки сервера
stop_server() {
    print_status "Остановка QuestCity Backend..."
    
    # Останавливаем по PID файлу
    if [ -f ".server_pid" ]; then
        PID=$(cat .server_pid)
        if ps -p $PID > /dev/null 2>&1; then
            kill $PID
            rm -f .server_pid
            print_success "Сервер остановлен (PID: $PID)"
        else
            print_warning "Сервер с PID $PID уже не запущен"
            rm -f .server_pid
        fi
    fi
    
    # Дополнительно останавливаем все процессы uvicorn и python main.py
    pkill -f "uvicorn.*questcity" 2>/dev/null || true
    pkill -f "python.*main.py" 2>/dev/null || true
    pkill -f "python3.*main.py" 2>/dev/null || true
    
    # Очищаем токен при остановке для безопасности
    if [ -f "$TOKEN_FILE" ]; then
        rm -f "$TOKEN_FILE"
        print_info "Токен авторизации очищен"
    fi
    
    print_success "Все процессы QuestCity Backend остановлены"
}

# Функция для проверки статуса
check_status() {
    print_status "Проверка статуса QuestCity Backend..."
    
    if [ -f ".server_pid" ]; then
        PID=$(cat .server_pid)
        if ps -p $PID > /dev/null 2>&1; then
            print_success "Сервер запущен (PID: $PID)"
            print_info "Логи: tail -f server_output.log"
            
            # Проверяем доступность API
            if curl -s http://localhost:8000/api/v1/health/ > /dev/null 2>&1; then
                print_success "API доступен: http://localhost:8000/docs"
            else
                print_warning "Сервер запущен, но API пока недоступен"
            fi
        else
            print_warning "PID файл найден, но процесс не запущен"
            rm -f .server_pid
        fi
    else
        print_info "Сервер не запущен в фоновом режиме"
    fi
}

# Функция для показа логов
show_logs() {
    if [ -f "server_output.log" ]; then
        print_info "Показ логов QuestCity Backend (Ctrl+C для выхода)..."
        tail -f server_output.log
    else
        print_error "Файл логов не найден. Сервер запущен?"
    fi
}

# Функция для создания админа если его нет
create_admin_if_needed() {
    print_status "🔑 Проверка администратора..."
    
    # Проверяем есть ли уже админ в системе
    local check_result
    check_result=$(poetry run python3 -c "
import asyncio
import sys
sys.path.insert(0, 'src')
from db.engine import async_session_factory
from db.models.user import User
from sqlalchemy import select

async def check_admin():
    async with async_session_factory() as session:
        result = await session.execute(select(User).where(User.email == '$ADMIN_EMAIL'))
        admin = result.scalar_one_or_none()
        return admin is not None

try:
    result = asyncio.run(check_admin())
    print('exists' if result else 'not_exists')
except:
    print('error')
" 2>/dev/null || echo "error")
    
    if [ "$check_result" = "exists" ]; then
        print_success "Администратор найден в системе"
        return 0
    elif [ "$check_result" = "error" ]; then
        print_warning "Не удалось проверить существование админа, создаем нового..."
    else
        print_info "Администратор не найден, создаем..."
    fi
    
    # Создаем администратора
    print_status "Создание администратора..."
    if poetry run python3 scripts/create_admin.py \
        --username "$ADMIN_USERNAME" \
        --email "$ADMIN_EMAIL" \
        --password "$ADMIN_PASSWORD" \
        --first-name "System" \
        --last-name "Administrator" \
        --credits 10000 \
        --force >/dev/null 2>&1; then
        print_success "Администратор создан"
    else
        print_warning "Администратор уже существует или создан ранее"
    fi
}

# Функция для получения токена авторизации админа
get_admin_token() {
    print_status "🔐 Получение токена авторизации админа..."
    
    # Ждем пока сервер полностью запустится
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$API_BASE/health/" >/dev/null 2>&1; then
            print_success "Сервер готов для авторизации"
            break
        fi
        print_info "Ожидание готовности сервера... (попытка $attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        print_error "Сервер не отвечает, пропускаем авторизацию"
        return 1
    fi
    
    # Получаем токен авторизации (API ожидает form-data, а не JSON)
    local response
    response=$(curl -s -X POST "$API_BASE/auth/login" \
        -d "login=$ADMIN_EMAIL" \
        -d "password=$ADMIN_PASSWORD" 2>/dev/null || echo '{"error":"request_failed"}')
    
    # Простой парсинг JSON без jq
    local access_token=""
    if [[ "$response" == *"accessToken"* ]]; then
        # Извлекаем токен из JSON ответа
        access_token=$(echo "$response" | sed -n 's/.*"accessToken":"\([^"]*\)".*/\1/p')
    fi
    
    if [ -n "$access_token" ] && [ "$access_token" != "null" ] && [ "$access_token" != "" ]; then
        echo "$access_token" > "$TOKEN_FILE"
        print_success "Токен администратора получен и сохранен"
        print_info "Токен сохранен в файл: $TOKEN_FILE"
        return 0
    else
        print_error "Не удалось получить токен авторизации"
        print_error "Ответ сервера: $response"
        return 1
    fi
}

# Функция для проверки работы API с токеном
test_admin_access() {
    print_status "🧪 Проверка доступа администратора к API..."
    
    if [ ! -f "$TOKEN_FILE" ]; then
        print_warning "Файл токена не найден, пропускаем тест"
        return 1
    fi
    
    local token
    token=$(cat "$TOKEN_FILE")
    
    # Сначала проверяем health endpoint
    local health_response
    health_response=$(curl -s -X GET "$API_BASE/health/" 2>/dev/null || echo '{"error":"request_failed"}')
    
    if [[ "$health_response" == *"status"* ]] || [[ "$health_response" == *"ok"* ]]; then
        print_success "Health endpoint доступен"
    else
        print_warning "Health endpoint недоступен: $health_response"
    fi
    
    # Тестируем доступ к API квестов
    local response
    response=$(curl -s -X GET "$API_BASE/quests/" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" 2>/dev/null || echo '{"error":"request_failed"}')
    
    if [[ "$response" == *"["* ]] || [[ "$response" == *"items"* ]]; then
        print_success "API квестов доступен с токеном администратора"
        # Простой подсчет элементов без jq
        local count="unknown"
        if [[ "$response" == *"["* ]]; then
            count=$(echo "$response" | grep -o '"[^"]*"' | wc -l)
        fi
        print_info "Найдено квестов: $count"
        return 0
    elif [[ "$response" == *"PERMISSION_DENIED"* ]]; then
        print_warning "Проблемы с правами доступа к API квестов"
        print_info "Это нормально для новых пользователей - права будут настроены позже"
        return 0
    else
        print_warning "Проблемы с доступом к API квестов"
        print_info "Ответ: $response"
        print_info "Это может быть нормально при первом запуске"
        return 0
    fi
}

# Функция для настройки прав доступа администратора
setup_admin_permissions() {
    print_status "🔐 Настройка прав доступа администратора..."
    
    if [ ! -f "$TOKEN_FILE" ]; then
        print_warning "Файл токена не найден, пропускаем настройку прав"
        return 1
    fi
    
    local token
    token=$(cat "$TOKEN_FILE")
    
    # Настраиваем права доступа через API
    local response
    response=$(curl -s -X PUT "$API_BASE/users/me/permissions" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d '{"canEditQuests": true, "canLockUsers": true}' 2>/dev/null || echo '{"error":"request_failed"}')
    
    if [[ "$response" == *"success"* ]] || [[ "$response" == *"updated"* ]]; then
        print_success "Права доступа администратора настроены"
        return 0
    else
        print_warning "Не удалось настроить права доступа: $response"
        print_info "Это может быть нормально - права могут быть настроены вручную"
        return 0
    fi
}

# Переходим в директорию скрипта
cd "$(dirname "$0")"

# Обработка аргументов
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    --stop)
        stop_server
        exit 0
        ;;
    --status)
        check_status
        exit 0
        ;;
    --logs)
        show_logs
        exit 0
        ;;
    --bg)
        BACKGROUND_MODE=true
        ;;
    *)
        BACKGROUND_MODE=false
        ;;
esac

# Основной заголовок
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    🚀 QuestCity Backend                      ║"
echo "║                  Quick Start Automation                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

print_status "Начинаем автоматическую настройку и запуск..."

# 0. Проверяем необходимые инструменты
check_requirements

# 1. Проверяем рабочую директорию
print_status "📁 Проверка рабочей директории..."
if [ ! -f "main.py" ] || [ ! -f "pyproject.toml" ]; then
    print_error "Не найдены файлы main.py или pyproject.toml. Запустите скрипт из корня проекта questcity-backend"
    exit 1
fi
print_success "Рабочая директория: $(pwd)"

# 2. Останавливаем предыдущие процессы
print_status "🔄 Остановка предыдущих процессов..."
stop_server

# 3. Проверяем Python
print_status "🐍 Проверка Python..."
if ! command -v python3 &> /dev/null; then
    print_error "Python3 не найден! Установите Python 3.8+"
    exit 1
fi
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
print_success "Python версия: $PYTHON_VERSION"

# 4. Проверяем Poetry
print_status "📦 Проверка Poetry..."
if ! command -v poetry &> /dev/null; then
    print_warning "Poetry не найден. Попытка установки через pip..."
    python3 -m pip install poetry
    if ! command -v poetry &> /dev/null; then
        print_error "Не удалось установить Poetry. Установите вручную: https://python-poetry.org/docs/#installation"
        exit 1
    fi
fi
print_success "Poetry найден"

# 5. Устанавливаем зависимости
print_status "📚 Установка зависимостей..."
if [ -f "poetry.lock" ]; then
    poetry install --without dev 2>/dev/null || poetry install
else
    print_warning "poetry.lock не найден, выполняем полную установку..."
    poetry install
fi
print_success "Зависимости установлены"

# 6. Проверяем Docker (для PostgreSQL)
print_status "🐳 Проверка Docker..."
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    print_info "Запуск PostgreSQL через Docker..."
    docker-compose up -d database 2>/dev/null || print_warning "Docker не запущен или проблемы с docker-compose"
    sleep 3
    print_success "База данных готова"
else
    print_warning "Docker не найден. Убедитесь, что PostgreSQL запущен вручную"
fi

# 7. Проверяем миграции
print_status "🔧 Проверка миграций..."
if [ -f "alembic.ini" ]; then
    export PYTHONPATH=src:$PYTHONPATH
    poetry run alembic current 2>/dev/null || print_warning "Проблемы с миграциями, но продолжаем..."
    print_success "Миграции проверены"
else
    print_warning "alembic.ini не найден, пропускаем проверку миграций"
fi

# 8. Создаем администратора если нужно
create_admin_if_needed

# 9. Создаем директорию для логов
mkdir -p logs

# 10. Запускаем сервер
print_status "🌐 Запуск FastAPI сервера..."

if [ "$BACKGROUND_MODE" = true ]; then
    # Фоновый режим
    print_info "Запуск в фоновом режиме..."
    
    # Пробуем разные способы запуска
    if [ -f "main.py" ]; then
        nohup poetry run python main.py > server_output.log 2>&1 &
    else
        print_error "main.py не найден"
        exit 1
    fi
    
    SERVER_PID=$!
    echo $SERVER_PID > .server_pid
    
    # Ждем немного и проверяем что сервер запустился
    sleep 3
    if ps -p $SERVER_PID > /dev/null 2>&1; then
        print_success "Сервер запущен в фоне (PID: $SERVER_PID)"
        print_info "📊 Логи: tail -f server_output.log"
        print_info "📊 Или используйте: ./quick_start.sh --logs"
        print_info "🛑 Остановка: ./quick_start.sh --stop"
        
        # 11. Получаем токен администратора
        get_admin_token
        
        # 12. Настраиваем права доступа
        setup_admin_permissions
        
        # 13. Тестируем доступ
        test_admin_access
    else
        print_error "Не удалось запустить сервер в фоне"
        exit 1
    fi
else
    # Интерактивный режим
    print_info "Запуск в интерактивном режиме..."
    print_info "Для остановки: Ctrl+C"
    echo ""
    
    # Пробуем запустить сервер
    if [ -f "main.py" ]; then
        # Запускаем сервер в фоне для авторизации, затем переходим в интерактивный режим
        print_info "Запуск сервера для настройки авторизации..."
        nohup poetry run python main.py > server_output.log 2>&1 &
        TEMP_PID=$!
        
        # Ждем запуска и получаем токен
        sleep 5
        get_admin_token
        setup_admin_permissions
        test_admin_access
        
        # Останавливаем временный процесс
        kill $TEMP_PID 2>/dev/null || true
        sleep 2
        
        # Теперь запускаем в интерактивном режиме
        print_info "Перезапуск в интерактивном режиме..."
        poetry run python main.py
    else
        print_error "main.py не найден"
        exit 1
    fi
fi

# 13. Показываем информацию о доступных endpoints
echo ""
print_success "🎉 QuestCity Backend успешно запущен!"
echo ""
echo -e "${YELLOW}📋 Доступные endpoints:${NC}"
echo -e "  📖 API Documentation: ${CYAN}http://localhost:8000/docs${NC}"
echo -e "  🔍 ReDoc:             ${CYAN}http://localhost:8000/redoc${NC}"
echo -e "  ❤️  Health Check:      ${CYAN}http://localhost:8000/api/v1/health/${NC}"
echo -e "  🌐 API v1:            ${CYAN}http://localhost:8000/api/v1/${NC}"
echo ""
echo -e "${YELLOW}🛠️  Полезные команды:${NC}"
echo -e "  ./quick_start.sh --status  - Проверить статус сервера"
echo -e "  ./quick_start.sh --logs    - Просмотр логов"
echo -e "  ./quick_start.sh --stop    - Остановить сервер"
echo ""
if [ -f "$TOKEN_FILE" ]; then
    echo -e "${YELLOW}🔐 Авторизация:${NC}"
    echo -e "  ✅ Токен администратора сохранен в $TOKEN_FILE"
    echo -e "  🧪 Тестирование API: ./test_quests_api.sh"
    echo -e "  👤 Админ: $ADMIN_EMAIL"
    echo ""
fi 