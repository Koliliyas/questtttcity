"""
Валидаторы для проверки безопасности файлов.
"""
import base64
import hashlib
import io
import mimetypes
import os
import re
import tempfile
import zipfile
from pathlib import Path
from typing import Tuple, Dict, Any, Optional
from urllib.parse import urlparse

import magic

from .config import FileValidationConfig, get_config_for_context
from .exceptions import (
    FileSizeError, FileTypeError, FileContentError, VirusDetectedError,
    EmptyFileError, CorruptedFileError, ZipBombError, FilenameTooLongError,
    UnsafeFilenameError, FileValidationError
)


class FileValidator:
    """
    Основной класс для валидации файлов.
    
    Выполняет комплексную проверку безопасности файлов:
    - Размер файла
    - Тип файла (MIME type)
    - Содержимое файла
    - Проверка на вирусы (опционально)
    - Проверка на ZIP bombs
    - Валидация имени файла
    """
    
    def __init__(self, config: Optional[FileValidationConfig] = None):
        self.config = config or FileValidationConfig()
        self._magic = magic.Magic(mime=True)
    
    def validate_file_data(
        self,
        file_data: str,
        filename: str = None,
        context: str = "default"
    ) -> Tuple[bytes, str, Dict[str, Any]]:
        """
        Валидация файла из base64 строки или data URL.
        
        Args:
            file_data: Base64 строка или data URL
            filename: Оригинальное имя файла (опционально)
            context: Контекст использования для выбора конфигурации
            
        Returns:
            Tuple[содержимое_файла, mime_type, метаданные]
            
        Raises:
            FileValidationError: При обнаружении проблем с файлом
        """
        # Используем контекстную конфигурацию если указана
        if context != "default":
            config = get_config_for_context(context)
        else:
            config = self.config
        
        # Декодируем файл
        content, original_mime = self._decode_file_data(file_data)
        
        # Базовые проверки
        self._validate_file_size(content, config)
        self._validate_not_empty(content)
        
        # Определяем реальный MIME type
        detected_mime = self._detect_mime_type(content)
        
        # Проверяем тип файла
        self._validate_file_type(detected_mime, config)
        
        # Проверяем имя файла если предоставлено
        if filename:
            self._validate_filename(filename, config)
        
        # Проверяем содержимое файла
        if config.enable_content_validation:
            self._validate_file_content(content, detected_mime, config)
        
        # Проверяем на ZIP bomb если это архив
        if detected_mime in ['application/zip', 'application/x-zip-compressed']:
            self._validate_zip_bomb(content, config)
        
        # Антивирусное сканирование (опционально)
        if config.enable_virus_scan:
            self._scan_for_viruses(content, config)
        
        # Собираем метаданные
        metadata = {
            'size': len(content),
            'mime_type': detected_mime,
            'original_mime': original_mime,
            'hash_sha256': hashlib.sha256(content).hexdigest(),
            'safe': True,
            'validated_at': self._get_current_timestamp()
        }
        
        return content, detected_mime, metadata
    
    def _decode_file_data(self, file_data: str) -> Tuple[bytes, Optional[str]]:
        """Декодирование base64 данных или data URL."""
        original_mime = None
        
        if file_data.startswith("data:"):
            # Парсим data URL
            try:
                header, encoded = file_data.split(",", 1)
                mime_match = re.match(r"data:([^;]+)", header)
                if mime_match:
                    original_mime = mime_match.group(1)
                content = base64.b64decode(encoded)
            except Exception as e:
                raise CorruptedFileError(f"Невозможно декодировать data URL: {e}")
        else:
            # Обычный base64
            try:
                content = base64.b64decode(file_data)
            except Exception as e:
                raise CorruptedFileError(f"Невозможно декодировать base64: {e}")
        
        return content, original_mime
    
    def _detect_mime_type(self, content: bytes) -> str:
        """Определение MIME типа по содержимому файла."""
        try:
            return self._magic.from_buffer(content)
        except Exception as e:
            raise CorruptedFileError(f"Невозможно определить тип файла: {e}")
    
    def _validate_file_size(self, content: bytes, config: FileValidationConfig):
        """Проверка размера файла."""
        size = len(content)
        
        if size > config.max_file_size:
            raise FileSizeError(size, config.max_file_size)
    
    def _validate_not_empty(self, content: bytes):
        """Проверка что файл не пустой."""
        if len(content) == 0:
            raise EmptyFileError()
    
    def _validate_file_type(self, mime_type: str, config: FileValidationConfig):
        """Проверка допустимости типа файла."""
        # Собираем все разрешенные типы
        allowed_types = set()
        allowed_types.update(config.allowed_image_types)
        allowed_types.update(config.allowed_document_types)
        allowed_types.update(config.allowed_video_types)
        allowed_types.update(config.allowed_audio_types)
        
        if mime_type not in allowed_types:
            raise FileTypeError(mime_type, list(allowed_types))
    
    def _validate_filename(self, filename: str, config: FileValidationConfig):
        """Проверка безопасности имени файла."""
        if len(filename) > config.max_filename_length:
            raise FilenameTooLongError(len(filename), config.max_filename_length)
        
        # Проверяем на небезопасные символы
        unsafe_chars = ['..', '/', '\\', '<', '>', ':', '"', '|', '?', '*']
        for char in unsafe_chars:
            if char in filename:
                raise UnsafeFilenameError(filename, f"Содержит небезопасный символ: {char}")
        
        # Проверяем расширение
        file_ext = Path(filename).suffix.lower()
        if file_ext in config.forbidden_extensions:
            raise UnsafeFilenameError(filename, f"Запрещенное расширение: {file_ext}")
    
    def _validate_file_content(self, content: bytes, mime_type: str, config: FileValidationConfig):
        """Проверка содержимого файла на подозрительные элементы."""
        # Проверяем заголовки файлов
        if config.check_file_headers:
            self._validate_file_headers(content, mime_type)
        
        # Проверяем на подозрительные строки
        self._check_for_suspicious_content(content)
    
    def _validate_file_headers(self, content: bytes, mime_type: str):
        """Проверка соответствия заголовков файла заявленному типу."""
        # Сигнатуры файлов (magic numbers)
        file_signatures = {
            'image/jpeg': [b'\xFF\xD8\xFF'],
            'image/png': [b'\x89PNG\r\n\x1a\n'],
            'image/gif': [b'GIF87a', b'GIF89a'],
            'application/pdf': [b'%PDF-'],
            'application/zip': [b'PK\x03\x04', b'PK\x05\x06', b'PK\x07\x08'],
            'image/bmp': [b'BM'],
            'image/tiff': [b'II*\x00', b'MM\x00*'],
        }
        
        expected_signatures = file_signatures.get(mime_type, [])
        if expected_signatures:
            # Проверяем что файл начинается с ожидаемой сигнатуры
            if not any(content.startswith(sig) for sig in expected_signatures):
                raise FileContentError(f"Заголовок файла не соответствует типу {mime_type}")
    
    def _check_for_suspicious_content(self, content: bytes):
        """Проверка на подозрительное содержимое."""
        # Конвертируем в строку для поиска (только первые 1024 байта)
        try:
            text_content = content[:1024].decode('utf-8', errors='ignore').lower()
        except:
            return  # Не текстовый файл, пропускаем
        
        # Подозрительные строки
        suspicious_patterns = [
            # Скрипты
            '<script', 'javascript:', 'vbscript:',
            # Исполняемый код
            'eval(', 'exec(', 'system(',
            # PHP код
            '<?php', '<?=',
            # SQL инъекции
            'union select', 'drop table',
            # Системные команды
            'cmd.exe', 'powershell',
        ]
        
        for pattern in suspicious_patterns:
            if pattern in text_content:
                raise FileContentError(f"Обнаружен подозрительный код: {pattern}")
    
    def _validate_zip_bomb(self, content: bytes, config: FileValidationConfig):
        """Проверка на ZIP bomb."""
        try:
            with zipfile.ZipFile(io.BytesIO(content), 'r') as zip_file:
                total_size = 0
                for info in zip_file.infolist():
                    total_size += info.file_size
                    # Проверяем коэффициент сжатия для каждого файла
                    if info.compress_size > 0:
                        ratio = info.file_size / info.compress_size
                        if ratio > config.max_compression_ratio:
                            raise ZipBombError(ratio)
                
                # Проверяем общий размер после распаковки
                if total_size > config.max_extracted_size:
                    raise ZipBombError(total_size / len(content))
                    
        except zipfile.BadZipFile:
            raise CorruptedFileError("Поврежденный ZIP архив")
        except ZipBombError:
            raise  # Перебрасываем наше исключение
        except Exception as e:
            raise FileContentError(f"Ошибка при проверке ZIP архива: {e}")
    
    def _scan_for_viruses(self, content: bytes, config: FileValidationConfig):
        """
        Антивирусное сканирование.
        
        В реальной реализации здесь должна быть интеграция с антивирусом
        (например, ClamAV). Для демонстрации проверяем простые сигнатуры.
        """
        # Простые сигнатуры вирусов (для демонстрации)
        virus_signatures = {
            b'X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR': 'EICAR-Test-File',
            b'EICAR-STANDARD-ANTIVIRUS-TEST-FILE': 'EICAR-Test-File',
        }
        
        for signature, virus_name in virus_signatures.items():
            if signature in content:
                raise VirusDetectedError(virus_name)
        
        # TODO: Интеграция с реальным антивирусом
        # Например: clamd, Windows Defender API, VirusTotal API
    
    def _get_current_timestamp(self) -> str:
        """Получение текущего времени в ISO формате."""
        from datetime import datetime
        return datetime.utcnow().isoformat() + 'Z'


