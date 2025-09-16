import aioinject
import os

from src.core.di._types import Providers
from src.core.repositories import S3Repository, create_s3_client
from src.core.services import EmailSenderService
from src.core.base.repositories import BaseFileRepository

# Создаем мок-репозиторий для S3
class MockS3Repository(BaseFileRepository):
    """Мок-репозиторий для S3, который возвращает пустые значения"""
    
    async def upload_file(
        self,
        release: str,
        file_data: str,
        context: str = "default",
        filename: str = None,
    ) -> str:
        """Мок-загрузка файла - возвращает пустой URL"""
        return f"mock://localhost/mock/{release}/{filename or 'mock_file'}"
    
    async def delete_file(self, path: str) -> None:
        """Мок-удаление файла - всегда успешно"""
        pass

# Функция для создания S3 репозитория
def create_s3_repository() -> S3Repository | MockS3Repository:
    """Создает S3 репозиторий в зависимости от окружения"""
    if os.getenv("ENVIRONMENT", "development") == "production":
        # В продакшене используем реальный S3
        client = create_s3_client()
        from src.settings import get_settings, S3Settings
        settings = get_settings(S3Settings)
        return S3Repository(client, settings)
    else:
        # В разработке используем мок
        return MockS3Repository()

PROVIDERS: Providers = [
    aioinject.Scoped(EmailSenderService),
    aioinject.Scoped(MockS3Repository),  # Регистрируем мок как провайдер для S3Repository
    # Алиас для S3Repository -> MockS3Repository
    aioinject.Scoped(MockS3Repository, type_=S3Repository),
]
