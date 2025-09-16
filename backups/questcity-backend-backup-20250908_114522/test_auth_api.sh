#!/bin/bash

# QuestCity Backend - Authentication API Testing Script
# Скрипт для тестирования всех функций авторизации и регистрации
# 
# Использование:
#   ./test_auth_api.sh           - Полное тестирование всех функций
#   ./test_auth_api.sh --quick   - Быстрая проверка базовых функций
#   ./test_auth_api.sh --login   - Только тестирование входа

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
TEST_USER_EMAIL="testuser@questcity.com"
TEST_USER_USERNAME="testuser"
TEST_USER_PASSWORD="TestPass123!"
ACCESS_TOKEN=""
REFRESH_TOKEN=""

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

print_test() {
    echo -e "${YELLOW}🧪 Тест: $1${NC}"
}

# Функция для проверки доступности сервера
check_server() {
    print_status "Проверка доступности сервера..."
    
    local health_response=$(curl -s "$API_BASE/health/" 2>/dev/null || echo "error")
    
    if [[ "$health_response" == *"status"* ]]; then
        print_success "Сервер доступен"
        return 0
    else
        print_error "Сервер недоступен по адресу $API_BASE"
        print_info "Запустите сервер: ./quick_start.sh --bg"
        exit 1
    fi
}

# Функция для генерации уникального email
generate_test_email() {
    local timestamp=$(date +%s)
    local short_timestamp=${timestamp: -6}  # Последние 6 цифр
    echo "test${short_timestamp}@qc.com"
}

# Функция для генерации уникального username
generate_test_username() {
    local timestamp=$(date +%s)
    local short_timestamp=${timestamp: -6}  # Последние 6 цифр
    echo "test${short_timestamp}"
}

# Тестирование регистрации нового пользователя
test_user_registration() {
    print_test "Регистрация нового пользователя"
    
    # Генерируем уникальный email для тестирования
    local unique_email=$(generate_test_email)
    local unique_username=$(generate_test_username)
    
    local registration_data='{
        "username": "'$unique_username'",
        "email": "'$unique_email'",
        "password1": "'$TEST_USER_PASSWORD'",
        "password2": "'$TEST_USER_PASSWORD'",
        "first_name": "Test",
        "last_name": "User",
        "instagram_username": "test_insta"
    }'
    
    # Регистрация возвращает статус 204 (пустой ответ) при успехе
    local http_status=$(curl -s -o /tmp/register_response.json -w "%{http_code}" -X POST "$API_BASE/auth/register" \
        -H "Content-Type: application/json" \
        -d "$registration_data" 2>/dev/null || echo "000")
    
    local response=$(cat /tmp/register_response.json 2>/dev/null || echo "")
    
    if [ "$http_status" = "204" ]; then
        print_success "Пользователь успешно зарегистрирован"
        print_info "Email: $unique_email"
        print_info "Username: $unique_username"
        
        # Сохраняем данные для дальнейших тестов
        TEST_USER_EMAIL="$unique_email"
        TEST_USER_USERNAME="$unique_username"
        echo "$unique_email" > .test_user_email
        echo "$unique_username" > .test_user_username
        rm -f /tmp/register_response.json
        return 0
    else
        print_error "Ошибка регистрации пользователя (HTTP: $http_status)"
        print_error "Ответ: $response"
        rm -f /tmp/register_response.json
        return 1
    fi
}

# Тестирование входа в систему
test_user_login() {
    print_test "Вход в систему"
    
    # Используем данные существующего пользователя или админа
    local login_email="admin@questcity.com"
    local login_password="admin123"
    
    # Если есть созданный тестовый пользователь, используем его
    if [ -f ".test_user_email" ]; then
        login_email=$(cat .test_user_email)
        login_password="$TEST_USER_PASSWORD"
    fi
    
    local response=$(curl -s -X POST "$API_BASE/auth/login" \
        -d "login=$login_email" \
        -d "password=$login_password" 2>/dev/null || echo '{"error":"request_failed"}')
    
    ACCESS_TOKEN=$(echo "$response" | jq -r '.accessToken // empty' 2>/dev/null || echo "")
    REFRESH_TOKEN=$(echo "$response" | jq -r '.refreshToken // empty' 2>/dev/null || echo "")
    
    if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ] && [ "$ACCESS_TOKEN" != "" ]; then
        print_success "Вход выполнен успешно"
        print_info "Пользователь: $login_email"
        echo "$ACCESS_TOKEN" > .test_access_token
        return 0
    else
        print_error "Ошибка входа в систему"
        print_error "Ответ: $response"
        return 1
    fi
}

# Тестирование обновления токена
test_token_refresh() {
    print_test "Обновление токена доступа"
    
    if [ -z "$REFRESH_TOKEN" ]; then
        print_warning "Нет refresh токена для тестирования"
        return 1
    fi
    
    local response=$(curl -s -X POST "$API_BASE/auth/refresh" \
        -H "Content-Type: application/json" \
        -d '{"refresh_token":"'$REFRESH_TOKEN'"}' 2>/dev/null || echo '{"error":"request_failed"}')
    
    local new_access_token=$(echo "$response" | jq -r '.accessToken // empty' 2>/dev/null || echo "")
    
    if [ -n "$new_access_token" ] && [ "$new_access_token" != "null" ] && [ "$new_access_token" != "" ]; then
        print_success "Токен успешно обновлен"
        ACCESS_TOKEN="$new_access_token"
        return 0
    else
        print_error "Ошибка обновления токена"
        print_error "Ответ: $response"
        return 1
    fi
}

