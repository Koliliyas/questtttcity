"""
Конфигурация для валидации файлов.
"""
from dataclasses import dataclass
from typing import Dict, List, Set


@dataclass
class FileValidationConfig:
    """Конфигурация валидации файлов."""
    
    # Максимальные размеры файлов (в байтах)
    max_file_size: int = 10 * 1024 * 1024  # 10MB по умолчанию
    max_image_size: int = 5 * 1024 * 1024   # 5MB для изображений
    max_document_size: int = 50 * 1024 * 1024  # 50MB для документов
    max_video_size: int = 100 * 1024 * 1024    # 100MB для видео
    
    # Максимальная длина имени файла
    max_filename_length: int = 255
    
    # Разрешенные MIME типы по категориям
    allowed_image_types: Set[str] = None
    allowed_document_types: Set[str] = None
    allowed_video_types: Set[str] = None
    allowed_audio_types: Set[str] = None
    
    # Запрещенные расширения (потенциально опасные)
    forbidden_extensions: Set[str] = None
    
    # Проверка на ZIP bomb
    max_compression_ratio: float = 100.0  # Максимальный коэффициент сжатия
    max_extracted_size: int = 100 * 1024 * 1024  # 100MB после распаковки
    
    # Антивирусное сканирование
    enable_virus_scan: bool = True
    virus_scan_timeout: int = 30  # секунд
    
    # Проверка содержимого
    enable_content_validation: bool = True
    check_file_headers: bool = True
    
    # Лимиты для предотвращения DoS
    max_files_per_request: int = 10
    max_total_size_per_request: int = 100 * 1024 * 1024  # 100MB общий размер
    
    def __post_init__(self):
        """Инициализация значений по умолчанию."""
        if self.allowed_image_types is None:
            self.allowed_image_types = {
                'image/jpeg',
                'image/png', 
                'image/gif',
                'image/webp',
                'image/svg+xml',
                'image/bmp',
                'image/tiff'
            }
        
        if self.allowed_document_types is None:
            self.allowed_document_types = {
                'application/pdf',
                'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'application/vnd.ms-excel',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'application/vnd.ms-powerpoint',
                'application/vnd.openxmlformats-officedocument.presentationml.presentation',
                'text/plain',
                'text/csv',
                'application/rtf'
            }
        
        if self.allowed_video_types is None:
            self.allowed_video_types = {
                'video/mp4',
                'video/avi',
                'video/quicktime',
                'video/x-msvideo',
                'video/webm',
                'video/ogg'
            }
        
        if self.allowed_audio_types is None:
            self.allowed_audio_types = {
                'audio/mpeg',
                'audio/wav',
                'audio/ogg',
                'audio/webm',
                'audio/aac',
                'audio/flac'
            }
        
        if self.forbidden_extensions is None:
            self.forbidden_extensions = {
                # Исполняемые файлы
                '.exe', '.bat', '.cmd', '.com', '.pif', '.scr', '.vbs', '.vbe',
                '.js', '.jse', '.ws', '.wsf', '.wsc', '.wsh', '.ps1', '.ps1xml',
                '.ps2', '.ps2xml', '.psc1', '.psc2', '.msh', '.msh1', '.msh2',
                '.mshxml', '.msh1xml', '.msh2xml', '.scf', '.lnk', '.inf',
                '.reg', '.docm', '.dotm', '.xlsm', '.xltm', '.xlam', '.pptm',
                '.potm', '.ppam', '.ppsm', '.sldm',
                
                # Архивы с исполняемыми файлами (потенциально опасные)
                '.jar', '.deb', '.rpm', '.dmg', '.pkg', '.msi',
                
                # Системные файлы
                '.sys', '.dll', '.drv', '.ocx',
                
                # Конфигурационные файлы
                '.htaccess', '.htpasswd',
                
                # Файлы с двойным расширением
                '.pdf.exe', '.txt.exe', '.doc.exe', '.jpg.exe'
            }


# Предустановленные конфигурации для разных случаев использования

# Строгая конфигурация для production
STRICT_CONFIG = FileValidationConfig(
    max_file_size=5 * 1024 * 1024,     # 5MB
    max_image_size=2 * 1024 * 1024,    # 2MB для изображений
    max_document_size=10 * 1024 * 1024, # 10MB для документов
    max_compression_ratio=10.0,         # Низкий лимит сжатия
    enable_virus_scan=True,
    enable_content_validation=True,
    check_file_headers=True
)

# Конфигурация для аватаров пользователей
AVATAR_CONFIG = FileValidationConfig(
    max_file_size=1 * 1024 * 1024,  # 1MB
    allowed_document_types=set(),    # Только изображения
    allowed_video_types=set(),
    allowed_audio_types=set(),
    enable_virus_scan=True,
    enable_content_validation=True
)

# Конфигурация для квестов (изображения + документы)
QUEST_CONFIG = FileValidationConfig(
    max_file_size=10 * 1024 * 1024,  # 10MB
    max_image_size=5 * 1024 * 1024,  # 5MB для изображений
    max_document_size=20 * 1024 * 1024,  # 20MB для документов
    allowed_video_types=set(),        # Видео не разрешены
    allowed_audio_types=set(),        # Аудио не разрешены
    enable_virus_scan=True,
    enable_content_validation=True
)

# Конфигурация для разработки (более мягкие ограничения)
DEV_CONFIG = FileValidationConfig(
    max_file_size=50 * 1024 * 1024,   # 50MB
    max_compression_ratio=1000.0,     # Высокий лимит
    enable_virus_scan=False,          # Отключен для разработки
    enable_content_validation=False,   # Отключен для разработки
    check_file_headers=False
)


def get_config_for_context(context: str) -> FileValidationConfig:
    """
    Получить конфигурацию для конкретного контекста использования.
    
    Args:
        context: Контекст использования ('avatar', 'quest', 'strict', 'dev')
        
    Returns:
        Соответствующая конфигурация валидации
    """
    configs = {
        'avatar': AVATAR_CONFIG,
        'quest': QUEST_CONFIG,
        'strict': STRICT_CONFIG,
        'dev': DEV_CONFIG,
        'default': FileValidationConfig()
    }
    
    return configs.get(context, configs['default']) 