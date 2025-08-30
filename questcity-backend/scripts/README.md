# 🤖 Скрипты автоматизации QuestCity Backend

> **Быстрый старт:** Автоматическое создание resilient сервисов без ручного кодирования

---

## 🚀 Быстрые команды

### 1. Создать новый Repository сервис
```bash
python3 scripts/generate_resilient_service.py --name PaymentService --type repository
```

### 2. Создать новый API Client  
```bash
python3 scripts/generate_resilient_service.py --name StripeAPI --type api
```

### 3. Проверить качество кода
```bash
python3 scripts/validate_resilience.py --path src/core/payment_service
```

---

## 📁 Файлы

| Файл | Назначение | Команда |
|------|------------|---------|
| `generate_resilient_service.py` | Генерация сервисов с resilience | `python3 scripts/generate_resilient_service.py --help` |
| `validate_resilience.py` | Валидация resilience паттернов | `python3 scripts/validate_resilience.py --help` |
| `create_admin.py` | Создание администратора | `python3 scripts/create_admin.py --help` |

---

## ✅ Что получаете автоматически

При генерации ЛЮБОГО сервиса:

- ✅ **Retry механизм** с экспоненциальным backoff
- ✅ **Circuit Breaker** для предотвращения каскадных сбоев  
- ✅ **Health Check** функции и регистрация
- ✅ **Exception классы** для ошибок сервиса
- ✅ **Graceful Degradation** с fallback методами
- ✅ **Structured Logging** для операций и ошибок
- ✅ **Availability Check** перед каждой операцией
- ✅ **Инструкции по интеграции** в `INTEGRATION.md`

**Результат:** 100% resilient сервис за 5 минут!

---

## 📋 Примеры использования

### Платежная система:
```bash
python3 scripts/generate_resilient_service.py --name PaymentProvider --type repository
# Создает: src/core/payment_provider/
```

### Внешний API:
```bash  
python3 scripts/generate_resilient_service.py --name StripeAPI --type api
# Создает: src/core/stripe_api/
```

### Валидация:
```bash
python3 scripts/validate_resilience.py --path src/core/stripe_api
# Результат: Балл качества 0-100%
```

---

## 🎯 Автоматическое применение ИИ

**ИИ автоматически использует эти скрипты** при упоминании новых интеграций благодаря:
- 🧠 Обновленной памяти ИИ
- 📋 AI Development Guidelines  
- 🔄 Автоматическим правилам

**Подробно:** См. `docs/AUTOMATION_SYSTEM.md`

---

*Скрипты автоматически применяются при разработке QuestCity Backend* 