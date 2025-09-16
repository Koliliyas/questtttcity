#!/usr/bin/env python3
import psycopg2
from psycopg2.extras import RealDictCursor

def check_database_direct():
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
        
        # Проверяем таблицы
        cur.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
            ORDER BY table_name
        """)
        tables = cur.fetchall()
        print("📊 Таблицы в базе данных:")
        for table in tables:
            print(f"  - {table['table_name']}")
        
        # Проверяем квесты
        cur.execute("SELECT COUNT(*) as count FROM quest")
        quest_count = cur.fetchone()
        print(f"\n📊 Всего квестов: {quest_count['count']}")
        
        if quest_count['count'] > 0:
            cur.execute("SELECT id, name FROM quest LIMIT 5")
            quests = cur.fetchall()
            print("\n🔍 Первые 5 квестов:")
            for quest in quests:
                print(f"  - ID: {quest['id']}, Название: {quest['name']}")
        else:
            print("❌ Квестов в базе данных нет!")
        
        # Проверяем категории
        cur.execute("SELECT COUNT(*) as count FROM category")
        category_count = cur.fetchone()
        print(f"\n📊 Всего категорий: {category_count['count']}")
        
        if category_count['count'] > 0:
            cur.execute("SELECT id, name FROM category")
            categories = cur.fetchall()
            print("\n🔍 Категории:")
            for category in categories:
                print(f"  - ID: {category['id']}, Название: {category['name']}")
        else:
            print("❌ Категорий в базе данных нет!")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка при подключении к базе данных: {e}")

if __name__ == "__main__":
    check_database_direct()
