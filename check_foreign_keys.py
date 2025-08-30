#!/usr/bin/env python3
"""
Проверка всех внешних ключей
"""
import psycopg2

# Конфигурация серверной базы данных
SERVER_DB_CONFIG = {
    'host': '7da2c0adf39345ca39269f40.twc1.net',
    'port': 5432,
    'database': 'default_db',
    'user': 'gen_user',
    'password': '|dls1z:N7#v>vr',
    'sslmode': 'disable'
}

def check_foreign_keys():
    """Проверка всех внешних ключей"""
    print("🔍 ПРОВЕРКА ВСЕХ ВНЕШНИХ КЛЮЧЕЙ")
    print("=" * 80)
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Проверяем все внешние ключи
        cursor.execute("""
            SELECT 
                tc.table_name, 
                kcu.column_name, 
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name
            FROM 
                information_schema.table_constraints AS tc 
                JOIN information_schema.key_column_usage AS kcu
                  ON tc.constraint_name = kcu.constraint_name
                  AND tc.table_schema = kcu.table_schema
                JOIN information_schema.constraint_column_usage AS ccu
                  ON ccu.constraint_name = tc.constraint_name
                  AND ccu.table_schema = tc.table_schema
            WHERE tc.constraint_type = 'FOREIGN KEY' 
            ORDER BY tc.table_name, kcu.column_name
        """)
        foreign_keys = cursor.fetchall()
        
        print("📊 Все внешние ключи:")
        for fk in foreign_keys:
            print(f"  - {fk[0]}.{fk[1]} -> {fk[2]}.{fk[3]}")
        
        # Проверяем типы колонок для внешних ключей
        print("\n📊 Типы колонок для внешних ключей:")
        for fk in foreign_keys:
            # Тип колонки в таблице
            cursor.execute(f"""
                SELECT data_type 
                FROM information_schema.columns 
                WHERE table_name = '{fk[0]}' AND column_name = '{fk[1]}'
            """)
            local_type = cursor.fetchone()
            
            # Тип колонки в внешней таблице
            cursor.execute(f"""
                SELECT data_type 
                FROM information_schema.columns 
                WHERE table_name = '{fk[2]}' AND column_name = '{fk[3]}'
            """)
            foreign_type = cursor.fetchone()
            
            if local_type and foreign_type:
                print(f"  - {fk[0]}.{fk[1]} ({local_type[0]}) -> {fk[2]}.{fk[3]} ({foreign_type[0]})")
                if local_type[0] != foreign_type[0]:
                    print(f"    ⚠️  НЕСООТВЕТСТВИЕ ТИПОВ!")
        
        cursor.close()
        conn.close()
        print("\n✅ Проверка завершена!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    check_foreign_keys()
