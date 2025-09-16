# Dockerfile для развертывания QuestCity Backend на Timeweb Cloud
FROM python:3.12-slim

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    libmagic1 \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Настройка рабочей директории
WORKDIR /app

# Копирование файлов зависимостей
COPY deploy/requirements.txt .

# Установка Python зависимостей
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Копирование исходного кода и конфигурации
COPY src/ ./src/
COPY deploy/ ./deploy/
COPY alembic.ini .

# Настройка PYTHONPATH
ENV PYTHONPATH=/app

# Создание пользователя для безопасности
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

# Открытие порта
EXPOSE 8000

# Команда запуска
CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]
