import dotenv
import uvicorn
from alembic import command
from alembic.config import Config

from logger import get_logger
from settings import ApplicationSettings, get_settings

logger = get_logger(__name__)

if __name__ == "__main__":
    try:
        alembic_cfg = Config("alembic.ini")
        command.upgrade(alembic_cfg, "heads")
    except Exception as e:
        logger.error(f"Failed to apply migrations: {str(e)}", exc_info=True)

    settings: ApplicationSettings = get_settings(ApplicationSettings)
    dotenv.load_dotenv(".env")
    uvicorn.run(
        "src.app:create_app",
        host=settings.host,
        port=settings.port,
        reload=settings.reload,
        factory=True,
        log_config="logging_config.json",
        use_colors=False,
    )
