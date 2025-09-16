"""
Обработчики исключений для FastAPI приложения.

Этот модуль содержит централизованные обработчики исключений,
которые конвертируют внутренние исключения в HTTP ответы.
"""

from typing import Dict, Type, Callable
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

from src.api.exceptions import (
    BaseHTTPError, FileTooLargeHTTPError, InvalidFileTypeHTTPError,
    SuspiciousFileContentHTTPError, VirusDetectedHTTPError, EmptyFileHTTPError,
    CorruptedFileHTTPError, ZipBombHTTPError, UnsafeFilenameHTTPError,
    FileValidationHTTPError
)
from src.logger import logger


async def http_exception_handler(
    request: Request,  # noqa: ARG001
    exc: BaseHTTPError,
) -> JSONResponse:
    """Основной обработчик HTTP исключений."""
    return JSONResponse(
        content=jsonable_encoder(exc.error_schema.model_dump(by_alias=True)),
        status_code=exc.status_code,
    )


class FileValidationExceptionMapper:
    """
    Класс для маппинга исключений валидации файлов в HTTP исключения.
    
    Инкапсулирует логику конвертации различных типов исключений
    валидации файлов в соответствующие HTTP ошибки.
    """
    
    def __init__(self):
        """Инициализация маппера исключений."""
        # Импортируем исключения валидации файлов
        from src.core.file_validation.exceptions import (
            FileSizeError, FileTypeError, FileContentError, VirusDetectedError,
            EmptyFileError, CorruptedFileError, ZipBombError, FilenameTooLongError,
            UnsafeFilenameError, FileValidationError
        )
        
        # Создаем маппинг типов исключений к функциям конвертации
        self._exception_mapping: Dict[Type[Exception], Callable] = {
            FileSizeError: self._handle_file_size_error,
            FileTypeError: self._handle_file_type_error,
            FileContentError: self._handle_file_content_error,
            VirusDetectedError: self._handle_virus_detected_error,
            EmptyFileError: self._handle_empty_file_error,
            CorruptedFileError: self._handle_corrupted_file_error,
            ZipBombError: self._handle_zip_bomb_error,
            FilenameTooLongError: self._handle_unsafe_filename_error,
            UnsafeFilenameError: self._handle_unsafe_filename_error,
            FileValidationError: self._handle_generic_validation_error,
        }
    
    def map_exception(self, exc: Exception) -> BaseHTTPError:
        """
        Конвертирует исключение валидации файла в HTTP исключение.
        
        Args:
            exc: Исключение валидации файла
            
        Returns:
            Соответствующее HTTP исключение
        """
        # Ищем подходящий обработчик
        for exc_type, handler in self._exception_mapping.items():
            if isinstance(exc, exc_type):
                return handler(exc)
        
        # Если тип исключения не найден, используем общий обработчик
        return self._handle_unknown_error(exc)
    
    def _handle_file_size_error(self, exc) -> BaseHTTPError:
        """Обработка ошибки размера файла."""
        return FileTooLargeHTTPError(exc.actual_size, exc.max_size)
    
    def _handle_file_type_error(self, exc) -> BaseHTTPError:
        """Обработка ошибки типа файла."""
        return InvalidFileTypeHTTPError(exc.actual_type, exc.allowed_types)
    
    def _handle_file_content_error(self, exc) -> BaseHTTPError:
        """Обработка ошибки содержимого файла."""
        return SuspiciousFileContentHTTPError(exc.reason)
    
    def _handle_virus_detected_error(self, exc) -> BaseHTTPError:
        """Обработка обнаружения вируса."""
        return VirusDetectedHTTPError(exc.virus_name)
    
    def _handle_empty_file_error(self, exc) -> BaseHTTPError:
        """Обработка пустого файла."""
        return EmptyFileHTTPError()
    
    def _handle_corrupted_file_error(self, exc) -> BaseHTTPError:
        """Обработка поврежденного файла."""
        return CorruptedFileHTTPError(exc.message)
    
    def _handle_zip_bomb_error(self, exc) -> BaseHTTPError:
        """Обработка zip-бомбы."""
        return ZipBombHTTPError(exc.compression_ratio)
    
    def _handle_unsafe_filename_error(self, exc) -> BaseHTTPError:
        """Обработка небезопасного имени файла."""
        return UnsafeFilenameHTTPError(
            getattr(exc, 'filename', 'unknown'), 
            exc.message
        )
    
    def _handle_generic_validation_error(self, exc) -> BaseHTTPError:
        """Обработка общей ошибки валидации."""
        return FileValidationHTTPError(exc.message, exc.error_code)
    
    def _handle_unknown_error(self, exc) -> BaseHTTPError:
        """Обработка неизвестной ошибки валидации."""
        return FileValidationHTTPError(str(exc))


# Создаем глобальный экземпляр маппера
file_validation_mapper = FileValidationExceptionMapper()


async def file_validation_exception_handler(
    request: Request,
    exc: Exception,
) -> JSONResponse:
    """
    Обработчик исключений валидации файлов.
    
    Конвертирует исключения валидации файлов в HTTP ответы
    и логирует события безопасности.
    """
    # Конвертируем исключение через маппер
    http_exc = file_validation_mapper.map_exception(exc)
    
    # Логируем событие безопасности
    logger.warning(f"File validation failed: {exc}", extra={
        'event': 'file_validation_failed',
        'exception_type': type(exc).__name__,
        'error_message': str(exc),
        'client_ip': request.client.host if request.client else 'unknown',
        'user_agent': request.headers.get('user-agent', 'unknown'),
    })
    
    return JSONResponse(
        content=jsonable_encoder(http_exc.error_schema.model_dump(by_alias=True)),
        status_code=http_exc.status_code,
    ) 