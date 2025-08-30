from src.database import get_db
from src.models.user import User
from src.core.security import get_password_hash

# Создаем администратора
db = next(get_db())

# Проверяем, существует ли уже администратор
existing_admin = db.query(User).filter(User.email == 'admin@questcity.com').first()

if existing_admin:
    print("Администратор уже существует!")
    # Обновляем пароль
    existing_admin.hashed_password = get_password_hash('admin123')
    db.commit()
    print("Пароль обновлен на 'admin123'")
else:
    # Создаем нового администратора
    admin = User(
        email='admin@questcity.com',
        hashed_password=get_password_hash('admin123'),
        role=2,  # ADMIN
        is_verified=True
    )
    
    db.add(admin)
    db.commit()
    print("Администратор создан успешно!")

# Создаем тестового пользователя
existing_user = db.query(User).filter(User.email == 'testuser@questcity.com').first()

if existing_user:
    print("Тестовый пользователь уже существует!")
    # Обновляем пароль
    existing_user.hashed_password = get_password_hash('password123')
    db.commit()
    print("Пароль обновлен на 'password123'")
else:
    # Создаем нового тестового пользователя
    user = User(
        email='testuser@questcity.com',
        hashed_password=get_password_hash('password123'),
        role=0,  # USER
        is_verified=True
    )
    
    db.add(user)
    db.commit()
    print("Тестовый пользователь создан успешно!")

# Показываем всех пользователей
users = db.query(User).all()
print(f"Пользователи в базе данных ({len(users)}):")
for user in users:
    role_name = "ADMIN" if user.role == 2 else "USER" if user.role == 0 else "MODERATOR"
    print(f"ID: {user.id}, Email: {user.email}, Role: {role_name}, Verified: {user.is_verified}")

print("Готово! Теперь можно войти в систему:")
print("Администратор: admin@questcity.com / admin123")
print("Пользователь: testuser@questcity.com / password123")

