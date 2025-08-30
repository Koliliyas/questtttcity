#!/bin/bash

# QuestCity Backend - Base Data Initialization Script
# Создает базовые справочные данные через REST API
# 
# Использование:
#   ./scripts/init_base_data.sh
#   ./scripts/init_base_data.sh --force

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Конфигурация
API_BASE="http://localhost:8000/api/v1"
TOKEN_FILE=".admin_token"
FORCE_MODE=false

# Парсинг аргументов
if [[ "$1" == "--force" ]]; then
    FORCE_MODE=true
fi

# Функции для вывода
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

# Функция для отправки запроса с авторизацией
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local content_type="${4:-application/json}"
    
    local auth_header=""
    if [ -f "$TOKEN_FILE" ]; then
        ACCESS_TOKEN=$(cat "$TOKEN_FILE")
        auth_header="-H \"Authorization: Bearer $ACCESS_TOKEN\""
    else
        print_error "Файл токена $TOKEN_FILE не найден"
        return 1
    fi
    
    if [ "$method" = "GET" ]; then
        eval curl -s -X GET \"$API_BASE$endpoint\" $auth_header
    elif [ "$method" = "POST" ]; then
        eval curl -s -X POST \"$API_BASE$endpoint\" \
            -H \"Content-Type: $content_type\" \
            $auth_header \
            -d \'$data\'
    fi
}

# Функция создания активностей
create_activities() {
    print_status "🎯 Создание базовых активностей..."
    
    local activities=(
        "Face verification"
        "Photo taking"
        "QR code scanning"
        "GPS location check"
        "Text input"
        "Audio recording"
        "Video recording"
        "Object detection"
        "Gesture recognition"
        "Document scan"
    )
    
    local created=0
    local skipped=0
    
    for activity in "${activities[@]}"; do
        local response=$(api_request "POST" "/quests/types/" "{\"name\": \"$activity\"}")
        
        if [[ "$response" == *"id"* ]] && [[ "$response" != *"error"* ]] && [[ "$response" != *"detail"* ]]; then
            print_success "Создана активность: $activity"
            ((created++))
        elif [[ "$response" == *"already exists"* ]] || [[ "$response" == *"unique constraint"* ]]; then
            print_info "Активность '$activity' уже существует"
            ((skipped++))
        else
            print_warning "Проблема с созданием активности '$activity': $response"
        fi
    done
    
    print_info "Активности: создано $created, пропущено $skipped"
}

# Функция создания инструментов
create_tools() {
    print_status "🔧 Создание базовых инструментов..."
    
    # Простая заглушка base64 (1x1 прозрачный пиксель PNG)
    local placeholder_image="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    local tools=(
        "Smartphone"
        "Camera"
        "QR Scanner"
        "GPS Tracker"
        "Voice Recorder"
        "Compass"
        "Measuring Tape"
        "Flashlight"
        "Binoculars"
        "Notebook"
    )
    
    local created=0
    local skipped=0
    
    for tool_name in "${tools[@]}"; do
        local response=$(api_request "POST" "/quests/tools/" "{\"name\": \"$tool_name\", \"image\": \"$placeholder_image\"}")
        
        if [[ "$response" == *"id"* ]] && [[ "$response" != *"error"* ]] && [[ "$response" != *"detail"* ]]; then
            print_success "Создан инструмент: $tool_name"
            ((created++))
        elif [[ "$response" == *"already exists"* ]] || [[ "$response" == *"unique constraint"* ]]; then
            print_info "Инструмент '$tool_name' уже существует"
            ((skipped++))
        else
            print_warning "Проблема с созданием инструмента '$tool_name': $response"
        fi
    done
    
    print_info "Инструменты: создано $created, пропущено $skipped"
}

