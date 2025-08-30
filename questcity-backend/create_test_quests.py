#!/usr/bin/env python3
"""
Скрипт для очистки базы данных от квестов и создания тестовых квестов.
"""

import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime

def create_test_quests():
    """Основная функция."""
    try:
        # Подключаемся к базе данных
        conn = psycopg2.connect(
            host="localhost",
            port="5432",
            database="questcity_db",
            user="postgres",
            password="postgres"
        )
        
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        print("🚀 Начинаю очистку и создание тестовых квестов...")
        
        # Очищаем все существующие квесты
        print("🗑️ Очищаю все существующие квесты...")
        cur.execute("DELETE FROM quest")
        deleted_count = cur.rowcount
        print(f"✅ Удалено квестов: {deleted_count}")
        
        # Получаем категорию для тестовых квестов
        cur.execute("SELECT id, name FROM category LIMIT 1")
        category_result = cur.fetchone()
        if not category_result:
            print("❌ Нет категорий в базе данных!")
            return
        
        category_id = category_result["id"]
        category_name = category_result["name"]
        print(f"📂 Использую категорию: {category_name} (ID: {category_id})")
        
        # Получаем админа
        cur.execute("SELECT id, username FROM \"user\" WHERE role = 2 LIMIT 1")
        admin_result = cur.fetchone()
        if not admin_result:
            print("❌ Нет админа в базе данных!")
            return
        
        admin_id = admin_result["id"]
        admin_username = admin_result["username"]
        print(f"👤 Использую админа: {admin_username} (ID: {admin_id})")
        
        # Создаем тестовые квесты
        test_quests = [
            {
                "name": "Тестовый квест 1",
                "description": "Простой тестовый квест для проверки функциональности",
                "category_id": category_id,
                "level": "EASY",
                "timeframe": "ONE_HOUR",
                "group": "SOLO",
                "cost": 100,
                "reward": 200,
                "pay_extra": 0.0,
                "is_subscription": False,
                "created_by": admin_id,
                "created_at": datetime.now(),
                "updated_at": datetime.now()
            },
            {
                "name": "Тестовый квест 2", 
                "description": "Второй тестовый квест с другими параметрами",
                "category_id": category_id,
                "level": "MIDDLE",
                "timeframe": "TWO_HOURS", 
                "group": "GROUP",
                "cost": 150,
                "reward": 300,
                "pay_extra": 5.0,
                "is_subscription": True,
                "created_by": admin_id,
                "created_at": datetime.now(),
                "updated_at": datetime.now()
            }
        ]
        
        print("➕ Создаю тестовые квесты...")
        
        for quest_data in test_quests:
            cur.execute("""
                INSERT INTO quest (
                    name, description, category_id, level, timeframe, "group", 
                    cost, reward, pay_extra, is_subscription, created_by, 
                    created_at, updated_at
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                ) RETURNING id
            """, (
                quest_data["name"], quest_data["description"], quest_data["category_id"],
                quest_data["level"], quest_data["timeframe"], quest_data["group"],
                quest_data["cost"], quest_data["reward"], quest_data["pay_extra"],
                quest_data["is_subscription"], quest_data["created_by"],
                quest_data["created_at"], quest_data["updated_at"]
            ))
            
            quest_id = cur.fetchone()["id"]
            print(f"  ✅ Создан квест: {quest_data['name']} (ID: {quest_id})")
        
        # Сохраняем изменения
        conn.commit()
        print(f"💾 Сохранено в базу данных")
        
        # Проверяем результат
        cur.execute("SELECT COUNT(*) as count FROM quest")
        quests_count = cur.fetchone()["count"]
        print(f"📊 Всего квестов в базе: {quests_count}")
        
        # Показываем созданные квесты
        print("\n📋 Созданные квесты:")
        cur.execute("SELECT id, name, level FROM quest ORDER BY id")
        for quest in cur.fetchall():
            print(f"  - ID: {quest['id']}, Название: {quest['name']}, Сложность: {quest['level']}")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        if 'conn' in locals():
            conn.rollback()
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()
    
    print("🎉 Готово!")

if __name__ == "__main__":
    create_test_quests()
