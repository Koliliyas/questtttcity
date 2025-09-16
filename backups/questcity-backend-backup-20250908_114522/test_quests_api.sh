#!/bin/bash

# QuestCity Backend - Comprehensive API Testing Script (HIGH-014)
# Объединённый скрипт для запуска ВСЕХ backend тестов
# 
# Включает:
# - Comprehensive Integration Tests (pytest) - CRUD, validation, error scenarios
# - Quest API Tests (bash/curl) - полное тестирование API квестов
#
# Использование:
#   ./test_quests_api.sh                    - Полное тестирование всех функций
#   ./test_quests_api.sh --quick            - Быстрая проверка основных функций
#   ./test_quests_api.sh --pytest-only     - Только pytest тесты
#   ./test_quests_api.sh --bash-only        - Только bash тесты  
#   ./test_quests_api.sh --auth             - Только тестирование авторизации

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Конфигурация
API_BASE="http://localhost:8000/api/v1"
TEST_USER_EMAIL="admin@questcity.com"
TEST_USER_PASSWORD="admin123"
TOKEN_FILE=".admin_token"
ACCESS_TOKEN=""

# Результаты тестирования
PYTEST_RESULT=0
BASH_TESTS_RESULT=0
TOTAL_TESTS_RUN=0
TOTAL_TESTS_PASSED=0

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

# Функция для проверки ответа API
check_response() {
    local response="$1"
    local expected_status="$2"
    local test_name="$3"
    
    local status=$(echo "$response" | jq -r '.status // empty')
    local detail=$(echo "$response" | jq -r '.detail // empty')
    
    if [[ "$response" == *"\"$expected_status\""* ]] || [[ "$status" == "$expected_status" ]]; then
        print_success "$test_name - ОК"
        return 0
    else
        print_error "$test_name - FAILED"
        print_error "Ответ: $response"
        return 1
    fi
}

# Функция для отправки запроса с авторизацией
api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local content_type="${4:-application/json}"
    
    local auth_header=""
    if [ -n "$ACCESS_TOKEN" ]; then
        auth_header="-H \"Authorization: Bearer $ACCESS_TOKEN\""
    fi
    
    if [ "$method" = "GET" ]; then
        eval curl -s -X GET \"$API_BASE$endpoint\" $auth_header
    elif [ "$method" = "POST" ]; then
        eval curl -s -X POST \"$API_BASE$endpoint\" \
            -H \"Content-Type: $content_type\" \
            $auth_header \
            -d \'$data\'
    elif [ "$method" = "PUT" ]; then
        eval curl -s -X PUT \"$API_BASE$endpoint\" \
            -H \"Content-Type: $content_type\" \
            $auth_header \
            -d \'$data\'
    elif [ "$method" = "PATCH" ]; then
        eval curl -s -X PATCH \"$API_BASE$endpoint\" \
            -H \"Content-Type: $content_type\" \
            $auth_header \
            -d \'$data\'
    elif [ "$method" = "DELETE" ]; then
        eval curl -s -X DELETE \"$API_BASE$endpoint\" $auth_header
    fi
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

# Функция для получения токена авторизации
get_auth_token() {
    print_status "Получение токена авторизации..."
    
    # Сначала пытаемся прочитать сохраненный токен админа
    if [ -f "$TOKEN_FILE" ]; then
        ACCESS_TOKEN=$(cat "$TOKEN_FILE")
        if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "" ]; then
            print_success "Используем сохраненный токен администратора"
            return 0
        fi
    fi
    
    # Если сохраненного токена нет, пытаемся авторизоваться
    print_info "Сохраненный токен не найден, выполняем авторизацию..."
    # API login ожидает form-data, а не JSON
    local response=$(curl -s -X POST "$API_BASE/auth/login" \
        -d "login=$TEST_USER_EMAIL" \
        -d "password=$TEST_USER_PASSWORD" 2>/dev/null || echo '{"error":"request_failed"}')
    
    ACCESS_TOKEN=$(echo "$response" | jq -r '.accessToken // empty' 2>/dev/null || echo "")
    
    if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
        print_success "Токен получен через авторизацию"
        # Сохраняем токен для дальнейшего использования
        echo "$ACCESS_TOKEN" > "$TOKEN_FILE"
        return 0
    else
        print_warning "Не удалось получить токен. Продолжаем без авторизации..."
        print_info "Ответ авторизации: $response"
        return 1
    fi
}

