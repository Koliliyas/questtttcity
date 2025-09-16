# QuestCity Backend - Анализ зависимостей и план запуска

## 🔍 Полный анализ текущего состояния

### ✅ Что работает:
1. **PostgreSQL 16** - запущен через Homebrew, база данных `questcity_test` создана (24 таблицы)
2. **Poetry** - управление зависимостями Python работает
3. **Python 3.12** - установлен и настроен
4. **Flutter** - установлен и настроен для фронтенда

### ❌ Что НЕ работает:
1. **Docker** - не установлен (`docker: command not found`)
2. **MinIO/S3** - не запущен (нужен для файлового хранилища)
3. **JWT ключи** - не созданы (папка `certs/` пустая)
4. **Health Checker** - зависает на multiprocessing

### ⚠️ Проблемные компоненты:
1. **Mail сервер** - настроены только заглушки (не критично для разработки)
2. **S3 Health Check** - пытается подключиться к несуществующему MinIO

## 🎯 Обязательные зависимости для запуска Backend

### 1. **PostgreSQL** ✅
- **Статус:** Работает
- **Адрес:** localhost:5432
- **База:** questcity_test
- **Пользователь:** evgenijglusenko
- **Миграции:** Применены (24 таблицы)

### 2. **JWT ключи** ❌
- **Статус:** Отсутствуют
- **Путь:** `questcity-backend/main/certs/`
- **Требуется:** jwt-private.pem, jwt-public.pem
- **Создаются автоматически** при первом запуске

### 3. **MinIO (S3 хранилище)** ❌
- **Статус:** Не запущен
- **Требуется:** localhost:9000
- **Зависимость:** Docker или локальная установка
- **Используется для:** Загрузка файлов квестов, аватары, медиа

### 4. **Environment переменные** ✅
- **Статус:** Настроены в .env
- **Все обязательные:** Присутствуют

## 📋 План поэтапного запуска

### Этап 1: Установка Docker (обязательно)
```bash
# macOS
brew install --cask docker
# Или скачать с https://www.docker.com/products/docker-desktop/
```

### Этап 2: Запуск зависимых сервисов
```bash
cd questcity-backend/main

# Запуск только MinIO через Docker Compose
docker-compose up -d minio

# Проверка что MinIO запустился
curl http://localhost:9000/minio/health/ready
```

### Этап 3: Создание MinIO bucket
```bash
# Доступ к MinIO консоли: http://localhost:9001
# Логин: testuser
# Пароль: testpassword
# Создать bucket: questcity-test
```

### Этап 4: Исправление Health Checker
Проблема в multiprocessing - нужно использовать Threading вместо Process для macOS.

### Этап 5: Запуск Backend
```bash
cd questcity-backend/main
poetry run python3 main.py
```

## 🛠 Альтернативные решения

### Вариант 1: Полный Docker запуск
```bash
cd questcity-backend/main
docker-compose up -d  # Все сервисы включая backend
```

### Вариант 2: Локальная разработка
```bash
# 1. Установить MinIO локально
brew install minio/stable/minio

# 2. Запустить MinIO
minio server /tmp/minio-data --console-address ":9001"

# 3. Запустить Backend
poetry run python3 main.py
```

### Вариант 3: Mock S3 для разработки
Временно отключить S3 функциональность для быстрого старта.

## 🔧 Приоритетные исправления

### 1. Health Checker (критично)
Заменить multiprocessing на threading в health_check.py:
```python
# Вместо multiprocessing использовать asyncio tasks
```

### 2. S3 Health Check (средне)
Добавить проверку доступности S3 перед регистрацией health check.

### 3. JWT ключи (автоматически)
Создаются при первом запуске через ensure_jwt_keys_exist().

## 🚀 Рекомендуемая последовательность

1. **Установить Docker Desktop**
2. **Запустить MinIO**: `docker-compose up -d minio`
3. **Настроить MinIO bucket** через веб-интерфейс
4. **Исправить Health Checker** (заменить multiprocessing)
5. **Запустить Backend**: `poetry run python3 main.py`
6. **Протестировать подключение**: `curl http://localhost:8000/api/v1/health`

## 💡 Быстрый старт (минимум)

Если нужно запустить немедленно:
1. Отключить S3 health check ✅ (уже сделано)
2. Исправить multiprocessing в Health Checker
3. Запустить только с PostgreSQL

## 📊 Оценка времени

- **Установка Docker:** 10-15 минут
- **Настройка MinIO:** 5 минут  
- **Исправление Health Checker:** 15 минут
- **Первый запуск Backend:** 2-3 минуты
- **Общее время:** ~30-40 минут

---

**Статус анализа:** Завершен  
**Следующий шаг:** Установка Docker и запуск MinIO  
**Дата:** 28 января 2025 