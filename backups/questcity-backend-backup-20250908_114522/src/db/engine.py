import logging
from sqlalchemy.ext.asyncio import (AsyncEngine, async_sessionmaker,
                                    create_async_engine)

from settings import DatabaseSettings, get_settings

logger = logging.getLogger(__name__)

settings: DatabaseSettings = get_settings(DatabaseSettings)

# Создаем engine с улучшенными настройками для production
engine: AsyncEngine = create_async_engine(
    url=settings.url,
    echo=False,  # Отключаем в production для производительности
    # Connection pooling для лучшей производительности (автоматический выбор pool для async)
    # poolclass не указываем - SQLAlchemy автоматически использует правильный AsyncAdaptedQueuePool
    pool_size=20,              # Количество соединений в пуле
    max_overflow=30,           # Дополнительные соединения при нагрузке
    pool_timeout=30,           # Timeout получения соединения из пула
    pool_recycle=3600,         # Пересоздание соединений каждый час
    pool_pre_ping=True,        # Проверка соединений перед использованием
    # Retry и timeout настройки
    connect_args={
        "command_timeout": 60,  # SQL command timeout
        "server_settings": {
            "application_name": "questcity_backend",
        },
    }
)

async_session_factory = async_sessionmaker(
    bind=engine,
    expire_on_commit=False  # Не истекать объекты после commit
)

logger.info("Database engine инициализирован с connection pooling")
