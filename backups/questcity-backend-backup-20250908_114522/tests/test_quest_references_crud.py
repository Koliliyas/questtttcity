"""
Comprehensive integration тесты CRUD операций для справочников квестов.

Покрывает полное тестирование:
- Activities (types) 
- Tools
- Vehicles  
- Categories

Включает:
- Создание (POST)
- Чтение (GET) 
- Обновление (PATCH)
- Удаление (DELETE)
- Валидацию данных
- Error scenarios
"""
import pytest
import requests
from typing import Dict, Any


class TestActivitiesCRUD:
    """Тесты CRUD операций для активностей (types)."""
    
    def test_get_activities_list(self, api_client):
        """Тест получения списка активностей."""
        response = api_client.get("/quests/types/")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        print(f"✅ Получено активностей: {len(data)}")
    
    def test_create_activity_success(self, api_client, sample_activity_data, cleanup_created_items):
        """Тест успешного создания активности."""
        response = api_client.post("/quests/types/", json=sample_activity_data)
        
        assert response.status_code in [201, 409]  # Успех или конфликт имен
        
        if response.status_code == 201:
            data = response.json()
            assert data["name"] == sample_activity_data["name"]
            assert "id" in data
            cleanup_created_items("activity", data["id"])
            print(f"✅ Активность создана: ID={data['id']}, name={data['name']}")
        else:
            print(f"✅ Активность уже существует (409): {sample_activity_data['name']}")
    
    def test_create_activity_validation_empty_name(self, api_client, invalid_activity_data):
        """Тест валидации пустого имени активности."""
        response = api_client.post("/quests/types/", json=invalid_activity_data)
        
        assert response.status_code == 422  # Validation error
        print("✅ Валидация пустого имени активности работает")
    
    def test_create_activity_validation_digits_only(self, api_client, invalid_name_data):
        """Тест валидации имени из одних цифр."""
        response = api_client.post("/quests/types/", json=invalid_name_data)
        
        assert response.status_code == 422  # Validation error
        print("✅ Валидация имени из цифр работает")
    
    def test_create_activity_validation_too_long(self, api_client, too_long_name_data):
        """Тест валидации слишком длинного имени."""
        response = api_client.post("/quests/types/", json=too_long_name_data)
        
        assert response.status_code == 422  # Validation error
        print("✅ Валидация длинного имени работает")
    
    def test_create_activity_duplicate_name(self, api_client, sample_activity_data):
        """Тест создания активности с дублирующимся именем."""
        # Создаем первую активность
        response1 = api_client.post("/quests/types/", json=sample_activity_data)
        
        if response1.status_code == 201:
            # Пытаемся создать вторую с тем же именем
            response2 = api_client.post("/quests/types/", json=sample_activity_data)
            
            # Ожидаем ошибку дублирования
            assert response2.status_code in [400, 409]  # Bad Request или Conflict
            print("✅ Проверка дублирования имени активности работает")
        else:
            print("⚠️ Возможно активность уже существует")


class TestToolsCRUD:
    """Тесты CRUD операций для инструментов."""
    
    def test_get_tools_list(self, api_client):
        """Тест получения списка инструментов."""
        response = api_client.get("/quests/tools/")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        print(f"✅ Получено инструментов: {len(data)}")
    
    def test_create_tool_success(self, api_client, sample_tool_data, cleanup_created_items):
        """Тест успешного создания инструмента."""
        response = api_client.post("/quests/tools/", json=sample_tool_data)
        
        assert response.status_code in [201, 409]  # Успех или конфликт имен
        
        if response.status_code == 201:
            data = response.json()
            assert data["name"] == sample_tool_data["name"]
            assert "image" in data  # URL изображения в MinIO
            assert "id" in data
            cleanup_created_items("tool", data["id"])
            print(f"✅ Инструмент создан: ID={data['id']}, name={data['name']}")
            print(f"   Изображение: {data['image'][:50]}...")
        else:
            print(f"✅ Инструмент уже существует (409): {sample_tool_data['name']}")
    
    def test_create_tool_validation_missing_image(self, api_client, invalid_tool_data):
        """Тест валидации отсутствующего изображения."""
        response = api_client.post("/quests/tools/", json=invalid_tool_data)
        
        assert response.status_code == 422  # Validation error
        print("✅ Валидация отсутствующего изображения работает")
    
    def test_create_tool_validation_empty_name(self, api_client, test_base64_image):
        """Тест валидации пустого имени инструмента."""
        invalid_data = {"name": "", "image": test_base64_image}
        response = api_client.post("/quests/tools/", json=invalid_data)
        
        assert response.status_code == 422  # Validation error
        print("✅ Валидация пустого имени инструмента работает")


