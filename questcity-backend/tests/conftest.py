"""
Конфигурация pytest для integration тестов QuestCity Backend API.
"""
import pytest
import requests
from typing import Generator, Dict, Any
import os


@pytest.fixture(scope="session")
def api_base_url() -> str:
    """Base URL для API."""
    return os.getenv("API_BASE_URL", "http://localhost:8000/api/v1")


@pytest.fixture(scope="session")
def admin_token() -> str:
    """Токен администратора для тестов."""
    token_file = ".admin_token"
    try:
        with open(token_file, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        pytest.fail(f"Файл токена {token_file} не найден. Запустите quick_start.sh")


@pytest.fixture
def auth_headers(admin_token: str) -> Dict[str, str]:
    """Заголовки авторизации для API запросов."""
    return {
        "Authorization": f"Bearer {admin_token}",
        "Content-Type": "application/json"
    }


@pytest.fixture
def api_client(api_base_url: str, auth_headers: Dict[str, str]):
    """Клиент для API запросов с авторизацией."""
    class APIClient:
        def __init__(self, base_url: str, headers: Dict[str, str]):
            self.base_url = base_url
            self.headers = headers
        
        def get(self, endpoint: str, **kwargs):
            return requests.get(f"{self.base_url}{endpoint}", headers=self.headers, **kwargs)
        
        def post(self, endpoint: str, json=None, **kwargs):
            return requests.post(f"{self.base_url}{endpoint}", headers=self.headers, json=json, **kwargs)
        
        def put(self, endpoint: str, json=None, **kwargs):
            return requests.put(f"{self.base_url}{endpoint}", headers=self.headers, json=json, **kwargs)
        
        def patch(self, endpoint: str, json=None, **kwargs):
            return requests.patch(f"{self.base_url}{endpoint}", headers=self.headers, json=json, **kwargs)
        
        def delete(self, endpoint: str, **kwargs):
            return requests.delete(f"{self.base_url}{endpoint}", headers=self.headers, **kwargs)
    
    return APIClient(api_base_url, auth_headers)


@pytest.fixture(scope="session")
def test_base64_image() -> str:
    """Тестовое base64 изображение для создания справочников с изображениями."""
    # Минимальное PNG изображение 1x1 в base64
    return "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="


@pytest.fixture
def cleanup_created_items():
    """Фикстура для очистки созданных в тестах элементов."""
    created_items = []
    
    def add_item(item_type: str, item_id: int):
        """Добавить элемент для последующей очистки."""
        created_items.append((item_type, item_id))
    
    yield add_item
    
    # Cleanup после тестов (если нужно)
    # В нашем случае не удаляем, так как это могут быть референсные данные


# Тестовые данные для разных типов справочников
@pytest.fixture
def sample_activity_data() -> Dict[str, Any]:
    """Тестовые данные для создания активности."""
    return {"name": "Test Activity Automation"}


@pytest.fixture  
def sample_tool_data(test_base64_image: str) -> Dict[str, Any]:
    """Тестовые данные для создания инструмента."""
    return {
        "name": "Test Tool Automation",
        "image": test_base64_image
    }


@pytest.fixture
def sample_vehicle_data() -> Dict[str, Any]:
    """Тестовые данные для создания транспорта."""
    return {"name": "Test Vehicle"}


@pytest.fixture
def sample_category_data(test_base64_image: str) -> Dict[str, Any]:
    """Тестовые данные для создания категории."""
    return {
        "name": "Test Category Automation", 
        "image": test_base64_image
    }


# Валидационные данные для error тестов
@pytest.fixture
def invalid_activity_data() -> Dict[str, Any]:
    """Невалидные данные для тестирования валидации активности."""
    return {"name": ""}  # Пустое имя


@pytest.fixture
def invalid_tool_data() -> Dict[str, Any]:
    """Невалидные данные для тестирования валидации инструмента."""
    return {"name": "Test Tool"}  # Отсутствует image


@pytest.fixture
def invalid_name_data() -> Dict[str, Any]:
    """Данные с невалидным именем (только цифры)."""
    return {"name": "12345"}


@pytest.fixture
def too_long_name_data() -> Dict[str, Any]:
    """Данные со слишком длинным именем."""
    return {"name": "a" * 200}  # Превышает max_length=128 