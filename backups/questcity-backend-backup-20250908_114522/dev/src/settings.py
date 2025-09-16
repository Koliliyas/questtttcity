from functools import lru_cache
from pathlib import Path
from typing import Type, TypeVar

import dotenv
from fastapi_mail import ConnectionConfig
from pydantic_settings import BaseSettings, SettingsConfigDict

TSettings = TypeVar("TSettings", bound=BaseSettings)
BASE_DIR = Path(__file__).parent.parent


@lru_cache
def get_settings(cls: Type[TSettings]) -> TSettings:
    """Фабричная функция для создания экземпляров классов настроек с подгрузкой переменных окружения из .env файла.

    Args:
        cls (Type[TSettings]): класс для создания экземпляра после подгрузки переменных окружения.

    Returns:
        TSettings: экземпляр класса настроек.
    """
    dotenv.load_dotenv()
    return cls()


class MailSettings(ConnectionConfig):
    model_config = SettingsConfigDict(str_strip_whitespace=True)

    TEMPLATE_FOLDER: Path = BASE_DIR / "static_files" / "mail_templates"


class EmailVerificationSettings(BaseSettings):
    code_expire_minutes: int = 10
    token_expire_minutes: int = 10


class AuthJWTSettings(BaseSettings):
    private_key_path: Path = BASE_DIR / "certs" / "jwt-private.pem"
    public_key_path: Path = BASE_DIR / "certs" / "jwt-public.pem"

    algorithm: str = "RS256"

    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30


class ApplicationSettings(BaseSettings):
    model_config = SettingsConfigDict(str_strip_whitespace=True, env_prefix="app_")

    host: str
    port: int
    reload: bool

    session_secret_key: str

    allow_origins: list[str]
    allow_origin_regex: str
    allow_methods: list[str]
    allow_headers: list[str]


class DatabaseSettings(BaseSettings):
    model_config = SettingsConfigDict(str_strip_whitespace=True, env_prefix="database_")

    driver: str = "postgresql+asyncpg"
    username: str
    password: str
    host: str
    port: int
    name: str

    @property
    def url(self) -> str:
        return f"{self.driver}://{self.username}:{self.password}@{self.host}:{self.port}/{self.name}"


class S3Settings(BaseSettings):
    model_config = SettingsConfigDict(
        str_strip_whitespace=True,
        env_prefix="s3_",
    )
    access_key: str
    secret_key: str
    endpoint: str
    bucket_name: str

    browser_url: str

    connect_timeout: int = 5
    read_timeout: int = 10
    max_attempts: int = 3
    mode: str = "standard"