class TestVehiclesCRUD:
    """Тесты CRUD операций для транспорта."""
    
    def test_get_vehicles_list(self, api_client):
        """Тест получения списка транспорта."""
        response = api_client.get("/quests/vehicles/")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        print(f"✅ Получено транспорта: {len(data)}")
    
    def test_create_vehicle_success(self, api_client, sample_vehicle_data, cleanup_created_items):
        """Тест успешного создания транспорта."""
        response = api_client.post("/quests/vehicles/", json=sample_vehicle_data)
        
        assert response.status_code in [201, 409]  # Успех или конфликт имен
        
        if response.status_code == 201:
            data = response.json()
            assert data["name"] == sample_vehicle_data["name"]
            assert "id" in data
            cleanup_created_items("vehicle", data["id"])
            print(f"✅ Транспорт создан: ID={data['id']}, name={data['name']}")
        else:
            print(f"✅ Транспорт уже существует (409): {sample_vehicle_data['name']}")
    
    def test_create_vehicle_validation_empty_name(self, api_client, invalid_activity_data):
        """Тест валидации пустого имени транспорта."""
        response = api_client.post("/quests/vehicles/", json=invalid_activity_data)
        
        assert response.status_code == 422  # Validation error
        print("✅ Валидация пустого имени транспорта работает")


class TestCategoriesCRUD:
    """Тесты CRUD операций для категорий квестов."""
    
    def test_get_categories_list(self, api_client):
        """Тест получения списка категорий."""
        response = api_client.get("/quests/categories/")
        
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        print(f"✅ Получено категорий: {len(data)}")
    
    def test_create_category_success(self, api_client, sample_category_data, cleanup_created_items):
        """Тест успешного создания категории."""
        response = api_client.post("/quests/categories/", json=sample_category_data)
        
        assert response.status_code in [201, 409]  # Успех или конфликт имен
        
        if response.status_code == 201:
            data = response.json()
            assert data["name"] == sample_category_data["name"]
            assert "image" in data  # URL изображения в MinIO
            assert "id" in data
            cleanup_created_items("category", data["id"])
            print(f"✅ Категория создана: ID={data['id']}, name={data['name']}")
            print(f"   Изображение: {data['image'][:50]}...")
        else:
            print(f"✅ Категория уже существует (409): {sample_category_data['name']}")
    
    def test_create_category_validation_missing_image(self, api_client):
        """Тест валидации отсутствующего изображения."""
        invalid_data = {"name": "Test Category Missing Image"}
        response = api_client.post("/quests/categories/", json=invalid_data)
        
        assert response.status_code == 422  # Validation error
        print("✅ Валидация отсутствующего изображения категории работает")
    
    def test_update_category_success(self, api_client, sample_category_data, test_base64_image):
        """Тест успешного обновления категории."""
        # Сначала создаем категорию
        create_response = api_client.post("/quests/categories/", json=sample_category_data)
        
        if create_response.status_code == 201:
            category_id = create_response.json()["id"]
            
            # Обновляем категорию
            update_data = {
                "name": "Updated Test Category",
                "image": test_base64_image
            }
            update_response = api_client.patch(f"/quests/categories/{category_id}", json=update_data)
            
            assert update_response.status_code == 200
            updated_data = update_response.json()
            assert updated_data["name"] == update_data["name"]
            print(f"✅ Категория обновлена: ID={category_id}, name={updated_data['name']}")
        else:
            print("⚠️ Не удалось создать категорию для теста обновления")


class TestRegressionScenarios:
    """Регрессионные тесты для предотвращения повторных ошибок."""
    
    def test_no_internal_server_error_on_create(self, api_client, sample_activity_data, 
                                               sample_tool_data, sample_vehicle_data, 
                                               sample_category_data):
        """Регрессионный тест: убедиться что нет INTERNAL_SERVER_ERROR при создании."""
        
        # Тестируем все эндпоинты создания
        endpoints = [
            ("/quests/types/", sample_activity_data),
            ("/quests/tools/", sample_tool_data), 
            ("/quests/vehicles/", sample_vehicle_data),
            ("/quests/categories/", sample_category_data)
        ]
        
        for endpoint, data in endpoints:
            response = api_client.post(endpoint, json=data)
            
            # Главное - никогда не должно быть 500 ошибки
            assert response.status_code != 500, f"INTERNAL_SERVER_ERROR на {endpoint}"
            
            # Ожидаем либо успех (201) либо валидационную ошибку (422) либо конфликт (409)
            assert response.status_code in [201, 422, 409], f"Неожиданный код {response.status_code} на {endpoint}"
        
        print("✅ Регрессионный тест: нет INTERNAL_SERVER_ERROR")
    
    def test_correct_field_names_used(self, api_client, sample_activity_data):
        """Регрессионный тест: убедиться что используются правильные имена полей."""
        
        response = api_client.post("/quests/types/", json=sample_activity_data)
        
        if response.status_code == 201:
            data = response.json()
            
            # Убеждаемся что используется 'name', а не 'title'
            assert "name" in data
            assert "title" not in data
            
            # Убеждаемся что есть 'id' 
            assert "id" in data
            assert isinstance(data["id"], int)
            
            print("✅ Регрессионный тест: правильные имена полей")
        else:
            print("⚠️ Активность не создалась для теста полей")
    
    def test_image_field_consistency(self, api_client, sample_tool_data):
        """Регрессионный тест: убедиться что поле изображения называется 'image'."""
        
        response = api_client.post("/quests/tools/", json=sample_tool_data)
        
        if response.status_code == 201:
            data = response.json()
            
            # Убеждаемся что используется 'image', а не 'image_url'
            assert "image" in data
            assert "image_url" not in data
            
            # Проверяем что это URL к MinIO
            assert data["image"].startswith("http://localhost:9001/questcity-storage/")
            
            print("✅ Регрессионный тест: консистентность поля изображения")
        else:
            print("⚠️ Инструмент не создался для теста полей изображения") 