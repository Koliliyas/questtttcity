# QuestCity Frontend - Настройка окружений

## 📋 Обзор

QuestCity Frontend поддерживает два окружения:
- **Development** - для разработки с локальным бэкендом
- **Production** - для продакшена с облачным сервисом

## 🔧 Конфигурационные файлы

### Development (локальная разработка)
**Файл:** `env.development`
```bash
BASE_URL=http://localhost:8000/api/v1/
WS_BASE_URL=ws://localhost:8000/api/v1/
API_VERSION=v1
ENVIRONMENT=development
```

### Production (облачный сервис)
**Файл:** `env.production`
```bash
BASE_URL=http://questcity.ru/api/v1.0/
WS_BASE_URL=ws://questcity.ru/api/v1.0/
API_VERSION=v1.0
ENVIRONMENT=production
```

## 🚀 Быстрое переключение окружений

### Windows (PowerShell)
```powershell
# Переключение на разработку
.\switch_env.ps1 -Environment development

# Переключение на продакшен
.\switch_env.ps1 -Environment production
```

### Linux/Mac (Bash)
```bash
# Переключение на разработку
./switch_env.sh development

# Переключение на продакшен
./switch_env.sh production
```

## 📱 Сборка APK для продакшена

### Windows
```powershell
.\build_apk.ps1
```

### Linux/Mac
```bash
./build_apk.sh
```

## 🔄 Рабочий процесс

### Для разработки:
1. **Переключитесь на development:**
   ```bash
   ./switch_env.sh development
   ```

2. **Запустите локальный бэкенд:**
   ```bash
   cd ../questcity-backend
   ./start_system.sh
   ```

3. **Запустите фронтенд:**
   ```bash
   flutter run
   ```

### Для сборки APK:
1. **Соберите APK с продакшен конфигурацией:**
   ```bash
   ./build_apk.sh
   ```

2. **APK будет создан в:** `build/app/outputs/flutter-apk/app-release.apk`

3. **Вернитесь к разработке:**
   ```bash
   ./switch_env.sh development
   ```

## 📊 Проверка текущей конфигурации

После переключения окружения скрипт покажет текущую конфигурацию:

```bash
./switch_env.sh development
```

Вывод:
```
🔄 Переключение окружения QuestCity Frontend на: development
✅ Переключено на DEVELOPMENT (localhost:8000)
   📍 API URL: http://localhost:8000/api/v1/

📋 Текущая конфигурация:
   BASE_URL=http://localhost:8000/api/v1/
   WS_BASE_URL=ws://localhost:8000/api/v1/
   API_VERSION=v1
   ENVIRONMENT=development
```

## 🔍 Ручное переключение

Если скрипты не работают, можете переключить вручную:

```bash
# Для разработки
cp env.development .env

# Для продакшена
cp env.production .env
```

## ⚠️ Важные замечания

1. **Всегда перезапускайте Flutter** после смены конфигурации:
   ```bash
   flutter clean && flutter pub get
   ```

2. **Резервные копии** создаются автоматически при переключении

3. **Файл .env** не коммитится в Git (в .gitignore)

4. **Проверяйте API** перед сборкой APK:
   ```bash
   curl http://questcity.ru/api/v1/health/
   ```

## 🐛 Устранение проблем

### Проблема: API не отвечает
**Решение:**
1. Проверьте статус сервера: `curl http://questcity.ru/api/v1/health/`
2. Убедитесь, что конфигурация правильная
3. Перезапустите Flutter

### Проблема: Скрипт не работает
**Решение:**
1. Убедитесь, что файлы `env.development` и `env.production` существуют
2. Проверьте права доступа: `chmod +x switch_env.sh`
3. Переключите вручную: `cp env.development .env`

### Проблема: APK не собирается
**Решение:**
1. Проверьте, что переключились на production
2. Убедитесь, что API доступен
3. Проверьте логи сборки: `flutter build apk --verbose`
































