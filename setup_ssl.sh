#!/bin/bash

# Скрипт для настройки SSL сертификата для QuestCity
echo "🔒 Настройка SSL сертификата для questcity.ru"

# Установка certbot
echo "📦 Установка certbot..."
apt-get update
apt-get install -y certbot python3-certbot-nginx

# Получение SSL сертификата
echo "🎫 Получение SSL сертификата..."
certbot --nginx -d questcity.ru -d www.questcity.ru --non-interactive --agree-tos --email admin@questcity.ru

# Проверка автообновления
echo "🔄 Настройка автообновления сертификата..."
crontab -l 2>/dev/null | { cat; echo "0 12 * * * /usr/bin/certbot renew --quiet"; } | crontab -

echo "✅ SSL сертификат настроен!"
echo "🔍 Проверьте: https://questcity.ru"

