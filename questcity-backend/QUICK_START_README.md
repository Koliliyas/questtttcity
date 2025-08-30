# 🚀 QuestCity Backend - Быстрый старт

Этот документ описывает как быстро запустить и протестировать QuestCity Backend для работы с квестами.

## 📋 Содержание

- [Быстрый запуск сервера](#быстрый-запуск-сервера)
- [Тестирование API квестов](#тестирование-api-квестов)
- [Основные команды](#основные-команды)
- [Troubleshooting](#troubleshooting)

## 🚀 Быстрый запуск сервера

### Автоматический запуск (рекомендуется)

```bash
# В директории questcity-backend/
./quick_start.sh
```

Этот скрипт автоматически:
- ✅ Проверит и установит зависимости
- ✅ Запустит PostgreSQL (если Docker доступен)
- ✅ Проверит миграции базы данных
- ✅ Запустит FastAPI сервер
- ✅ Покажет доступные endpoints

### Режимы запуска

```bash
# Интерактивный режим (логи в консоли)
./quick_start.sh

# Фоновый режим
./quick_start.sh --bg

# Проверка статуса
./quick_start.sh --status

# Просмотр логов
./quick_start.sh --logs

# Остановка сервера
./quick_start.sh --stop

# Справка
./quick_start.sh --help
```

## 🧪 Тестирование API квестов

### Автоматическое тестирование

```bash
# Полное тестирование всех функций
./test_quests_api.sh

# Быстрая проверка основных функций
./test_quests_api.sh --quick

# Только авторизация
./test_quests_api.sh --auth
```

### Ручное тестирование через curl

```bash
# Получить список квестов
curl -X GET "http://localhost:8000/api/v1/quests/"

# Получить квест по ID
curl -X GET "http://localhost:8000/api/v1/quests/1"

# Проверить здоровье системы
curl -X GET "http://localhost:8000/api/v1/health/"
```

## 📊 Доступные Endpoints

После запуска сервера доступны:

- 📖 **API Documentation**: http://localhost:8000/docs
- 🔍 **ReDoc**: http://localhost:8000/redoc
- ❤️ **Health Check**: http://localhost:8000/api/v1/health/
- 🌐 **API v1**: http://localhost:8000/api/v1/

### Основные endpoints квестов

```
GET    /api/v1/quests/              - Список всех квестов
GET    /api/v1/quests/{id}          - Квест по ID
POST   /api/v1/quests/              - Создание квеста (требует авторизацию)
PUT    /api/v1/quests/{id}          - Обновление квеста (требует авторизацию)
DELETE /api/v1/quests/{id}          - Удаление квеста (требует авторизацию)

GET    /api/v1/categories/          - Категории квестов
GET    /api/v1/activities/          - Активности
GET    /api/v1/places/              - Места
GET    /api/v1/tools/               - Инструменты
GET    /api/v1/vehicles/            - Транспорт
```

## 🔧 Основные команды

### Управление сервером

```bash
# Запуск в интерактивном режиме
./quick_start.sh

# Запуск в фоне
./quick_start.sh --bg

# Проверка статуса
./quick_start.sh --status

# Остановка
./quick_start.sh --stop

# Просмотр логов
./quick_start.sh --logs
```

### Тестирование

```bash
# Полное тестирование
./test_quests_api.sh

# Быстрое тестирование
./test_quests_api.sh --quick

# Только проверка авторизации
./test_quests_api.sh --auth
```

### Ручная работа с базой данных

```bash
# Применить миграции
poetry run alembic upgrade head

# Создать тестового пользователя
python3 create_base_user.py

# Создать администратора
python3 scripts/create_admin.py
```

## 🛠️ Troubleshooting

### Проблема: "ModuleNotFoundError: No module named 'alembic'"

**Решение:**
```bash
cd questcity-backend
poetry install
```

### Проблема: "PostgreSQL connection error"

**Решения:**
1. Запустить Docker: `docker-compose up -d database`
2. Или установить PostgreSQL локально
3. Проверить настройки в `.env` файле

### Проблема: "Port 8000 already in use"

**Решение:**
```bash
# Остановить существующие процессы
./quick_start.sh --stop

# Или найти и убить процесс вручную
lsof -ti:8000 | xargs kill -9
```

### Проблема: "jq: command not found"

**Решение:**
```bash
brew install jq
```

### Проблема: "Poetry not found"

**Решение:**
```bash
# Установить Poetry
curl -sSL https://install.python-poetry.org | python3 -

# Или через Homebrew
brew install poetry
```

## 📝 Логи и диагностика

### Просмотр логов

```bash
# Логи сервера (если запущен в фоне)
./quick_start.sh --logs

# Или напрямую
tail -f server_output.log

# Логи в папке logs/
tail -f logs/server.log
```

### Проверка состояния системы

```bash
# Статус сервера
./quick_start.sh --status

# Проверка API
curl -s http://localhost:8000/api/v1/health/ | jq

# Проверка списка квестов
curl -s http://localhost:8000/api/v1/quests/ | jq
```

## 🎯 Быстрая проверка функционала

После запуска сервера выполните эту последовательность для проверки всех функций:

```bash
# 1. Запустить сервер
./quick_start.sh --bg

# 2. Проверить статус
./quick_start.sh --status

# 3. Быстрое тестирование API
./test_quests_api.sh --quick

# 4. Полное тестирование (включая создание/редактирование)
./test_quests_api.sh

# 5. Просмотр логов при необходимости
./quick_start.sh --logs
```

## 🔗 Полезные ссылки

- [API Documentation (Swagger)](http://localhost:8000/docs)
- [ReDoc Documentation](http://localhost:8000/redoc)
- [Health Check](http://localhost:8000/api/v1/health/)

---

**💡 Совет**: Сохраните этот файл в закладки для быстрого доступа к командам! 