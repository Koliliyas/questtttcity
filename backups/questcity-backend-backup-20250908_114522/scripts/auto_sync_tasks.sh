#!/bin/bash

# 🤖 Автоматическая синхронизация задач QuestCity Backend
# Запускается при изменениях в отчетах или вручную

set -e  # Прерывать выполнение при ошибках

# Конфигурация
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_ROOT/../docs"
SYNC_SCRIPT="$SCRIPT_DIR/sync_tasks.py"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Логирование
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Функция проверки изменений
check_changes() {
    log_info "Проверка изменений в отчетах..."
    
    # Проверяем наличие папки docs
    if [ ! -d "$DOCS_DIR" ]; then
        log_warning "Папка docs не найдена: $DOCS_DIR"
        return 1
    fi
    
    # Если это Git hook, проверяем только зафиксированные изменения
    if [ "${GIT_HOOK:-false}" = "true" ]; then
        changed_files=$(git diff --name-only HEAD~1 HEAD | grep -E "docs/.*\.(md|txt)$" || true)
    else
        # Иначе проверяем все изменения с последнего коммита
        changed_files=$(git status --porcelain "$DOCS_DIR" | grep -E "\.(md|txt)$" || true)
    fi
    
    if [ -z "$changed_files" ]; then
        log_info "Изменений в документации не обнаружено"
        return 1
    fi
    
    log_info "Обнаружены изменения в файлах:"
    echo "$changed_files" | while read -r file; do
        echo "  📄 $file"
    done
    
    return 0
}

# Функция синхронизации
sync_tasks() {
    log_info "Запуск синхронизации задач..."
    
    # Проверяем наличие скрипта синхронизации
    if [ ! -f "$SYNC_SCRIPT" ]; then
        log_error "Скрипт синхронизации не найден: $SYNC_SCRIPT"
        return 1
    fi
    
    # Переходим в директорию проекта
    cd "$PROJECT_ROOT" || {
        log_error "Не удается перейти в директорию проекта: $PROJECT_ROOT"
        return 1
    }
    
    # Запускаем синхронизацию
    if python3 "$SYNC_SCRIPT" --verbose; then
        log_success "Синхронизация задач завершена успешно"
        return 0
    else
        log_error "Ошибка при синхронизации задач"
        return 1
    fi
}

# Функция обновления дат
update_dates() {
    log_info "Обновление дат в документах..."
    
    cd "$PROJECT_ROOT" || {
        log_error "Не удается перейти в директорию проекта: $PROJECT_ROOT"
        return 1
    }
    
    if python3 "$SYNC_SCRIPT" --update-dates; then
        log_success "Даты обновлены успешно"
        return 0
    else
        log_warning "Предупреждение при обновлении дат"
        return 0  # Не критическая ошибка
    fi
}

# Функция коммита изменений
commit_changes() {
    log_info "Проверка изменений для коммита..."
    
    cd "$PROJECT_ROOT" || return 1
    
    # Проверяем, есть ли изменения в TASKS.md или COMPLETED_TASKS.md
    if git diff --quiet TASKS.md COMPLETED_TASKS.md 2>/dev/null; then
        log_info "Изменений в файлах задач не обнаружено"
        return 0
    fi
    
    # Добавляем изменения
    git add TASKS.md COMPLETED_TASKS.md 2>/dev/null || true
    
    # Создаем коммит с автоматическим сообщением
    current_date=$(date '+%d %B %Y')
    commit_message="🤖 Автоматическое обновление задач - $current_date"
    
    if git commit -m "$commit_message" 2>/dev/null; then
        log_success "Изменения зафиксированы в Git"
    else
        log_info "Нет изменений для коммита или коммит не требуется"
    fi
}

# Основная функция
main() {
    echo ""
    log_info "🤖 QuestCity Backend - Автоматическая синхронизация задач"
    echo ""
    
    # Проверяем аргументы командной строки
    case "${1:-auto}" in
        "force")
            log_info "Принудительная синхронизация..."
            ;;
        "update-dates")
            log_info "Только обновление дат..."
            update_dates
            exit $?
            ;;
        "auto")
            # Проверяем изменения только в автоматическом режиме
            if ! check_changes; then
                log_info "Синхронизация не требуется"
                exit 0
            fi
            ;;
        "help"|"-h"|"--help")
            echo "Использование: $0 [auto|force|update-dates|help]"
            echo ""
            echo "Режимы:"
            echo "  auto        - Синхронизация при обнаружении изменений (по умолчанию)"
            echo "  force       - Принудительная синхронизация"
            echo "  update-dates - Только обновление дат в документах"
            echo "  help        - Показать эту справку"
            echo ""
            exit 0
            ;;
        *)
            log_error "Неизвестный режим: $1"
            echo "Используйте '$0 help' для получения справки"
            exit 1
            ;;
    esac
    
    # Обновляем даты
    update_dates
    
    # Выполняем синхронизацию
    if sync_tasks; then
        # Коммитим изменения (если не Git hook)
        if [ "${GIT_HOOK:-false}" != "true" ]; then
            commit_changes
        fi
        
        echo ""
        log_success "Автоматическая синхронизация завершена!"
        echo ""
        log_info "📋 Актуальные задачи: TASKS.md"
        log_info "✅ Выполненные задачи: COMPLETED_TASKS.md"
        echo ""
    else
        log_error "Синхронизация завершилась с ошибкой"
        exit 1
    fi
}

# Обработка сигналов
trap 'log_error "Синхронизация прервана"; exit 130' INT TERM

# Запуск
main "$@" 