# Функция создания транспорта
create_vehicles() {
    print_status "🚗 Создание базовых транспортных средств..."
    
    local vehicles=(
        "Walking"
        "Bicycle"
        "Car"
        "Public Transport"
        "Motorcycle"
        "Scooter"
        "Boat"
        "Train"
        "Bus"
        "Metro"
    )
    
    local created=0
    local skipped=0
    
    for vehicle in "${vehicles[@]}"; do
        local response=$(api_request "POST" "/quests/vehicles/" "{\"name\": \"$vehicle\"}")
        
        if [[ "$response" == *"id"* ]] && [[ "$response" != *"error"* ]] && [[ "$response" != *"detail"* ]]; then
            print_success "Создан транспорт: $vehicle"
            ((created++))
        elif [[ "$response" == *"already exists"* ]] || [[ "$response" == *"unique constraint"* ]]; then
            print_info "Транспорт '$vehicle' уже существует"
            ((skipped++))
        else
            print_warning "Проблема с созданием транспорта '$vehicle': $response"
        fi
    done
    
    print_info "Транспорт: создано $created, пропущено $skipped"
}

# Функция создания категорий
create_categories() {
    print_status "📂 Создание базовых категорий..."
    
    # Простая заглушка base64 (1x1 прозрачный пиксель PNG)
    local placeholder_image="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    local categories=(
        "Adventure"
        "Culture"
        "Sport"
        "Education"
        "Entertainment"
        "Business"
        "Travel"
        "Technology"
        "Nature"
        "Social"
    )
    
    local created=0
    local skipped=0
    
    for category_name in "${categories[@]}"; do
        local response=$(api_request "POST" "/quests/categories/" "{\"name\": \"$category_name\", \"image\": \"$placeholder_image\"}")
        
        if [[ "$response" == *"id"* ]] && [[ "$response" != *"error"* ]] && [[ "$response" != *"detail"* ]]; then
            print_success "Создана категория: $category_name"
            ((created++))
        elif [[ "$response" == *"already exists"* ]] || [[ "$response" == *"unique constraint"* ]]; then
            print_info "Категория '$category_name' уже существует"
            ((skipped++))
        else
            print_warning "Проблема с созданием категории '$category_name': $response"
        fi
    done
    
    print_info "Категории: создано $created, пропущено $skipped"
}

# Проверка доступности сервера
check_server() {
    print_status "Проверка доступности сервера..."
    
    local health_response=$(curl -s "$API_BASE/health/" || echo "error")
    
    if [[ "$health_response" == *"healthy"* ]] || [[ "$health_response" == *"ok"* ]]; then
        print_success "Сервер доступен"
        return 0
    else
        print_error "Сервер недоступен. Запустите ./quick_start.sh"
        return 1
    fi
}

# Проверка токена авторизации
check_auth() {
    print_status "Проверка авторизации..."
    
    if [ ! -f "$TOKEN_FILE" ]; then
        print_error "Файл токена $TOKEN_FILE не найден"
        print_info "Запустите ./quick_start.sh для получения токена"
        return 1
    fi
    
    local auth_response=$(api_request "GET" "/quests/")
    
    if [[ "$auth_response" == *"[{"* ]] || [[ "$auth_response" == *"id"* ]]; then
        print_success "Авторизация прошла успешно"
        return 0
    else
        print_error "Проблемы с авторизацией: $auth_response"
        return 1
    fi
}

# Главная функция
main() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                🚀 QuestCity Base Data Init                   ║"
    echo "║            Инициализация базовых справочных данных          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
    
    if [ "$FORCE_MODE" = true ]; then
        print_warning "Режим FORCE: попытка перезаписать существующие данные"
    fi
    
    # Проверки
    check_server || exit 1
    check_auth || exit 1
    
    # Создание данных
    create_activities
    create_tools  
    create_vehicles
    create_categories
    
    echo
    print_success "🎉 Инициализация базовых данных завершена!"
    print_info "Теперь можно создавать квесты через API"
}

# Запуск
main "$@" 