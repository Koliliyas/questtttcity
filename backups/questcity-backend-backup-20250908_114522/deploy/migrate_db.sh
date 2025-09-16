#!/bin/bash

# Скрипт для переноса данных с локальной БД на сервер Timeweb Cloud
# ИЗМЕНИТЕ ПАРАМЕТРЫ ЛОКАЛЬНОЙ БД НИЖЕ

# Параметры локальной БД (из .env.backup)
LOCAL_HOST="localhost"
LOCAL_PORT="5432"
LOCAL_USER="postgres"
LOCAL_PASSWORD="postgres"
LOCAL_DB="questcity_db"

# Параметры серверной БД (Timeweb Cloud)
SERVER_HOST="7da2c0adf39345ca39269f40.twc1.net"
SERVER_PORT="5432"
SERVER_USER="gen_user"
SERVER_PASSWORD="|dls1z:N7#v>vr"
SERVER_DB="default_db"
SERVER_SSLMODE="verify-full"

# IP сервера
SERVER_IP="176.98.177.16"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Скрипт переноса данных с локальной БД на сервер${NC}"
echo "============================================================"

# Проверяем наличие pg_dump
if ! command -v pg_dump &> /dev/null; then
    echo -e "${RED}❌ pg_dump не найден. Установите PostgreSQL client tools.${NC}"
    exit 1
fi

# Создаем имя файла для бэкапа
BACKUP_FILE="db_backup_$(date +%Y%m%d_%H%M%S).sql"

echo -e "${YELLOW}📁 Создание бэкапа локальной БД...${NC}"
echo "Команда: pg_dump -h $LOCAL_HOST -p $LOCAL_PORT -U $LOCAL_USER -d $LOCAL_DB"

# Создаем бэкап
PGPASSWORD="$LOCAL_PASSWORD" pg_dump -h "$LOCAL_HOST" -p "$LOCAL_PORT" -U "$LOCAL_USER" -d "$LOCAL_DB" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Бэкап создан успешно: $BACKUP_FILE${NC}"
    
    # Проверяем размер файла
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo -e "${YELLOW}📊 Размер файла: $FILE_SIZE${NC}"
    
    echo -e "${YELLOW}📤 Загрузка файла на сервер...${NC}"
    
    # Загружаем файл на сервер
    scp "$BACKUP_FILE" "root@$SERVER_IP:/opt/questcity/questcity-backend/"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Файл загружен на сервер${NC}"
        
        echo -e "${YELLOW}📥 Импорт данных на сервере...${NC}"
        
        # Импортируем данные на сервере
        ssh "root@$SERVER_IP" "cd /opt/questcity/questcity-backend && PGPASSWORD='$SERVER_PASSWORD' psql -h '$SERVER_HOST' -p '$SERVER_PORT' -U '$SERVER_USER' -d '$SERVER_DB' -c 'SET sslmode=$SERVER_SSLMODE;' < $BACKUP_FILE"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Данные импортированы успешно${NC}"
            
            echo -e "${YELLOW}🧹 Очистка временных файлов...${NC}"
            
            # Очищаем временные файлы
            rm "$BACKUP_FILE"
            ssh "root@$SERVER_IP" "cd /opt/questcity/questcity-backend && rm $BACKUP_FILE"
            
            echo -e "${GREEN}🎉 Перенос данных завершен успешно!${NC}"
            echo "============================================================"
        else
            echo -e "${RED}❌ Ошибка импорта данных на сервере${NC}"
        fi
    else
        echo -e "${RED}❌ Ошибка загрузки файла на сервер${NC}"
    fi
else
    echo -e "${RED}❌ Ошибка создания бэкапа${NC}"
    exit 1
fi
