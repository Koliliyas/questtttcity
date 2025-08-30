"""
Базовые классы для репозиториев работы с файлами.

Этот модуль содержит абстрактные базовые классы для унификации работы с файлами
в различных хранилищах (S3, локальная файловая система, другие облачные провайдеры).
"""

import base64
import mimetypes
import uuid
from abc import ABC, abstractmethod
from datetime import datetime
from io import BytesIO
from pathlib import Path
from typing import Optional, Tuple
from urllib.parse import urlparse

import magic


class BaseFileRepository(ABC):
    """
    Абстрактный базовый класс для репозиториев работы с файлами.
    
    Определяет стандартный интерфейс для операций с файлами:
    - Загрузка файлов с валидацией
    - Удаление файлов
    - Безопасная обработка файлов
    - Логирование операций
    """
    
    @abstractmethod
    async def upload_file(
        self,
        release: str,
        file_data: str,
        context: str = "default",
        filename: str = None,
    ) -> str:
        """
        Загрузка файла в хранилище.
        
        Args:
            release: Папка/версия для загрузки файла
            file_data: Base64 строка или data URL
            context: Контекст валидации ('avatar', 'quest', 'strict', 'dev')
            filename: Оригинальное имя файла для дополнительной валидации
            
        Returns:
            URL загруженного файла
            
        Raises:
            FileValidationError: При обнаружении проблем с файлом
        """
        pass
        
    @abstractmethod
    async def delete_file(self, path: str) -> None:
        """
        Удаление файла из хранилища.
        
        Args:
            path: Полный URL или путь к файлу
        """
        pass
    
    def _decode_file_data(self, file_data: str) -> bytes:
        """
        Декодирование файловых данных из base64 или data URL.
        
        Args:
            file_data: Base64 строка или data URL
            
        Returns:
            Бинарные данные файла
        """
        if file_data.startswith("data:"):
            _, encoded = file_data.split(",", 1)
            return base64.b64decode(encoded)
        else:
            return base64.b64decode(file_data)
    
    def _detect_mime_type(self, content: bytes) -> str:
        """
        Определение MIME типа файла по его содержимому.
        
        Args:
            content: Бинарные данные файла
            
        Returns:
            MIME тип файла
        """
        return magic.Magic(mime=True).from_buffer(content)
    
    def _get_file_category(self, mime_type: str) -> str:
        """
        Определение категории файла для организации в хранилище.
        
        Args:
            mime_type: MIME тип файла
            
        Returns:
            Название категории для группировки файлов
        """
        if mime_type.startswith('image/'):
            return 'images'
        elif mime_type.startswith('video/'):
            return 'videos'
        elif mime_type.startswith('audio/'):
            return 'audio'
        elif mime_type in [
            'application/vnd.ms-excel', 
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        ]:
            return 'excels'
        elif mime_type == 'application/pdf':
            return 'documents'
        elif mime_type.startswith('application/') or mime_type.startswith('text/'):
            return 'documents'
        else:
            return 'files'
    
    def _generate_safe_filename(self, mime_type: str, original_filename: Optional[str] = None) -> str:
        """
        Генерация безопасного имени файла.
        
        Args:
            mime_type: MIME тип файла
            original_filename: Оригинальное имя файла (опционально)
            
        Returns:
            Безопасное уникальное имя файла
        """
        extension = mimetypes.guess_extension(mime_type) or ""
        return f"{uuid.uuid4()}{extension}"
    
    def _extract_key_from_url(self, url: str, bucket_name: Optional[str] = None) -> str:
        """
        Извлечение ключа файла из полного URL.
        
        Args:
            url: Полный URL файла
            bucket_name: Имя bucket (опционально, для валидации)
            
        Returns:
            Ключ файла в хранилище
        """
        url_path = urlparse(url).path
        path_parts = url_path.split("/")
        
        # Предполагаем формат: /bucket_name/folder/file
        # Возвращаем folder/file
        if len(path_parts) >= 3:
            return "/".join(path_parts[3:])
        else:
            return "/".join(path_parts[1:])
    
    def _log_security_event(self, event: str, **kwargs) -> None:
        """
        Логирование событий безопасности.
        
        Args:
            event: Тип события
            **kwargs: Дополнительные данные для лога
        """
        import logging
        
        security_logger = logging.getLogger('security.file_upload')
        
        log_data = {
            'event': event,
            'timestamp': self._get_current_timestamp(),
            **kwargs
        }
        
        if event.endswith('_blocked') or 'error' in event.lower():
            security_logger.warning(f"Security event: {event}", extra=log_data)
        else:
            security_logger.info(f"File upload event: {event}", extra=log_data)
    
    def _get_current_timestamp(self) -> str:
        """
        Получение текущего времени в ISO формате.
        
        Returns:
            Временная метка в формате ISO
        """
        return datetime.utcnow().isoformat() + 'Z'
    
    def _validate_file_with_fallback(
        self, 
        file_data: str, 
        context: str = "default", 
        filename: str = None
    ) -> Tuple[bytes, str, dict]:
        """
        Валидация файла с fallback на базовую проверку.
        
        Args:
            file_data: Base64 данные файла
            context: Контекст валидации
            filename: Оригинальное имя файла
            
        Returns:
            Tuple с (content, mime_type, metadata)
        """
        try:
            # Попытка использовать продвинутую валидацию
            from core.file_validation.validators import validate_file
            return validate_file(
                file_data=file_data,
                context=context,
                filename=filename
            )
        except ImportError:
            # Fallback на базовую валидацию
            content = self._decode_file_data(file_data)
            mime_type = self._detect_mime_type(content)
            
            # Базовая проверка размера (максимум 50MB)
            if len(content) > 50 * 1024 * 1024:
                raise ValueError("Файл слишком большой (максимум 50MB)")
                
            # Базовая проверка типа файла
            allowed_types = [
                'image/jpeg', 'image/png', 'image/gif', 'image/webp',
                'application/pdf', 'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'application/vnd.ms-excel',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            ]
            
            if context == "strict" and mime_type not in allowed_types:
                raise ValueError(f"Тип файла не разрешен: {mime_type}")
                
            return content, mime_type, {
                'validated_at': self._get_current_timestamp(),
                'validation_type': 'basic'
            }


class S3BaseRepository(BaseFileRepository):
    """
    Базовый класс для S3-совместимых хранилищ.
    
    Реализует общую логику работы с S3 API.
    """
    
    def __init__(self, client, settings):
        """
        Инициализация репозитория.
        
        Args:
            client: S3-совместимый клиент
            settings: Настройки подключения к S3
        """
        self._client = client
        self._settings = settings
    
    async def upload_file(
        self,
        release: str,
        file_data: str,
        context: str = "default",
        filename: str = None,
    ) -> str:
        """
        Загрузка файла в S3-совместимое хранилище с валидацией.
        """
        # Валидация файла
        try:
            content, mimetype, metadata = self._validate_file_with_fallback(
                file_data=file_data,
                context=context,
                filename=filename
            )
        except Exception as e:
            # Логируем попытку загрузки некорректного файла
            self._log_security_event(
                event="unsafe_file_upload_blocked",
                context=context,
                error=str(e),
                original_filename=filename,
                file_size=len(file_data) if file_data else 0
            )
            raise
        
        # Организация в папки по типу
        file_category = self._get_file_category(mimetype)
        safe_filename = self._generate_safe_filename(mimetype, filename)
        
        blob_s3_key = str(Path(file_category, release, safe_filename))

        # Загрузка в S3
        await self._client.upload_fileobj(
            Fileobj=BytesIO(content),
            Bucket=self._settings.bucket_name,
            Key=blob_s3_key,
            ExtraArgs={
                'ContentType': mimetype,
                'Metadata': {
                    'original_name': filename or 'unknown',
                    'validated': 'true',
                    'validation_context': context,
                    'file_hash': metadata.get('hash_sha256', ''),
                    'upload_time': metadata.get('validated_at', ''),
                }
            }
        )

        # Логирование успешной загрузки
        self._log_security_event(
            event="file_uploaded_successfully", 
            context=context,
            s3_key=blob_s3_key,
            mime_type=mimetype,
            file_size=len(content),
            original_filename=filename
        )

        return f"{self._settings.browser_url}/{self._settings.bucket_name}/{blob_s3_key}"
    
    async def delete_file(self, path: str) -> None:
        """
        Удаление файла из S3-совместимого хранилища.
        """
        file_key = self._extract_key_from_url(path, self._settings.bucket_name)
        
        await self._client.delete_object(
            Bucket=self._settings.bucket_name,
            Key=file_key,
        )
        
        # Логирование удаления
        self._log_security_event(
            event="file_deleted",
            s3_key=file_key,
            original_url=path
        ) 