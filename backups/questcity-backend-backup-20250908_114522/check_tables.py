#!/usr/bin/env python3
import psycopg2

def check_table_structure():
    try:
        conn = psycopg2.connect(
            host="localhost",
            port="5432",
            database="questcity_db",
            user="postgres",
            password="postgres"
        )
        
        cur = conn.cursor()
        
        # Проверяем структуру таблицы category
        print("📊 Структура таблицы category:")
        cur.execute("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'category' 
            ORDER BY ordinal_position
        """)
        category_columns = cur.fetchall()
        for col in category_columns:
            print(f"  - {col[0]}: {col[1]}")
        
        print("\n📊 Структура таблицы quest:")
        cur.execute("""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_name = 'quest' 
            ORDER BY ordinal_position
        """)
        quest_columns = cur.fetchall()
        for col in quest_columns:
            print(f"  - {col[0]}: {col[1]}")
        
        cur.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_table_structure()

































