# QuestCity - Соединение Frontend ↔ Backend

Данный документ описывает настройку соединения между фронтендом и бекендом для локальной разработки.

## 🔗 Текущее состояние

✅ **Соединение настроено** для локальной разработки

## 📡 Конфигурация API

### Backend (Python/FastAPI)
- **URL:** `http://localhost:8000`
- **API Base:** `http://localhost:8000/api/v1/`
- **Документация:** `http://localhost:8000/api/docs`
- **Health Check:** `http://localhost:8000/api/v1/health`

### Frontend (Flutter/Dart)  
- **Development URL:** `http://localhost:8000/api/v1/`
- **WebSocket URL:** `ws://localhost:8000/api/v1/`
- **Production URL:** `https://questicity.com/api/v1.0/`

## 🗂 Структура файлов конфигурации

```
questcity-frontend/
├── .env                    # Текущая конфигурация (development)
├── .env.development        # Локальная разработка
└── .env.production         # Production сервер
```

## 🚀 Быстрый запуск

### Автоматический запуск (рекомендуется)
```bash
./start_system.sh
```

### Ручной запуск

#### 1. Запуск Backend
```bash
cd questcity-backend/main
poetry install
poetry run python3 main.py
```

#### 2. Настройка Frontend environment
```bash
cd questcity-frontend
cp .env.development .env
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 3. Запуск Frontend
```bash
cd questcity-frontend
flutter run
```

## 🔧 Переключение между окружениями

### Development (локальная разработка)
```bash
cd questcity-frontend
cp .env.development .env
```

### Production
```bash
cd questcity-frontend  
cp .env.production .env
```

## 🔌 Доступные API Endpoints

### Authentication (`/api/v1/auth/`)
- `POST /auth/login` - Вход в систему
- `POST /auth/register` - Регистрация
- `POST /auth/refresh-token` - Обновление токена
- `POST /auth/reset-password` - Сброс пароля

### Users (`/api/v1/users/`)
- `GET /users/me` - Профиль пользователя
- `PATCH /users/me` - Обновление профиля
- `GET /users` - Список пользователей

### Quests (`/api/v1/quests/`)
- `GET /quests` - Список квестов
- `POST /quests` - Создание квеста
- `GET /quests/{id}` - Получение квеста
- `GET /quests/categories` - Категории квестов

### Chats (`/api/v1/chats/`)
- `GET /chats/get_chats` - Список чатов
- `GET /chats/get_messages` - Сообщения чата
- `WS /chats/{chat_id}` - WebSocket соединение

### Health Check (`/api/v1/health/`)
- `GET /health` - Статус системы
- `GET /health/detailed` - Детальная диагностика

## 🧪 Проверка соединения

### Backend доступность
```bash
curl http://localhost:8000/api/v1/health
```

### Frontend настройки
Проверить в файле `questcity-frontend/lib/core/network/api_client.dart`:
```dart
_baseUrl = dotenv.env['BASE_URL'] ?? 'https://questicity.com/api/v1.0/';
```

## 🐛 Устранение проблем

### Проблема: Frontend не может подключиться к Backend
**Решение:**
1. Проверить что Backend запущен: `curl http://localhost:8000/api/v1/health`
2. Проверить .env файл фронтенда: `cat questcity-frontend/.env`
3. Перезапустить Flutter: `flutter hot reload`

### Проблема: CORS ошибки
**Решение:**
Backend настроен на `allow_origins=["*"]` для development.

### Проблема: WebSocket соединение не работает
**Решение:**
1. Проверить WS_BASE_URL в .env
2. Убедиться что используется `ws://` а не `wss://` для localhost

### Проблема: 404 на API endpoints
**Решение:**
1. Проверить версию API в URL (`/api/v1/`)
2. Проверить swagger документацию: `http://localhost:8000/api/docs`

## 📱 Особенности Flutter

### Environment Variables
Flutter использует `flutter_dotenv` для загрузки .env файлов:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load(fileName: ".env");
String apiUrl = dotenv.env['BASE_URL']!;
```

### HTTP Client
Используется централизованный ApiClient:
```dart
// GET запрос
final response = await ApiClient().get<UserModel>(
  'users/me',
  fromJson: (json) => UserModel.fromJson(json),
);

// POST запрос  
final response = await ApiClient().post<TokenModel>(
  'auth/login',
  body: {'email': email, 'password': password},
  fromJson: (json) => TokenModel.fromJson(json),
);
```

## 💡 Лучшие практики

1. **Всегда используйте .env файлы** для конфигурации
2. **Не коммитьте актуальные .env файлы** в Git
3. **Используйте .env.example** как шаблон
4. **Проверяйте health endpoints** перед началом работы
5. **Логируйте сетевые запросы** в development режиме

## 🔄 Обновление конфигурации

При изменении backend API endpoints:
1. Обновить роутеры в backend
2. Проверить Swagger документацию
3. Обновить frontend data sources если нужно
4. Протестировать все endpoints

---

**Автор:** QuestCity Development Team  
**Дата обновления:** 28 января 2025  
**Версия:** 1.0 