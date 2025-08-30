# QuestCity Cloud Connection Report

## 📊 Текущее состояние подключения

**Дата проверки:** 29 августа 2025  
**Сервер:** 176.98.177.16  
**Домен:** questcity.ru  

### ✅ Что работает:

1. **DNS резолюция** - домен корректно указывает на сервер
2. **SSH подключение** - доступ к серверу работает
3. **Docker контейнер** - бэкенд запущен и работает
4. **Nginx** - веб-сервер активен
5. **API через IP** - `http://176.98.177.16/api/v1/health/` отвечает со статусом 200

### ❌ Проблемы:

1. **SSL сертификат не настроен** - HTTPS недоступен
2. **Редирект на HTTPS** - домен пытается перенаправить на HTTPS
3. **404 на корневой путь** - `http://questcity.ru/` возвращает 404

## 🔧 План исправления

### Шаг 1: Настройка SSL сертификата
```bash
# Подключитесь к серверу
ssh root@176.98.177.16

# Запустите скрипт настройки
chmod +x deploy_cloud.sh
./deploy_cloud.sh
```

### Шаг 2: Проверка конфигурации nginx
Убедитесь, что конфигурация `/etc/nginx/sites-available/questcity-backend` корректна.

### Шаг 3: Обновление фронтенда
Настройте фронтенд для работы с HTTPS:
```bash
cd questcity-frontend
cp .env.production .env
# Обновите BASE_URL на https://questcity.ru/api/v1.0/
```

## 📋 Команды для проверки

### Проверка сервисов на сервере:
```bash
# Статус nginx
systemctl status nginx

# Статус Docker контейнеров
docker ps

# Проверка API
curl http://localhost:8000/api/v1/health/

# Проверка nginx конфигурации
nginx -t
```

### Проверка с локальной машины:
```bash
# DNS резолюция
nslookup questcity.ru

# Проверка HTTP
curl -I http://questcity.ru/api/v1/health/

# Проверка HTTPS (после настройки SSL)
curl -I https://questcity.ru/api/v1/health/
```

## 🎯 Ожидаемый результат

После настройки:
- ✅ `http://questcity.ru/api/v1/health/` - работает
- ✅ `https://questcity.ru/api/v1/health/` - работает с SSL
- ✅ Автоматический редирект с HTTP на HTTPS
- ✅ Фронтенд может подключаться к API

## 📞 Контакты для поддержки

- **Провайдер:** Timeweb Cloud
- **IP сервера:** 176.98.177.16
- **Домен:** questcity.ru
- **SSH:** `ssh root@176.98.177.16`

---

**Статус:** Требует настройки SSL сертификата  
**Приоритет:** Высокий  
**Сложность:** Средняя

