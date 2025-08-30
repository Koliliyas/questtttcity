#!/bin/bash

# Скрипт для переключения между окружениями QuestCity Frontend
# Использование: ./switch_env.sh [development|production]

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Проверка аргумента
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Укажите окружение: development или production${NC}"
    echo "Использование: $0 [development|production]"
    exit 1
fi

ENVIRONMENT=$1

# Проверка валидности окружения
if [ "$ENVIRONMENT" != "development" ] && [ "$ENVIRONMENT" != "production" ]; then
    echo -e "${RED}❌ Неверное окружение. Используйте: development или production${NC}"
    exit 1
fi

echo -e "${BLUE}🔄 Переключение окружения QuestCity Frontend на: $ENVIRONMENT${NC}"

# Определяем файлы
DEV_FILE="env.development"
PROD_FILE="env.production"
TARGET_FILE=".env"

# Проверяем существование файлов
if [ ! -f "$DEV_FILE" ]; then
    echo -e "${RED}❌ Файл $DEV_FILE не найден!${NC}"
    exit 1
fi

if [ ! -f "$PROD_FILE" ]; then
    echo -e "${RED}❌ Файл $PROD_FILE не найден!${NC}"
    exit 1
fi

# Создаем резервную копию текущего .env
if [ -f "$TARGET_FILE" ]; then
    BACKUP_FILE=".env.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$TARGET_FILE" "$BACKUP_FILE"
    echo -e "${YELLOW}📦 Создана резервная копия: $BACKUP_FILE${NC}"
fi

# Копируем нужную конфигурацию
if [ "$ENVIRONMENT" = "development" ]; then
    cp "$DEV_FILE" "$TARGET_FILE"
    echo -e "${GREEN}✅ Переключено на DEVELOPMENT (localhost:8000)${NC}"
    echo -e "   📍 API URL: http://localhost:8000/api/v1/"
else
    cp "$PROD_FILE" "$TARGET_FILE"
    echo -e "${GREEN}✅ Переключено на PRODUCTION (questcity.ru)${NC}"
    echo -e "   📍 API URL: http://questcity.ru/api/v1.0/"
fi

echo ""
echo -e "${BLUE}🔧 Следующие шаги:${NC}"
echo -e "   1. Перезапустите Flutter: flutter clean && flutter pub get"
echo -e "   2. Запустите приложение: flutter run"
echo ""
echo -e "${BLUE}📋 Текущая конфигурация:${NC}"
while IFS= read -r line; do
    echo -e "   $line"
done < "$TARGET_FILE"