class ImageValidator(FileValidator):
    """Специализированный валидатор для изображений."""
    
    def __init__(self, config: Optional[FileValidationConfig] = None):
        super().__init__(config)
    
    def validate_image(
        self,
        file_data: str,
        max_width: int = None,
        max_height: int = None,
        filename: str = None
    ) -> Tuple[bytes, str, Dict[str, Any]]:
        """
        Валидация изображения с дополнительными проверками.
        
        Args:
            file_data: Base64 строка или data URL
            max_width: Максимальная ширина в пикселях
            max_height: Максимальная высота в пикселях
            filename: Оригинальное имя файла
            
        Returns:
            Tuple[содержимое_файла, mime_type, метаданные]
        """
        content, mime_type, metadata = self.validate_file_data(file_data, filename, 'avatar')
        
        # Дополнительные проверки для изображений
        if max_width or max_height:
            self._validate_image_dimensions(content, max_width, max_height)
        
        # Добавляем информацию об изображении в метаданные
        try:
            from PIL import Image
            image = Image.open(io.BytesIO(content))
            metadata.update({
                'width': image.width,
                'height': image.height,
                'format': image.format,
                'mode': image.mode
            })
        except ImportError:
            # PIL не установлен, пропускаем расширенную валидацию
            pass
        except Exception as e:
            raise CorruptedFileError(f"Невозможно обработать изображение: {e}")
        
        return content, mime_type, metadata
    
    def _validate_image_dimensions(self, content: bytes, max_width: int, max_height: int):
        """Проверка размеров изображения."""
        try:
            from PIL import Image
            image = Image.open(io.BytesIO(content))
            
            if max_width and image.width > max_width:
                raise FileContentError(f"Ширина изображения {image.width}px превышает лимит {max_width}px")
            
            if max_height and image.height > max_height:
                raise FileContentError(f"Высота изображения {image.height}px превышает лимит {max_height}px")
                
        except ImportError:
            # PIL не установлен, пропускаем проверку размеров
            pass
        except FileContentError:
            raise  # Перебрасываем наше исключение
        except Exception as e:
            raise CorruptedFileError(f"Невозможно проверить размеры изображения: {e}")