# Тестирование получения списка квестов
test_get_quests() {
    print_test "Получение списка квестов"
    
    local response=$(api_request "GET" "/quests/")
    
    if [[ "$response" == *"["* ]] || [[ "$response" == *"items"* ]]; then
        print_success "Список квестов получен"
        local count=$(echo "$response" | jq '. | length' 2>/dev/null || echo "unknown")
        print_info "Найдено квестов: $count"
    else
        print_error "Ошибка получения списка квестов"
        print_error "Ответ: $response"
        return 1
    fi
}

# Тестирование получения квеста по ID
test_get_quest_by_id() {
    print_test "Получение квеста по ID"
    
    # Сначала получаем список квестов чтобы найти ID
    local quests_response=$(api_request "GET" "/quests/")
    local quest_id=$(echo "$quests_response" | jq -r '.[0].id // empty' 2>/dev/null || echo "")
    
    if [ -z "$quest_id" ] || [ "$quest_id" = "null" ]; then
        print_warning "Не найдено квестов для тестирования"
        return 1
    fi
    
    local response=$(api_request "GET" "/quests/$quest_id")
    
    if [[ "$response" == *"id"* ]]; then
        print_success "Квест по ID получен"
        print_info "ID квеста: $quest_id"
    else
        print_error "Ошибка получения квеста по ID"
        print_error "Ответ: $response"
        return 1
    fi
}

# Тестирование создания нового квеста
test_create_quest() {
    print_test "Создание нового квеста"
    
    if [ -z "$ACCESS_TOKEN" ]; then
        print_warning "Нет токена авторизации, пропускаем создание квеста"
        return 1
    fi
    
    # Подготавливаем base64 изображение (простая тестовая картинка)
    local base64_image="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    # Подготавливаем base64 для mentor_preferences (простой тестовый Excel файл)
    local base64_excel="UEsDBBQACAgIAAAAAAAAAAAAAAAAAAAAAAAUAAAAeGwvd29ya2Jvb2sueG1sRU9BDsIwDLz3iv4g7xYBQqhJKxASEhI/4OImXmuTO3ESaPv7urTAcTQz45md7fWt731zYoIex+A6FQSMeGI/Fo4c0mYd4HsY0Ic15lLOphtxmQD2YYz5kz3vOUdrr2XfqMZKwpZuCdZ5aw/Y1Ap3vI5P1AtQH1ptL4X3s1gKKzUYn1J5xkxaXJNXj4TaZqFWO6q7mU/wBQAA//8="
    
    # Генерируем уникальное имя с timestamp (макс. 32 символа)
    local timestamp=$(date +"%H%M%S")
    local quest_data='{
        "name": "Test API '$timestamp'",
        "description": "Квест созданный через API тестирование с правильными данными валидации",
        "image": "'$base64_image'",
        "credits": {
            "cost": 100,
            "reward": 200
        },
        "main_preferences": {
            "types": [1, 2],
            "places": [1],
            "vehicles": [1],
            "tools": [1]
        },
        "mentor_preferences": "'$base64_excel'",
        "merch": [],
        "points": [
            {
                "name_of_location": "Тестовая точка",
                "description": "Описание тестовой точки",
                "order": 1,
                "type": {
                    "type_id": 1,
                    "type_photo": "Face verification",
                    "type_code": "TEST_CODE",
                    "type_word": "Тест"
                },
                "tool_id": 1,
                "places": [
                    {
                        "longitude": 37.6156,
                        "latitude": 55.7522,
                        "detections_radius": 10.0,
                        "height": 0.0,
                        "interaction_inaccuracy": 5.0,
                        "part": 1,
                        "random_occurrence": 5.0
                    }
                ],
                "files": {
                    "file": "'$base64_image'",
                    "is_divide": false
                }
            }
        ]
    }'
    
    local response=$(api_request "POST" "/quests/" "$quest_data")
    
    if [[ "$response" == *"id"* ]] && [[ "$response" != *"error"* ]] && [[ "$response" != *"detail"* ]]; then
        print_success "Квест успешно создан"
        local new_quest_id=$(echo "$response" | jq -r '.id // empty' 2>/dev/null || echo "")
        print_info "ID нового квеста: $new_quest_id"
        
        # Сохраняем ID для дальнейших тестов
        echo "$new_quest_id" > .test_quest_id
    else
        print_error "Ошибка создания квеста"
        print_error "Ответ: $response"
        
        # Дополнительная диагностика ошибок валидации
        if [[ "$response" == *"detail"* ]]; then
            print_info "🔍 Детали ошибок валидации:"
            echo "$response" | jq '.detail // empty' 2>/dev/null || echo "$response"
        fi
        
        return 1
    fi
}

