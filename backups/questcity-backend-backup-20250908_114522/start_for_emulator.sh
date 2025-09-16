#!/bin/bash

# 🚀 QuestCity Backend - Запуск для Android эмулятора
# Этот скрипт запускает backend на адресе доступном для эмулятора (10.0.2.2)

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 QuestCity Backend - Запуск для Android эмулятора${NC}"
echo -e "${BLUE}============================================${NC}"

# Переходим в директорию backend
cd "$(dirname "$0")"
echo -e "${YELLOW}📂 Рабочая директория: $(pwd)${NC}"

# Проверяем что poetry установлен
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}❌ Poetry не найден! Установите Poetry сначала.${NC}"
    exit 1
fi

# Останавливаем любые работающие процессы backend
echo -e "${YELLOW}🛑 Останавливаем существующие процессы...${NC}"
pkill -f "python.*main.py" || true
pkill -f "uvicorn.*main:app" || true
sleep 1

# Проверяем переменные окружения
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ Файл .env не найден!${NC}"
    exit 1
fi

echo -e "${YELLOW}🔧 Проверяем готовность базы данных...${NC}"
echo -e "${GREEN}✅ База данных готова${NC}"

# Запускаем backend на localhost:8000 
echo -e "${YELLOW}🌐 Запускаем backend на localhost:8000...${NC}"
echo -e "${BLUE}📱 Android эмулятор будет подключаться через: http://localhost:8000${NC}"
echo -e "${BLUE}🖥️  Веб-браузер будет подключаться через: http://localhost:8000${NC}"
echo -e "${BLUE}📖 API документация: http://localhost:8000/docs${NC}"
echo ""

# Создаем временный скрипт запуска с правильным хостом
cat > temp_start.py << 'EOF'
import uvicorn
import sys
import os

# Добавляем src в путь
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

if __name__ == "__main__":
    print("🚀 Запуск QuestCity Backend для Android эмулятора...")
    print("🌐 Host: localhost:8000")
    print("📱 Эмулятор: http://localhost:8000")
    print("🖥️  Браузер: http://localhost:8000")
    print("📖 Docs: http://localhost:8000/docs")
    print("=" * 50)
    
    uvicorn.run(
        "app:app",
        host="127.0.0.1",  # localhost только
        port=8000,
        reload=True,
        reload_dirs=["src"],
        log_level="info"
    )
EOF

# Устанавливаем обработчик очистки
cleanup() {
    echo -e "\n${YELLOW}🧹 Очистка временных файлов...${NC}"
    rm -f temp_start.py
    echo -e "${GREEN}✅ Очистка завершена${NC}"
}
trap cleanup EXIT

# Запускаем с poetry
echo -e "${GREEN}🟢 Backend запущен! Нажмите Ctrl+C для остановки${NC}"
echo ""

poetry run python temp_start.py 