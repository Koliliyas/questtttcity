"""
Исключения для валидации файлов.
"""
from typing import Optional


class FileValidationError(Exception):
    """Базовое исключение для ошибок валидации файлов."""
    
    def __init__(self, message: str, error_code: Optional[str] = None):
        self.message = message
        self.error_code = error_code
        super().__init__(message)


class FileSizeError(FileValidationError):
    """Файл превышает максимальный размер."""
    
    def __init__(self, actual_size: int, max_size: int):
        self.actual_size = actual_size
        self.max_size = max_size
        message = f"Файл слишком большой: {actual_size} байт (максимум {max_size} байт)"
        super().__init__(message, "FILE_TOO_LARGE")


class FileTypeError(FileValidationError):
    """Недопустимый тип файла."""
    
    def __init__(self, actual_type: str, allowed_types: list):
        self.actual_type = actual_type
        self.allowed_types = allowed_types
        message = f"Недопустимый тип файла: {actual_type} (разрешены: {', '.join(allowed_types)})"
        super().__init__(message, "INVALID_FILE_TYPE")


class FileContentError(FileValidationError):
    """Подозрительное содержимое файла."""
    
    def __init__(self, reason: str):
        self.reason = reason
        message = f"Подозрительное содержимое файла: {reason}"
        super().__init__(message, "SUSPICIOUS_CONTENT")


class VirusDetectedError(FileValidationError):
    """Обнаружен вирус в файле."""
    
    def __init__(self, virus_name: str):
        self.virus_name = virus_name
        message = f"Обнаружен вирус: {virus_name}"
        super().__init__(message, "VIRUS_DETECTED")


class EmptyFileError(FileValidationError):
    """Файл пустой."""
    
    def __init__(self):
        message = "Файл пустой"
        super().__init__(message, "EMPTY_FILE")


class CorruptedFileError(FileValidationError):
    """Файл поврежден."""
    
    def __init__(self, reason: str = "Файл поврежден или нечитаем"):
        message = reason
        super().__init__(message, "CORRUPTED_FILE")


class ZipBombError(FileValidationError):
    """Обнаружена ZIP bomb."""
    
    def __init__(self, compression_ratio: float):
        self.compression_ratio = compression_ratio
        message = f"Подозрение на ZIP bomb: коэффициент сжатия {compression_ratio:.2f}"
        super().__init__(message, "ZIP_BOMB")


class FilenameTooLongError(FileValidationError):
    """Имя файла слишком длинное."""
    
    def __init__(self, actual_length: int, max_length: int):
        self.actual_length = actual_length
        self.max_length = max_length
        message = f"Имя файла слишком длинное: {actual_length} символов (максимум {max_length})"
        super().__init__(message, "FILENAME_TOO_LONG")


class UnsafeFilenameError(FileValidationError):
    """Небезопасное имя файла."""
    
    def __init__(self, filename: str, reason: str):
        self.filename = filename
        self.reason = reason
        message = f"Небезопасное имя файла '{filename}': {reason}"
        super().__init__(message, "UNSAFE_FILENAME") 