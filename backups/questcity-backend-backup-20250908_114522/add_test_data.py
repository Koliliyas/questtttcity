#!/usr/bin/env python3
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime

def add_test_data():
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
        
        print("🚀 Добавляем тестовые данные...")
        
        # Добавляем категории
        categories = [
            {"name": "Городские квесты", "image": "assets/icons/city.svg"},
            {"name": "Исторические", "image": "assets/icons/history.svg"},
            {"name": "Приключения", "image": "assets/icons/adventure.svg"},
            {"name": "Детективы", "image": "assets/icons/detective.svg"},
        ]
        
        print("📊 Добавляем категории...")
        category_ids = []
        for category in categories:
            cur.execute("""
                INSERT INTO category (name, image, created_at, updated_at)
                VALUES (%s, %s, %s, %s) RETURNING id
            """, (category["name"], category["image"], datetime.now(), datetime.now()))
            category_id = cur.fetchone()["id"]
            category_ids.append(category_id)
            print(f"  ✅ Добавлена категория: {category['name']} (ID: {category_id})")
        
        print("\n📊 Добавляем транспортные средства...")
        vehicles = [
            {"name": "Пешком"},
            {"name": "Велосипед"},
            {"name": "Автомобиль"},
        ]
        
        vehicle_ids = []
        for vehicle in vehicles:
            cur.execute("""
                INSERT INTO vehicle (name)
                VALUES (%s) RETURNING id
            """, (vehicle["name"],))
            vehicle_id = cur.fetchone()["id"]
            vehicle_ids.append(vehicle_id)
            print(f"  ✅ Добавлено ТС: {vehicle['name']} (ID: {vehicle_id})")
        
        print("\n📊 Добавляем места...")
        places = [
            {"name": "Центр города"},
            {"name": "Городской парк"},
            {"name": "Исторический район"},
        ]
        
        place_ids = []
        for place in places:
            cur.execute("""
                INSERT INTO place (name)
                VALUES (%s) RETURNING id
            """, (place["name"][:16],))
            place_id = cur.fetchone()["id"]
            place_ids.append(place_id)
            print(f"  ✅ Добавлено место: {place['name']} (ID: {place_id})")
        
        # Добавляем тестовые квесты
        quests = [
            {
                "name": "Тайны старого города",
                "description": "Исследуйте исторический центр города и раскройте его секреты",
                "category_id": category_ids[0] if category_ids else None,
                "cost": 1500,
                "reward": 2000,
                "level": "MIDDLE",
                "timeframe": "THREE_HOURS",
                "image": "assets/images/quest1.jpg",
                "mentor_preference": "GUIDE",
                "grouptype": "TWO",
                "milage": "UP_TO_TEN",
                "vehicle_id": vehicle_ids[0] if vehicle_ids else None,
                "place_id": place_ids[0] if place_ids else None
            },
            {
                "name": "Детектив в парке",
                "description": "Решите загадочное преступление в городском парке",
                "category_id": category_ids[2] if len(category_ids) > 2 else None,
                "cost": 1000,
                "reward": 1500,
                "level": "EASY",
                "timeframe": "ONE_HOUR",
                "image": "assets/images/quest2.jpg",
                "mentor_preference": "GUIDE",
                "grouptype": "TWO",
                "milage": "UP_TO_TEN",
                "vehicle_id": vehicle_ids[0] if vehicle_ids else None,
                "place_id": place_ids[1] if len(place_ids) > 1 else place_ids[0] if place_ids else None
            },
            {
                "name": "Историческая прогулка",
                "description": "Погрузитесь в историю города через увлекательный квест",
                "category_id": category_ids[1] if len(category_ids) > 1 else None,
                "cost": 2000,
                "reward": 2500,
                "level": "HARD",
                "timeframe": "DAY",
                "image": "assets/images/quest3.jpg",
                "mentor_preference": "GUIDE",
                "grouptype": "THREE",
                "milage": "UP_TO_THIRTY",
                "vehicle_id": vehicle_ids[1] if len(vehicle_ids) > 1 else vehicle_ids[0] if vehicle_ids else None,
                "place_id": place_ids[2] if len(place_ids) > 2 else place_ids[0] if place_ids else None
            }
        ]
        
        print("\n📊 Добавляем квесты...")
        for quest in quests:
            cur.execute("""
                INSERT INTO quest (name, description, category_id, cost, reward, level, timeframe,
                                 auto_accrual, is_subscription, pay_extra, image, mentor_preference, 
                                 "group", milage, vehicle_id, place_id, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                quest["name"], quest["description"], quest["category_id"],
                quest["cost"], quest["reward"], quest["level"], quest["timeframe"],
                False, False, 0, quest["image"], quest["mentor_preference"], 
                quest["grouptype"], quest["milage"], quest["vehicle_id"], quest["place_id"], 
                datetime.now(), datetime.now()
            ))
            print(f"  ✅ Добавлен квест: {quest['name']}")
        
        # Подтверждаем изменения
        conn.commit()
        
        print("\n✅ Тестовые данные успешно добавлены!")
        
        # Проверяем результат
        cur.execute("SELECT COUNT(*) as count FROM quest")
        quest_count = cur.fetchone()
        print(f"📊 Теперь квестов в базе: {quest_count['count']}")
        
        cur.execute("SELECT COUNT(*) as count FROM category")
        category_count = cur.fetchone()
        print(f"📊 Теперь категорий в базе: {category_count['count']}")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при добавлении данных: {e}")

if __name__ == "__main__":
    add_test_data()
