# Развертывание QuestCity Backend на Timeweb Cloud

Это руководство поможет вам развернуть QuestCity Backend на облачной платформе Timeweb Cloud.

## 🏗️ Архитектура развертывания

Наше приложение будет использовать следующие сервисы Timeweb Cloud:

- **VDS сервер** - для размещения FastAPI бэкенда
- **Облачная база данных PostgreSQL** - для хранения данных
- **Объектное хранилище S3** - для хранения файлов (изображения, документы)

## 📋 Предварительные требования

1. Аккаунт на [Timeweb Cloud](https://timeweb.cloud/)
2. Домен для вашего приложения
3. SSH доступ к VDS серверу
4. Docker и Docker Compose на сервере

## 🚀 Пошаговое развертывание

### Шаг 1: Создание сервисов в Timeweb Cloud

#### 1.1 Создание VDS сервера
1. Войдите в панель управления Timeweb Cloud
2. Перейдите в раздел "Облачные серверы"
3. Создайте новый VDS сервер:
   - **ОС**: Ubuntu 22.04 LTS
   - **CPU**: 2 ядра
   - **RAM**: 4 GB
   - **Диск**: 80 GB SSD
   - **Сеть**: Публичная

#### 1.2 Создание базы данных PostgreSQL
1. Перейдите в раздел "Облачные базы данных"
2. Создайте новую базу данных:
   - **Тип**: PostgreSQL 16
   - **CPU**: 1 ядро
   - **RAM**: 2 GB
   - **Диск**: 20 GB
   - **Включить резервное копирование**: Да

#### 1.3 Создание S3 хранилища
1. Перейдите в раздел "Объектное хранилище"
2. Создайте новый bucket:
   - **Имя**: `questcity-storage`
   - **Регион**: ru-1
   - **Версионирование**: Включено
   - **Политика жизненного цикла**: 30 дней

### Шаг 2: Настройка VDS сервера

#### 2.1 Подключение к серверу
```bash
ssh root@your-server-ip
```

#### 2.2 Установка Docker и Docker Compose
```bash
# Обновление системы
apt update && apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Добавление пользователя в группу docker
usermod -aG docker $USER
```

#### 2.3 Клонирование проекта
```bash
# Создание директории проекта
mkdir -p /opt/questcity
cd /opt/questcity

# Клонирование репозитория (замените на ваш репозиторий)
git clone https://github.com/your-username/questcity-backend.git
cd questcity-backend
```

### Шаг 3: Настройка переменных окружения

#### 3.1 Копирование файла конфигурации
```bash
cd deploy
cp env.production.example .env.production
```

#### 3.2 Редактирование конфигурации
Отредактируйте файл `.env.production` с реальными данными:

```bash
nano .env.production
```

**Важные настройки для изменения:**

1. **База данных PostgreSQL**:
   ```
   DATABASE_HOST=your-database-host.timeweb.cloud
   DATABASE_USERNAME=questcity_user
   DATABASE_PASSWORD=your-database-password
   DATABASE_NAME=questcity_db
   ```

2. **S3 хранилище**:
   ```
   S3_ACCESS_KEY=your-s3-access-key
   S3_SECRET_KEY=your-s3-secret-key
   S3_ENDPOINT=https://s3.timeweb.cloud
   S3_BUCKET_NAME=questcity-storage
   ```

3. **Домен и CORS**:
   ```
   APP_ALLOW_ORIGINS=["https://questcity.yourdomain.com"]
   ```

### Шаг 4: Развертывание приложения

#### 4.1 Запуск скрипта развертывания
```bash
chmod +x deploy.sh
./deploy.sh
```

#### 4.2 Проверка статуса
```bash
docker-compose -f docker-compose.production.yml ps
```

#### 4.3 Выполнение миграций базы данных
```bash
docker-compose -f docker-compose.production.yml exec questcity-backend alembic upgrade head
```

### Шаг 5: Настройка домена и SSL

#### 5.1 Настройка DNS
1. В панели управления доменом добавьте A-запись:
   - **Имя**: `api` (или поддомен по вашему выбору)
   - **Значение**: IP-адрес вашего VDS сервера

#### 5.2 Настройка Nginx (опционально)
Для использования домена и SSL создайте конфигурацию Nginx:

```bash
# Установка Nginx
apt install nginx certbot python3-certbot-nginx -y

# Создание конфигурации
cat > /etc/nginx/sites-available/questcity << EOF
server {
    listen 80;
    server_name api.questcity.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Активация сайта
ln -s /etc/nginx/sites-available/questcity /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# Получение SSL сертификата
certbot --nginx -d api.questcity.yourdomain.com
```

## 🔧 Мониторинг и обслуживание

### Просмотр логов
```bash
# Логи приложения
docker-compose -f docker-compose.production.yml logs -f questcity-backend

# Логи Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Обновление приложения
```bash
# Остановка приложения
docker-compose -f docker-compose.production.yml down

# Обновление кода
git pull origin main

# Пересборка и запуск
docker-compose -f docker-compose.production.yml up -d --build
```

### Резервное копирование
```bash
# Создание резервной копии базы данных
docker-compose -f docker-compose.production.yml exec questcity-backend pg_dump -h $DATABASE_HOST -U $DATABASE_USERNAME -d $DATABASE_NAME > backup_$(date +%Y%m%d_%H%M%S).sql
```

## 🚨 Безопасность

### Настройка файрвола
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

### Регулярные обновления
```bash
# Автоматические обновления безопасности
apt install unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

## 📊 Мониторинг производительности

### Установка мониторинга
```bash
# Установка htop для мониторинга ресурсов
apt install htop

# Установка netdata для веб-мониторинга
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

## 🆘 Устранение неполадок

### Проверка статуса сервисов
```bash
# Статус Docker контейнеров
docker ps

# Статус системных сервисов
systemctl status nginx
systemctl status docker
```

### Проверка подключения к базе данных
```bash
docker-compose -f docker-compose.production.yml exec questcity-backend python -c "
import asyncio
import asyncpg
import os

async def test_db():
    try:
        conn = await asyncpg.connect(os.getenv('DATABASE_URL'))
        print('✅ Подключение к базе данных успешно')
        await conn.close()
    except Exception as e:
        print(f'❌ Ошибка подключения к БД: {e}')

asyncio.run(test_db())
"
```

### Проверка S3 подключения
```bash
docker-compose -f docker-compose.production.yml exec questcity-backend python -c "
import boto3
import os

try:
    s3 = boto3.client(
        's3',
        endpoint_url=os.getenv('S3_ENDPOINT'),
        aws_access_key_id=os.getenv('S3_ACCESS_KEY'),
        aws_secret_access_key=os.getenv('S3_SECRET_KEY')
    )
    s3.list_buckets()
    print('✅ Подключение к S3 успешно')
except Exception as e:
    print(f'❌ Ошибка подключения к S3: {e}')
"
```

## 📞 Поддержка

Если у вас возникли проблемы с развертыванием:

1. Проверьте логи приложения
2. Убедитесь, что все переменные окружения настроены правильно
3. Проверьте подключение к базе данных и S3
4. Обратитесь в поддержку Timeweb Cloud при проблемах с их сервисами

## 🔗 Полезные ссылки

- [Документация Timeweb Cloud](https://timeweb.cloud/docs/)
- [Документация FastAPI](https://fastapi.tiangolo.com/)
- [Документация PostgreSQL](https://www.postgresql.org/docs/)
- [Документация Docker](https://docs.docker.com/)











