# 🚀 QuestCity - Команды для работы с API квестов

Быстрый справочник команд для запуска и тестирования QuestCity Backend.

## 📁 Структура проекта

```
Questcity/
├── questcity-backend/     # Backend API на Python/FastAPI
├── questcity-frontend/    # Frontend на Flutter
└── QUEST_API_COMMANDS.md  # ← Этот файл
```

## 🎯 Основные команды

### 🔄 Перезапуск системы (остановка + запуск)

```bash
cd questcity-backend && ./quick_start.sh --stop && ./quick_start.sh --bg
```

**Что делает:**
- ✅ Останавливает сервер
- ✅ Очищает токен авторизации  
- ✅ Запускает сервер заново в фоне
- ✅ Создает/проверяет админа
- ✅ Получает новый токен авторизации

---

### 🚀 Запуск системы с нуля

```bash
cd questcity-backend && ./quick_start.sh --bg
```

**Что включает:**
- 📦 Установка зависимостей через Poetry
- 🐳 Запуск PostgreSQL через Docker
- 🔧 Проверка миграций БД
- 👤 Создание администратора (admin@questcity.com)
- 🔐 Автоматическая авторизация
- 🌐 Запуск FastAPI сервера

---

### 🧪 Тестирование API квестов

```bash
cd questcity-backend && ./test_quests_api.sh
```

**Проверяет:**
- ✅ Получение списка квестов (100,000+ в базе)
- ✅ Получение квеста по ID
- ✅ Получение категорий
- ✅ Создание нового квеста
- ✅ Обновление квеста
- ✅ Удаление квеста

---

### 🔐 Тестирование авторизации и регистрации

```bash
cd questcity-backend && ./test_auth_api.sh
```

**Проверяет:**
- ✅ Регистрация новых пользователей
- ✅ Вход в систему (логин)
- ✅ Обновление токенов (refresh)
- ✅ Доступ к защищенным ресурсам
- ✅ Выход из системы (logout)
- ✅ Безопасность (неверные данные)

**Быстрые режимы:**
```bash
# Только проверка входа
./test_auth_api.sh --login

# Быстрая проверка
./test_auth_api.sh --quick
```

---

### 📊 Управление сервером

```bash
cd questcity-backend

# Проверить статус
./quick_start.sh --status

# Просмотр логов
./quick_start.sh --logs

# Остановить сервер
./quick_start.sh --stop

# Справка
./quick_start.sh --help
```

---

### 🔍 Быстрая проверка API

```bash
cd questcity-backend

# Проверить здоровье сервера
curl -s http://localhost:8000/api/v1/health/ | jq

# Получить список квестов (с авторизацией)
curl -s -H "Authorization: Bearer $(cat .admin_token)" \
  "http://localhost:8000/api/v1/quests/" | jq '. | length'

# Получить категории
curl -s -H "Authorization: Bearer $(cat .admin_token)" \
  "http://localhost:8000/api/v1/quests/categories/" | jq '. | length'

# Проверить авторизацию (получить токен)
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -d "login=admin@questcity.com" \
  -d "password=admin123" | jq '.accessToken'
```

---

## 🌐 Доступные endpoints

После запуска сервера доступны:

- **📖 API Documentation**: http://localhost:8000/docs
- **🔍 ReDoc**: http://localhost:8000/redoc  
- **❤️ Health Check**: http://localhost:8000/api/v1/health/
- **🌐 API v1**: http://localhost:8000/api/v1/

### 🎯 Основные API квестов

```
GET    /api/v1/quests/              # Список всех квестов
GET    /api/v1/quests/{id}          # Квест по ID
POST   /api/v1/quests/              # Создание квеста
PUT    /api/v1/quests/{id}          # Обновление квеста
DELETE /api/v1/quests/{id}          # Удаление квеста

GET    /api/v1/quests/categories/   # Категории квестов
GET    /api/v1/quests/places/       # Места для квестов
GET    /api/v1/quests/tools/        # Инструменты
GET    /api/v1/quests/vehicles/     # Транспорт
GET    /api/v1/quests/types/        # Типы активности
```

### 🔐 API авторизации

```
POST   /api/v1/auth/register        # Регистрация пользователя
POST   /api/v1/auth/login           # Вход в систему
POST   /api/v1/auth/logout          # Выход из системы
POST   /api/v1/auth/refresh         # Обновление токена
```

---

## 🔐 Авторизация

### Администратор (автоматически создается)
- **Email**: admin@questcity.com
- **Password**: admin123
- **Токен**: автоматически сохраняется в `.admin_token`

### Ручная авторизация

```bash
# Получить токен
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -d "login=admin@questcity.com" \
  -d "password=admin123"

# Использовать токен
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "http://localhost:8000/api/v1/quests/"
```

---

## 🛠️ Troubleshooting

### Проблема: "Port 8000 already in use"
```bash
cd questcity-backend && ./quick_start.sh --stop
```

### Проблема: "Database connection error" 
```bash
# Запустить Docker PostgreSQL
cd questcity-backend && docker-compose up -d database
```

### Проблема: "No such file or directory"
```bash
# Убедитесь что находитесь в правильной директории
cd questcity-backend
pwd  # Должно показать: .../Questcity/questcity-backend
```

### Проблема: "jq: command not found"
```bash
# На macOS
brew install jq
```

---

## 📈 Статистика системы

После успешного запуска в системе доступно:
- **🎯 Квестов**: 100,000+
- **📂 Категорий**: 5
- **🛠️ Инструментов**: Динамически загружается
- **🚗 Транспорт**: Динамически загружается
- **📍 Места**: Динамически загружается

---

## 🎉 Быстрый старт

**Для нетерпеливых:**

```bash
# 1. Запустить всё
cd questcity-backend && ./quick_start.sh --bg

# 2. Протестировать квесты
./test_quests_api.sh

# 3. Протестировать авторизацию
./test_auth_api.sh --quick

# 4. Открыть документацию
open http://localhost:8000/docs
```

**Готово! 🚀 Система квестов работает!**

---

*💡 Совет: Добавьте этот файл в закладки для быстрого доступа к командам!* 