def validate_file(
    file_data: str,
    context: str = "default",
    filename: Optional[str] = None,
    config: Optional[FileValidationConfig] = None
) -> Tuple[bytes, str, Dict[str, Any]]:
    """
    Удобная функция для валидации файлов.
    
    Args:
        file_data: Base64 строка или data URL
        context: Контекст использования ('avatar', 'quest', 'strict', 'dev')
        filename: Оригинальное имя файла
        config: Кастомная конфигурация валидации
        
    Returns:
        Tuple[содержимое_файла, mime_type, метаданные]
    """
    validator = FileValidator(config)
    return validator.validate_file_data(file_data, filename, context)


def validate_image(
    file_data: str,
    max_width: Optional[int] = None,
    max_height: Optional[int] = None,
    filename: Optional[str] = None,
    config: Optional[FileValidationConfig] = None
) -> Tuple[bytes, str, Dict[str, Any]]:
    """
    Удобная функция для валидации изображений.
    
    Args:
        file_data: Base64 строка или data URL
        max_width: Максимальная ширина в пикселях
        max_height: Максимальная высота в пикселях
        filename: Оригинальное имя файла
        config: Кастомная конфигурация валидации
        
    Returns:
        Tuple[содержимое_файла, mime_type, метаданные]
    """
    validator = ImageValidator(config)
    return validator.validate_image(file_data, max_width, max_height, filename) 