# Тестирование доступа к защищенным ресурсам
test_protected_access() {
    print_test "Доступ к защищенным ресурсам"
    
    # Используем админский токен для проверки защищенных ресурсов
    local admin_token=""
    if [ -f ".admin_token" ]; then
        admin_token=$(cat .admin_token)
    fi
    
    if [ -z "$admin_token" ]; then
        # Если нет админского токена, получаем его
        local admin_response=$(curl -s -X POST "$API_BASE/auth/login" \
            -d "login=admin@questcity.com" \
            -d "password=admin123" 2>/dev/null || echo '{"error":"request_failed"}')
        
        admin_token=$(echo "$admin_response" | jq -r '.accessToken // empty' 2>/dev/null || echo "")
    fi
    
    if [ -z "$admin_token" ]; then
        print_warning "Нет токена админа для тестирования защищенных ресурсов"
        return 1
    fi
    
    local response=$(curl -s -X GET "$API_BASE/quests/" \
        -H "Authorization: Bearer $admin_token" 2>/dev/null || echo '{"error":"request_failed"}')
    
    if [[ "$response" == *"["* ]] || [[ "$response" == *"items"* ]]; then
        print_success "Доступ к защищенным ресурсам работает (админ)"
        local count=$(echo "$response" | jq '. | length' 2>/dev/null || echo "unknown")
        print_info "Доступно квестов: $count"
        return 0
    else
        print_error "Ошибка доступа к защищенным ресурсам"
        print_error "Ответ: $response"
        return 1
    fi
}

# Тестирование выхода из системы
test_user_logout() {
    print_test "Выход из системы"
    
    if [ -z "$ACCESS_TOKEN" ]; then
        print_warning "Нет токена для тестирования выхода"
        return 1
    fi
    
    local response=$(curl -s -X POST "$API_BASE/auth/logout" \
        -H "Authorization: Bearer $ACCESS_TOKEN" 2>/dev/null || echo '{"error":"request_failed"}')
    
    # Logout может возвращать разные ответы, проверяем что не было ошибки сервера
    if [[ "$response" != *"INTERNAL_SERVER_ERROR"* ]]; then
        print_success "Выход выполнен успешно"
        return 0
    else
        print_error "Ошибка при выходе из системы"
        print_error "Ответ: $response"
        return 1
    fi
}

# Тестирование неверных данных авторизации
test_invalid_credentials() {
    print_test "Тестирование неверных данных"
    
    local response=$(curl -s -X POST "$API_BASE/auth/login" \
        -d "login=invalid@email.com" \
        -d "password=wrongpassword" 2>/dev/null || echo '{"error":"request_failed"}')
    
    if [[ "$response" == *"INVALID_USER_CREDENTIALS"* ]] || [[ "$response" == *"Invalid"* ]] || [[ "$response" == *"Unauthorized"* ]] || [[ "$response" == *"Incorrect"* ]]; then
        print_success "Неверные данные корректно отклонены"
        return 0
    else
        print_error "Неверные данные были приняты (проблема безопасности!)"
        print_error "Ответ: $response"
        return 1
    fi
}

# Очистка тестовых данных
cleanup_test_data() {
    print_status "Очистка тестовых данных..."
    rm -f .test_user_email .test_user_username .test_access_token
    print_info "Временные файлы удалены"
}

# Функция для показа помощи
show_help() {
    echo -e "${CYAN}QuestCity Backend - Authentication API Testing Script${NC}"
    echo ""
    echo -e "${YELLOW}Использование:${NC}"
    echo "  ./test_auth_api.sh           - Полное тестирование всех функций"
    echo "  ./test_auth_api.sh --quick   - Быстрая проверка базовых функций"
    echo "  ./test_auth_api.sh --login   - Только тестирование входа"
    echo "  ./test_auth_api.sh --help    - Показать эту справку"
    echo ""
    echo -e "${YELLOW}Требования:${NC}"
    echo "  - Запущенный сервер QuestCity Backend"
    echo "  - Установленный jq для обработки JSON"
    echo ""
}

# Основная функция
main() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            🔐 QuestCity Authentication API Testing           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Проверяем jq
    if ! command -v jq &> /dev/null; then
        print_error "jq не установлен. Установите: brew install jq"
        exit 1
    fi
    
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --login)
            check_server
            test_user_login
            test_protected_access
            cleanup_test_data
            exit 0
            ;;
        --quick)
            check_server
            test_user_login
            test_protected_access
            cleanup_test_data
            exit 0
            ;;
        *)
            # Полное тестирование
            print_status "Начинаем полное тестирование авторизации..."
            
            check_server
            
            print_info "=== Тестирование регистрации ==="
            test_user_registration
            
            print_info "=== Тестирование авторизации ==="
            test_user_login
            test_protected_access
            
            print_info "=== Тестирование безопасности ==="
            test_invalid_credentials
            
            print_info "=== Тестирование токенов ==="
            test_token_refresh
            
            print_info "=== Тестирование выхода ==="
            test_user_logout
            
            cleanup_test_data
            
            print_success "🎉 Тестирование авторизации завершено!"
            ;;
    esac
}

# Обработка сигнала прерывания для очистки
trap cleanup_test_data EXIT

# Запуск
main "$@" 