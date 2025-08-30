#!/bin/bash

# Скрипт для настройки облачного сервиса QuestCity
echo "🚀 Настройка облачного сервиса QuestCity"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✅ OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[⚠️ WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[❌ ERROR]${NC} $1"; }

# 1. Проверка статуса сервисов
log_info "Проверка статуса сервисов..."
if systemctl is-active --quiet nginx; then
    log_success "Nginx работает"
else
    log_error "Nginx не работает"
    exit 1
fi

if docker ps | grep -q questcity-backend; then
    log_success "Docker контейнер работает"
else
    log_error "Docker контейнер не работает"
    exit 1
fi

# 2. Обновление конфигурации nginx
log_info "Обновление конфигурации nginx..."
cp /etc/nginx/sites-available/questcity-backend /etc/nginx/sites-available/questcity-backend.backup.$(date +%Y%m%d_%H%M%S)

# Создание новой конфигурации
cat > /etc/nginx/sites-available/questcity-backend << 'EOF'
server {
    listen 80;
    server_name questcity.ru www.questcity.ru 176.98.177.16;

    # Логи
    access_log /var/log/nginx/questcity-backend.access.log;
    error_log /var/log/nginx/questcity-backend.error.log;

    # Проксирование на бэкенд
    location / {
        proxy_pass http://172.18.0.2:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Таймауты
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Специальная обработка для API
    location /api/ {
        proxy_pass http://172.18.0.2:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check
    location /health {
        proxy_pass http://172.18.0.2:8000;
        proxy_set_header Host $host;
    }
}
EOF

# 3. Проверка конфигурации nginx
log_info "Проверка конфигурации nginx..."
if nginx -t; then
    log_success "Конфигурация nginx корректна"
else
    log_error "Ошибка в конфигурации nginx"
    exit 1
fi

# 4. Перезагрузка nginx
log_info "Перезагрузка nginx..."
systemctl reload nginx
if [ $? -eq 0 ]; then
    log_success "Nginx перезагружен"
else
    log_error "Ошибка перезагрузки nginx"
    exit 1
fi

# 5. Установка SSL сертификата
log_info "Установка SSL сертификата..."
if command -v certbot &> /dev/null; then
    log_info "Certbot уже установлен"
else
    log_info "Установка certbot..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi

# Получение SSL сертификата
log_info "Получение SSL сертификата..."
certbot --nginx -d questcity.ru -d www.questcity.ru --non-interactive --agree-tos --email admin@questcity.ru

if [ $? -eq 0 ]; then
    log_success "SSL сертификат установлен"
else
    log_warning "Ошибка установки SSL сертификата"
fi

# 6. Настройка автообновления сертификата
log_info "Настройка автообновления сертификата..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -

# 7. Финальная проверка
log_info "Финальная проверка..."
sleep 5

# Проверка HTTP
if curl -s -f http://questcity.ru/api/v1/health/ >/dev/null 2>&1; then
    log_success "HTTP API работает"
else
    log_warning "HTTP API не отвечает"
fi

# Проверка HTTPS
if curl -s -f https://questcity.ru/api/v1/health/ >/dev/null 2>&1; then
    log_success "HTTPS API работает"
else
    log_warning "HTTPS API не отвечает"
fi

echo ""
log_success "Настройка завершена!"
echo "🌐 Проверьте:"
echo "   HTTP:  http://questcity.ru/api/v1/health/"
echo "   HTTPS: https://questcity.ru/api/v1/health/"

