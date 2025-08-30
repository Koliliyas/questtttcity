from src.api.exceptions import BaseHTTPError
from src.settings import BASE_DIR

STATIC_DIR = BASE_DIR / "static_files"
EXCEL_TYPES = {
    "application/vnd.ms-excel": "xlsx",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": "xls",
}


def get_responses(errors: list[BaseHTTPError]) -> dict:
    result = {}
    for error in errors:
        if error.status_code not in result:
            result[error.status_code] = {
                "content": {
                    "application/json": {
                        "examples": {error.code: {"value": error.error_schema}}
                    }
                }
            }
        else:
            result[error.status_code]["content"]["application/json"]["examples"][
                error.code
            ] = {"value": error.error_schema}
    return result
