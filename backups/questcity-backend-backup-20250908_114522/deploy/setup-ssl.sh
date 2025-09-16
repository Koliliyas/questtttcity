#!/bin/bash

# Скрипт настройки SSL сертификатов для QuestCity Backend
# Использование: ./setup-ssl.sh your-domain.com

set -e

DOMAIN=${1:-"api.questcity.yourdomain.com"}

if [ -z "$1" ]; then
    echo "❌ Укажите домен в качестве параметра"
    echo "Использование: ./setup-ssl.sh your-domain.com"
    exit 1
fi

echo "🔒 Настройка SSL сертификатов для домена: $DOMAIN"

# Проверка наличия Nginx
if ! command -v nginx &> /dev/null; then
    echo "📦 Устанавливаем Nginx..."
    apt update
    apt install -y nginx
fi

# Проверка наличия Certbot
if ! command -v certbot &> /dev/null; then
    echo "📦 Устанавливаем Certbot..."
    apt install -y certbot python3-certbot-nginx
fi

# Создание временной конфигурации Nginx для получения сертификата
echo "📝 Создание временной конфигурации Nginx..."
cat > /etc/nginx/sites-available/questcity-temp << EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Активация временной конфигурации
ln -sf /etc/nginx/sites-available/questcity-temp /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверка конфигурации Nginx
nginx -t

# Перезапуск Nginx
systemctl reload nginx

# Получение SSL сертификата
echo "🔐 Получение SSL сертификата..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

# Копирование production конфигурации Nginx
echo "📝 Установка production конфигурации Nginx..."
cp deploy/nginx.conf /etc/nginx/nginx.conf

# Замена домена в конфигурации
sed -i "s/api\.questcity\.yourdomain\.com/$DOMAIN/g" /etc/nginx/nginx.conf

# Проверка конфигурации
nginx -t

# Перезапуск Nginx
systemctl reload nginx

# Настройка автоматического обновления сертификатов
echo "🔄 Настройка автоматического обновления сертификатов..."
cat > /etc/cron.d/certbot-renew << EOF
0 12 * * * /usr/bin/certbot renew --quiet
EOF

# Установка прав на cron файл
chmod 644 /etc/cron.d/certbot-renew

echo "✅ SSL сертификаты настроены успешно!"
echo ""
echo "📋 Информация:"
echo "   Домен: $DOMAIN"
echo "   SSL сертификат: /etc/letsencrypt/live/$DOMAIN/"
echo "   Автообновление: настроено (ежедневно в 12:00)"
echo ""
echo "🔗 Проверьте доступность: https://$DOMAIN"











