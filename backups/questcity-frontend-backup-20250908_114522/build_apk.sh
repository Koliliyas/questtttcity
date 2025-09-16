#!/bin/bash

# Скрипт для сборки APK QuestCity с продакшен конфигурацией

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Сборка APK QuestCity для продакшена${NC}"

# Переключаемся на продакшен
echo -e "${YELLOW}🔄 Переключение на продакшен конфигурацию...${NC}"
./switch_env.sh production

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка переключения окружения!${NC}"
    exit 1
fi

# Очищаем и получаем зависимости
echo -e "${YELLOW}🧹 Очистка проекта...${NC}"
flutter clean

echo -e "${YELLOW}📦 Получение зависимостей...${NC}"
flutter pub get

# Собираем APK
echo -e "${YELLOW}🔨 Сборка APK...${NC}"
flutter build apk --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ APK успешно собран!${NC}"
    echo -e "${BLUE}📱 Файл: build/app/outputs/flutter-apk/app-release.apk${NC}"
    echo -e "${BLUE}🌐 API URL: http://questcity.ru/api/v1.0/${NC}"
else
    echo -e "${RED}❌ Ошибка сборки APK!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔧 Для возврата к разработке выполните:${NC}"
echo -e "   ./switch_env.sh development"
































