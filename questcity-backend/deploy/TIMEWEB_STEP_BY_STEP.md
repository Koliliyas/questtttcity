# Пошаговое развертывание QuestCity на Timeweb Cloud

## 🚀 Шаг 1: Создание VDS сервера

### 1.1 Вход в панель управления
1. Откройте [https://timeweb.cloud/](https://timeweb.cloud/)
2. Войдите в свой аккаунт
3. Перейдите в раздел **"Облачные серверы"**

### 1.2 Создание сервера
1. Нажмите **"Создать сервер"**
2. Выберите конфигурацию:
   - **ОС**: Ubuntu 22.04 LTS
   - **CPU**: 2 ядра
   - **RAM**: 4 GB
   - **Диск**: 80 GB SSD
   - **Сеть**: Публичная
3. Нажмите **"Создать"**
4. Дождитесь создания сервера (2-3 минуты)
5. **Запишите IP-адрес сервера** - он понадобится для настройки

## 🗄️ Шаг 2: Создание базы данных PostgreSQL

### 2.1 Создание БД
1. Перейдите в раздел **"Облачные базы данных"**
2. Нажмите **"Создать базу данных"**
3. Выберите настройки:
   - **Тип**: PostgreSQL 16
   - **CPU**: 1 ядро
   - **RAM**: 2 GB
   - **Диск**: 20 GB
   - **Резервное копирование**: Включить
4. Нажмите **"Создать"**

### 2.2 Настройка пользователя БД
1. После создания БД перейдите в её настройки
2. Создайте пользователя:
   - **Имя пользователя**: `questcity_user`
   - **Пароль**: сгенерируйте сложный пароль
3. **Запишите данные подключения**:
   - Хост БД
   - Порт (обычно 5432)
   - Имя базы данных
   - Имя пользователя и пароль

## 📦 Шаг 3: Создание S3 хранилища

### 3.1 Создание bucket
1. Перейдите в раздел **"Объектное хранилище"**
2. Нажмите **"Создать bucket"**
3. Настройте:
   - **Имя**: `questcity-storage`
   - **Регион**: ru-1
   - **Версионирование**: Включить
4. Нажмите **"Создать"**

### 3.2 Создание ключей доступа
1. Перейдите в **"API ключи"** в разделе S3
2. Создайте новый ключ доступа
3. **Запишите**:
   - Access Key ID
   - Secret Access Key

## 🔧 Шаг 4: Подключение к VDS серверу

### 4.1 Получение данных для подключения
1. В панели управления перейдите к вашему VDS серверу
2. Найдите **IP-адрес** сервера
3. Найдите **пароль root** (или создайте SSH ключ)

### 4.2 Подключение по SSH
```bash
# Windows (PowerShell или Git Bash)
ssh root@YOUR_SERVER_IP

# Mac/Linux
ssh root@YOUR_SERVER_IP
```

## 🐳 Шаг 5: Установка Docker на сервере

```bash
# Обновление системы
apt update && apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Проверка установки
docker --version
docker-compose --version
```

## 📁 Шаг 6: Загрузка проекта на сервер

### 6.1 Создание директории проекта
```bash
mkdir -p /opt/questcity
cd /opt/questcity
```

### 6.2 Загрузка файлов
У вас есть несколько вариантов:

**Вариант A: Клонирование из Git (если проект в репозитории)**
```bash
git clone https://github.com/your-username/questcity-backend.git
cd questcity-backend
```

**Вариант B: Загрузка через SCP (если проект локально)**
```bash
# На вашем локальном компьютере выполните:
scp -r questcity-backend root@YOUR_SERVER_IP:/opt/questcity/
```

**Вариант C: Создание файлов вручную**
```bash
# Создайте структуру проекта
mkdir -p questcity-backend/src questcity-backend/deploy
cd questcity-backend
```

## ⚙️ Шаг 7: Настройка переменных окружения

### 7.1 Создание файла конфигурации
```bash
cd /opt/questcity/questcity-backend/deploy
cp env.production.example .env.production
nano .env.production
```

### 7.2 Заполнение реальных данных
Замените следующие значения в файле `.env.production`:

```bash
# Настройки базы данных (данные из шага 2)
DATABASE_HOST=your-database-host.timeweb.cloud
DATABASE_USERNAME=questcity_user
DATABASE_PASSWORD=your-database-password
DATABASE_NAME=questcity_db

# Настройки S3 (данные из шага 3)
S3_ACCESS_KEY=your-s3-access-key
S3_SECRET_KEY=your-s3-secret-key
S3_ENDPOINT=https://s3.timeweb.cloud
S3_BUCKET_NAME=questcity-storage

# Настройки домена (замените на ваш домен)
APP_ALLOW_ORIGINS=["https://questcity.yourdomain.com"]

# Секретный ключ (сгенерируйте новый)
APP_SESSION_SECRET_KEY=your-super-secret-session-key-change-this
```

## 🚀 Шаг 8: Развертывание приложения

### 8.1 Запуск скрипта развертывания
```bash
cd /opt/questcity/questcity-backend
chmod +x deploy/deploy.sh
./deploy/deploy.sh
```

### 8.2 Проверка статуса
```bash
docker-compose -f docker-compose.production.yml ps
```

### 8.3 Выполнение миграций БД
```bash
docker-compose -f docker-compose.production.yml exec questcity-backend alembic upgrade head
```

## 🌐 Шаг 9: Настройка домена и SSL

### 9.1 Настройка DNS
1. В панели управления вашим доменом добавьте A-запись:
   - **Имя**: `api` (или поддомен по вашему выбору)
   - **Значение**: IP-адрес вашего VDS сервера

### 9.2 Настройка SSL
```bash
cd /opt/questcity/questcity-backend
chmod +x deploy/setup-ssl.sh
./deploy/setup-ssl.sh api.questcity.yourdomain.com
```

## 🔒 Шаг 10: Настройка безопасности

### 10.1 Настройка файрвола
```bash
# Установка UFW
apt install ufw

# Настройка правил
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80
ufw allow 443
ufw enable
```

### 10.2 Автоматические обновления
```bash
apt install unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

## ✅ Шаг 11: Проверка работоспособности

### 11.1 Проверка API
```bash
# Проверка health endpoint
curl http://localhost:8000/health

# Проверка документации API
curl http://localhost:8000/docs
```

### 11.2 Проверка через браузер
Откройте в браузере:
- `http://YOUR_SERVER_IP:8000/docs` - документация API
- `https://api.questcity.yourdomain.com/docs` - через домен (после настройки SSL)

## 📊 Шаг 12: Мониторинг

### 12.1 Установка инструментов мониторинга
```bash
# Установка htop
apt install htop

# Установка netdata (опционально)
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

### 12.2 Просмотр логов
```bash
# Логи приложения
docker-compose -f docker-compose.production.yml logs -f questcity-backend

# Логи Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## 🆘 Возможные проблемы и решения

### Проблема: Не удается подключиться к базе данных
**Решение:**
```bash
# Проверьте настройки БД в .env.production
# Убедитесь, что IP сервера добавлен в белый список БД в Timeweb Cloud
```

### Проблема: Ошибки при сборке Docker образа
**Решение:**
```bash
# Очистите Docker кэш
docker system prune -a

# Пересоберите образ
docker-compose -f docker-compose.production.yml build --no-cache
```

### Проблема: SSL сертификат не работает
**Решение:**
```bash
# Проверьте настройки DNS
nslookup api.questcity.yourdomain.com

# Переустановите сертификат
certbot --nginx -d api.questcity.yourdomain.com --force-renewal
```

## 📞 Поддержка

Если возникли проблемы:
1. Проверьте логи: `docker-compose -f docker-compose.production.yml logs`
2. Обратитесь в поддержку Timeweb Cloud через чат в панели управления
3. Проверьте статус сервисов Timeweb Cloud

## 🎉 Готово!

Ваш QuestCity Backend успешно развернут на Timeweb Cloud!

**Доступные URL:**
- API: `https://api.questcity.yourdomain.com`
- Документация: `https://api.questcity.yourdomain.com/docs`
- Health check: `https://api.questcity.yourdomain.com/health`