# Тестирование обновления квеста
test_update_quest() {
    print_test "Обновление квеста"
    
    if [ -z "$ACCESS_TOKEN" ]; then
        print_warning "Нет токена авторизации, пропускаем обновление квеста"
        return 1
    fi
    
    local quest_id=""
    if [ -f ".test_quest_id" ]; then
        quest_id=$(cat .test_quest_id)
    fi
    
    if [ -z "$quest_id" ]; then
        print_warning "Нет ID квеста для обновления"
        return 1
    fi
    
    # Подготавливаем base64 изображение (простая тестовая картинка)
    local base64_image="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    
    # Подготавливаем base64 для mentor_preferences (простой тестовый Excel файл)
    local base64_excel="UEsDBBQACAgIAAAAAAAAAAAAAAAAAAAAAAAUAAAAeGwvd29ya2Jvb2sueG1sRU9BDsIwDLz3iv4g7xYBQqhJKxASEhI/4OImXmuTO3ESaPv7urTAcTQz45md7fWt731zYoIex+A6FQSMeGI/Fo4c0mYd4HsY0Ic15lLOphtxmQD2YYz5kz3vOUdrr2XfqMZKwpZuCdZ5aw/Y1Ap3vI5P1AtQH1ptL4X3s1gKKzUYn1J5xkxaXJNXj4TaZqFWO6q7mU/wBQAA//8="
    
    # Генерируем уникальное имя для обновления
    local timestamp=$(date +"%H%M%S")
    local update_data='{
        "name": "Updated '$timestamp'",
        "description": "Описание было обновлено через API с правильным форматом данных",
        "image": "'$base64_image'",
        "credits": {
            "cost": 150,
            "reward": 250
        },
        "main_preferences": {
            "types": [1, 2, 3],
            "places": [1, 2],
            "vehicles": [1],
            "tools": [1, 2]
        },
        "mentor_preferences": "'$base64_excel'",
        "merch": [],
        "points": [
            {
                "name_of_location": "Обновленная тестовая точка",
                "description": "Обновленное описание тестовой точки",
                "order": 1,
                "type": {
                    "type_id": 1,
                    "type_photo": "Photo Matching",
                    "type_code": "UPDATED_CODE",
                    "type_word": "Обновлено"
                },
                "tool_id": 1,
                "places": [
                    {
                        "longitude": 37.6156,
                        "latitude": 55.7522,
                        "detections_radius": 8.0,
                        "height": 0.0,
                        "interaction_inaccuracy": 10.0,
                        "part": 1,
                        "random_occurrence": 7.0
                    }
                ],
                "files": {
                    "file": "'$base64_image'",
                    "is_divide": false
                }
            }
        ]
    }'
    
    local response=$(api_request "PATCH" "/quests/$quest_id" "$update_data")
    
    if [[ "$response" == *"id"* ]] && [[ "$response" != *"error"* ]] && [[ "$response" != *"detail"* ]]; then
        print_success "Квест успешно обновлен"
    else
        print_error "Ошибка обновления квеста"
        print_error "Ответ: $response"
        
        # Дополнительная диагностика ошибок валидации
        if [[ "$response" == *"detail"* ]]; then
            print_info "🔍 Детали ошибок валидации:"
            echo "$response" | jq '.detail // empty' 2>/dev/null || echo "$response"
        fi
        
        return 1
    fi
}

# Тестирование удаления квеста
test_delete_quest() {
    print_test "Удаление квеста"
    
    if [ -z "$ACCESS_TOKEN" ]; then
        print_warning "Нет токена авторизации, пропускаем удаление квеста"
        return 1
    fi
    
    local quest_id=""
    if [ -f ".test_quest_id" ]; then
        quest_id=$(cat .test_quest_id)
    fi
    
    if [ -z "$quest_id" ]; then
        print_warning "Нет ID квеста для удаления"
        return 1
    fi
    
    local response=$(api_request "DELETE" "/quests/$quest_id")
    
    if [[ "$response" == *"success"* ]] || [[ "$response" == "" ]]; then
        print_success "Квест успешно удален"
        rm -f .test_quest_id
    else
        print_error "Ошибка удаления квеста"
        print_error "Ответ: $response"
        return 1
    fi
}

