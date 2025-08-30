#!/usr/bin/env python3
"""
Исправление типа id в таблицах токенов с INTEGER на UUID
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

def fix_token_tables_id_type():
    """Исправление типа id в таблицах токенов"""
    print("🔧 ИСПРАВЛЕНИЕ ТИПА ID В ТАБЛИЦАХ ТОКЕНОВ")
    print("=" * 80)
    
    tables_to_fix = ['refresh_token', 'reset_password_token', 'email_verification_code']
    
    try:
        conn = psycopg2.connect(**SERVER_DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        for table_name in tables_to_fix:
            print(f"\n🔧 Исправление таблицы {table_name}...")
            
            # Проверяем текущий тип id
            cursor.execute(f"""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = '{table_name}' AND column_name = 'id'
            """)
            column_info = cursor.fetchone()
            
            if column_info and column_info[1] == 'integer':
                print(f"  📋 Текущий тип id: {column_info[1]}")
                
                # Создаем временную таблицу с UUID
                temp_table = f"{table_name}_temp"
                cursor.execute(f"""
                    CREATE TABLE {temp_table} AS 
                    SELECT * FROM {table_name} LIMIT 0
                """)
                
                # Получаем структуру оригинальной таблицы
                cursor.execute(f"""
                    SELECT column_name, data_type, is_nullable, column_default
                    FROM information_schema.columns 
                    WHERE table_name = '{table_name}'
                    ORDER BY ordinal_position
                """)
                columns = cursor.fetchall()
                
                # Создаем новую структуру с UUID id
                create_columns = []
                for col in columns:
                    if col[0] == 'id':
                        create_columns.append('id UUID PRIMARY KEY DEFAULT gen_random_uuid()')
                    else:
                        nullable = "NOT NULL" if col[2] == "NO" else ""
                        default = f"DEFAULT {col[3]}" if col[3] else ""
                        create_columns.append(f"{col[0]} {col[1]} {nullable} {default}".strip())
                
                # Удаляем временную таблицу и создаем новую
                cursor.execute(f"DROP TABLE {temp_table}")
                cursor.execute(f"DROP TABLE {table_name}")
                cursor.execute(f"CREATE TABLE {table_name} ({', '.join(create_columns)})")
                
                print(f"  ✅ Таблица {table_name} исправлена")
            else:
                print(f"  ✅ Таблица {table_name} уже имеет правильный тип id")
        
        cursor.close()
        conn.close()
        print("\n✅ Исправление завершено!")
        
    except Exception as e:
        print(f"❌ Ошибка: {e}")

if __name__ == "__main__":
    fix_token_tables_id_type()