# Тестирование получения категорий
test_get_categories() {
    print_test "Получение категорий квестов"
    
    local response=$(api_request "GET" "/quests/categories/")
    
    if [[ "$response" == *"["* ]] || [[ "$response" == *"items"* ]]; then
        print_success "Категории получены"
        local count=$(echo "$response" | jq '. | length' 2>/dev/null || echo "unknown")
        print_info "Найдено категорий: $count"
    else
        print_error "Ошибка получения категорий"
        print_error "Ответ: $response"
        return 1
    fi
}

# Функция для запуска pytest тестов
run_pytest_tests() {
    print_status "Запуск Comprehensive Integration Tests (pytest)..."
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            🧪 PYTEST COMPREHENSIVE TESTS                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    local pytest_mode="${1:-all}"
    
    if [ ! -f "run_comprehensive_tests.py" ]; then
        print_error "Файл run_comprehensive_tests.py не найден"
        return 1
    fi
    
    local pytest_args=""
    case "$pytest_mode" in
        quick)
            pytest_args="--quick"
            print_info "Режим: Быстрые CRUD тесты"
            ;;
        regression)
            pytest_args="--regression"
            print_info "Режим: Регрессионные тесты"
            ;;
        validation)
            pytest_args="--validation"
            print_info "Режим: Тесты валидации"
            ;;
        performance)
            pytest_args="--performance"
            print_info "Режим: Performance тесты"
            ;;
        *)
            print_info "Режим: Все comprehensive тесты"
            ;;
    esac
    
    echo ""
    
    # Проверяем наличие Python 3
    if ! command -v python3 &> /dev/null; then
        print_error "python3 не найден. Установите Python 3"
        return 1
    fi
    
    # Запускаем pytest тесты
    if python3 run_comprehensive_tests.py $pytest_args; then
        print_success "✅ Pytest тесты прошли успешно"
        PYTEST_RESULT=0
        ((TOTAL_TESTS_PASSED++))
    else
        print_error "❌ Pytest тесты завершились с ошибками"
        PYTEST_RESULT=1
    fi
    
    ((TOTAL_TESTS_RUN++))
    echo ""
    
    return $PYTEST_RESULT
}

# Функция для запуска bash тестов
run_bash_tests() {
    print_status "Запуск Quest API Tests (bash/curl)..."
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🔧 BASH API TESTS                               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    local bash_mode="${1:-full}"
    local failed_tests=0
    local total_bash_tests=0
    
    case "$bash_mode" in
        quick)
            print_info "Режим: Быстрые bash тесты"
            ((total_bash_tests+=2))
            test_get_quests || ((failed_tests++))
            test_get_categories || ((failed_tests++))
            ;;
        auth)
            print_info "Режим: Только авторизация"
            # Авторизация уже выполнена в get_auth_token
            ;;
        *)
            print_info "Режим: Полные bash тесты API"
            print_info "=== Тестирование чтения ==="
            ((total_bash_tests+=3))
            test_get_quests || ((failed_tests++))
            test_get_quest_by_id || ((failed_tests++))
            test_get_categories || ((failed_tests++))
            
            print_info "=== Тестирование записи ==="
            ((total_bash_tests+=3))
            test_create_quest || ((failed_tests++))
            test_update_quest || ((failed_tests++))
            test_delete_quest || ((failed_tests++))
            ;;
    esac
    
    if [ $failed_tests -eq 0 ]; then
        print_success "✅ Bash тесты прошли успешно ($total_bash_tests/$total_bash_tests)"
        BASH_TESTS_RESULT=0
        ((TOTAL_TESTS_PASSED++))
    else
        print_error "❌ Bash тесты завершились с ошибками ($((total_bash_tests-failed_tests))/$total_bash_tests прошли)"
        BASH_TESTS_RESULT=1
    fi
    
    ((TOTAL_TESTS_RUN++))
    echo ""
    
    return $BASH_TESTS_RESULT
}

# Функция для показа сводки результатов
show_test_summary() {
    echo ""
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    📊 СВОДКА РЕЗУЛЬТАТОВ                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    local overall_result=0
    
    echo -e "${YELLOW}Результаты тестирования HIGH-014:${NC}"
    echo ""
    
    # Pytest результаты
    if [ $PYTEST_RESULT -eq 0 ]; then
        echo -e "${GREEN}✅ Comprehensive Integration Tests (pytest): ПРОШЛИ${NC}"
    else
        echo -e "${RED}❌ Comprehensive Integration Tests (pytest): ПРОВАЛЕНЫ${NC}"
        overall_result=1
    fi
    
    # Bash тесты результаты
    if [ $BASH_TESTS_RESULT -eq 0 ]; then
        echo -e "${GREEN}✅ Quest API Tests (bash/curl): ПРОШЛИ${NC}"
    else
        echo -e "${RED}❌ Quest API Tests (bash/curl): ПРОВАЛЕНЫ${NC}"
        overall_result=1
    fi
    
    echo ""
    echo -e "${YELLOW}Общий результат: ${NC}$TOTAL_TESTS_PASSED/$TOTAL_TESTS_RUN групп тестов прошли"
    
    if [ $overall_result -eq 0 ]; then
        echo -e "${GREEN}🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!${NC}"
        echo -e "${CYAN}Backend API готов к production${NC}"
    else
        echo -e "${RED}💥 ЕСТЬ ПРОВАЛИВШИЕСЯ ТЕСТЫ!${NC}"
        echo -e "${YELLOW}Проверьте вывод выше для диагностики${NC}"
    fi
    
    echo ""
    return $overall_result
}

# Функция для показа помощи
show_help() {
    echo -e "${CYAN}QuestCity Backend - Comprehensive API Testing Script (HIGH-014)${NC}"
    echo ""
    echo -e "${YELLOW}Описание:${NC}"
    echo "  Объединённый скрипт для запуска ВСЕХ backend тестов созданных в HIGH-014:"
    echo "  - Comprehensive Integration Tests (pytest): CRUD, validation, error scenarios"  
    echo "  - Quest API Tests (bash/curl): полное тестирование API квестов"
    echo ""
    echo -e "${YELLOW}Использование:${NC}"
    echo "  ./test_quests_api.sh                    - Полное тестирование всех функций"
    echo "  ./test_quests_api.sh --quick            - Быстрая проверка основных функций"
    echo "  ./test_quests_api.sh --pytest-only     - Только pytest тесты"
    echo "  ./test_quests_api.sh --bash-only        - Только bash тесты"
    echo "  ./test_quests_api.sh --auth             - Только тестирование авторизации"
    echo "  ./test_quests_api.sh --help             - Показать эту справку"
    echo ""
    echo -e "${YELLOW}Pytest подрежимы (с --pytest-only):${NC}"
    echo "  ./test_quests_api.sh --pytest-only --quick        - Быстрые CRUD тесты"
    echo "  ./test_quests_api.sh --pytest-only --regression   - Регрессионные тесты"
    echo "  ./test_quests_api.sh --pytest-only --validation   - Тесты валидации"
    echo "  ./test_quests_api.sh --pytest-only --performance  - Performance тесты"
    echo ""
    echo -e "${YELLOW}Требования:${NC}"
    echo "  - Запущенный сервер QuestCity Backend"
    echo "  - Установленный jq для обработки JSON"
    echo "  - Python 3 для pytest тестов"
    echo "  - Poetry для запуска pytest (или переменная среды SKIP_POETRY=1)"
    echo ""
}

# Основная функция
main() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         🧪 QuestCity Comprehensive API Testing (HIGH-014)   ║"
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
        --auth)
            check_server
            get_auth_token
            exit 0
            ;;
        --pytest-only)
            print_status "Запуск только pytest тестов..."
            check_server
            get_auth_token
            
            local pytest_mode="all"
            if [ "${2:-}" = "--quick" ]; then
                pytest_mode="quick"
            elif [ "${2:-}" = "--regression" ]; then
                pytest_mode="regression"
            elif [ "${2:-}" = "--validation" ]; then
                pytest_mode="validation"
            elif [ "${2:-}" = "--performance" ]; then
                pytest_mode="performance"
            fi
            
            run_pytest_tests "$pytest_mode"
            show_test_summary
            exit $?
            ;;
        --bash-only)
            print_status "Запуск только bash тестов..."
            check_server
            get_auth_token
            run_bash_tests "full"
            show_test_summary
            exit $?
            ;;
        --quick)
            print_status "Запуск быстрых тестов всех типов..."
            check_server
            get_auth_token
            
            run_pytest_tests "quick"
            run_bash_tests "quick"
            show_test_summary
            exit $?
            ;;
        *)
            # Полное тестирование
            print_status "Начинаем полное comprehensive тестирование (HIGH-014)..."
            
            check_server
            get_auth_token
            
            # Запускаем все тесты последовательно
            run_pytest_tests "all"
            run_bash_tests "full"
            
            # Показываем сводку
            show_test_summary
            exit $?
            ;;
    esac
}

# Запуск
main "$@" 