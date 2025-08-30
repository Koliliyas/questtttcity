"""
Система разрешений для Questcity Backend.
Определяет все возможные действия в системе и логику их проверки.
"""
from enum import Enum
from typing import Set

from src.db.models.user import User


class Permission(Enum):
    """
    Все возможные разрешения в системе.
    Каждое разрешение представляет конкретное действие.
    """
    
    # === БАЗОВЫЕ ДЕЙСТВИЯ ===
    VIEW_OWN_PROFILE = "view_own_profile"
    EDIT_OWN_PROFILE = "edit_own_profile"
    
    # === ПОЛЬЗОВАТЕЛИ ===
    VIEW_USERS = "view_users"
    EDIT_USER_PROFILES = "edit_user_profiles"
    LOCK_USERS = "lock_users"
    UNLOCK_USERS = "unlock_users"
    DELETE_USERS = "delete_users"
    MANAGE_USER_ROLES = "manage_user_roles"
    
    # === КВЕСТЫ ===
    VIEW_QUESTS = "view_quests"
    CREATE_QUESTS = "create_quests"
    EDIT_QUESTS = "edit_quests"
    DELETE_QUESTS = "delete_quests"
    MODERATE_QUESTS = "moderate_quests"
    
    # === КАТЕГОРИИ И ТЕГИ ===
    MANAGE_CATEGORIES = "manage_categories"
    MANAGE_PLACES = "manage_places"
    MANAGE_VEHICLES = "manage_vehicles"
    MANAGE_TOOLS = "manage_tools"
    MANAGE_ACTIVITIES = "manage_activities"
    
    # === ЧАТЫ И СООБЩЕНИЯ ===
    CREATE_CHATS = "create_chats"
    SEND_MESSAGES = "send_messages"
    DELETE_MESSAGES = "delete_messages"
    MODERATE_CHATS = "moderate_chats"
    
    # === ОТЗЫВЫ ===
    WRITE_REVIEWS = "write_reviews"
    MODERATE_REVIEWS = "moderate_reviews"
    
    # === ИЗБРАННОЕ ===
    VIEW_USER_FAVORITES = "view_user_favorites"
    
    # === ЗАЯВКИ НА РАЗБЛОКИРОВКУ ===
    MANAGE_UNLOCK_REQUESTS = "manage_unlock_requests"
    RESPOND_TO_REVIEWS = "respond_to_reviews"
    
    # === МЕРЧ ===
    VIEW_MERCH = "view_merch"
    MANAGE_MERCH = "manage_merch"
    
    # === ДРУЗЬЯ ===
    MANAGE_FRIENDS = "manage_friends"
    SEND_FRIEND_REQUESTS = "send_friend_requests"
    
    # === ИЗБРАННОЕ (управление) ===
    MANAGE_FAVORITES = "manage_favorites"
    
    # === АДМИНИСТРИРОВАНИЕ ===
    VIEW_ADMIN_PANEL = "view_admin_panel"
    MANAGE_SYSTEM_SETTINGS = "manage_system_settings"
    VIEW_LOGS = "view_logs"
    MANAGE_BACKUPS = "manage_backups"


class Role(Enum):
    """
    Роли пользователей с базовыми разрешениями.
    """
    USER = 0
    MANAGER = 1
    ADMIN = 2


# Базовые разрешения для каждой роли
_USER_PERMISSIONS = {
    # Базовые действия
    Permission.VIEW_OWN_PROFILE,
    Permission.EDIT_OWN_PROFILE,
    
    # Квесты
    Permission.VIEW_QUESTS,
    
    # Чаты
    Permission.CREATE_CHATS,
    Permission.SEND_MESSAGES,
    
    # Отзывы
    Permission.WRITE_REVIEWS,
    
    # Мерч
    Permission.VIEW_MERCH,
    
    # Друзья
    Permission.MANAGE_FRIENDS,
    Permission.SEND_FRIEND_REQUESTS,
    
    # Избранное
    Permission.MANAGE_FAVORITES,
}

_MANAGER_PERMISSIONS = {
    # Все права пользователя
    *_USER_PERMISSIONS,
    
    # Дополнительные права менеджера
    Permission.VIEW_USERS,
    Permission.CREATE_QUESTS,
    Permission.MODERATE_QUESTS,
    Permission.MODERATE_REVIEWS,
    Permission.RESPOND_TO_REVIEWS,
    Permission.MODERATE_CHATS,
    Permission.DELETE_MESSAGES,
}

_ADMIN_PERMISSIONS = {
    # Все права менеджера
    *_MANAGER_PERMISSIONS,
    
    # Полные административные права
    Permission.EDIT_USER_PROFILES,
    Permission.LOCK_USERS,
    Permission.UNLOCK_USERS,
    Permission.DELETE_USERS,
    Permission.MANAGE_USER_ROLES,
    Permission.EDIT_QUESTS,
    Permission.DELETE_QUESTS,
    Permission.MANAGE_CATEGORIES,
    Permission.MANAGE_PLACES,
    Permission.MANAGE_VEHICLES,
    Permission.MANAGE_TOOLS,
    Permission.MANAGE_ACTIVITIES,
    Permission.MANAGE_MERCH,
    Permission.VIEW_ADMIN_PANEL,
    Permission.MANAGE_SYSTEM_SETTINGS,
    Permission.VIEW_LOGS,
    Permission.MANAGE_BACKUPS,
}

# Карта разрешений для каждой роли
ROLE_PERMISSIONS: dict[Role, Set[Permission]] = {
    Role.USER: _USER_PERMISSIONS,
    Role.MANAGER: _MANAGER_PERMISSIONS,
    Role.ADMIN: _ADMIN_PERMISSIONS,
}


def get_user_permissions(user: User) -> Set[Permission]:
    """
    Получает все разрешения пользователя на основе роли и специальных флагов.
    
    Args:
        user: Пользователь из БД
        
    Returns:
        Множество разрешений пользователя
    """
    # Получаем базовые разрешения роли
    try:
        role = Role(user.role)
        permissions = ROLE_PERMISSIONS.get(role, set()).copy()
    except ValueError:
        # Если роль неизвестна, даем только базовые права пользователя
        permissions = ROLE_PERMISSIONS[Role.USER].copy()
    
    # Добавляем специальные разрешения на основе флагов
    if user.can_edit_quests:
        permissions.add(Permission.EDIT_QUESTS)
        permissions.add(Permission.CREATE_QUESTS)
        permissions.add(Permission.DELETE_QUESTS)
        permissions.add(Permission.MANAGE_CATEGORIES)
        permissions.add(Permission.MANAGE_PLACES)
        permissions.add(Permission.MANAGE_VEHICLES)
        permissions.add(Permission.MANAGE_TOOLS)
        permissions.add(Permission.MANAGE_ACTIVITIES)
    
    if user.can_lock_users:
        permissions.add(Permission.LOCK_USERS)
        permissions.add(Permission.UNLOCK_USERS)
        permissions.add(Permission.VIEW_USERS)
        permissions.add(Permission.EDIT_USER_PROFILES)
    
    return permissions


def user_has_permission(user: User, permission: Permission) -> bool:
    """
    Проверяет есть ли у пользователя конкретное разрешение.
    
    Args:
        user: Пользователь из БД
        permission: Проверяемое разрешение
        
    Returns:
        True если разрешение есть, False иначе
    """
    # Проверяем что пользователь активен и верифицирован
    if not user.is_active:
        return False
        
    # Для некоторых базовых действий верификация не нужна
    basic_permissions = {
        Permission.VIEW_OWN_PROFILE,
        Permission.EDIT_OWN_PROFILE,
    }
    
    if permission not in basic_permissions and not user.is_verified:
        return False
    
    user_permissions = get_user_permissions(user)
    return permission in user_permissions


def user_has_any_permission(user: User, permissions: Set[Permission]) -> bool:
    """
    Проверяет есть ли у пользователя хотя бы одно из указанных разрешений.
    
    Args:
        user: Пользователь из БД
        permissions: Множество проверяемых разрешений
        
    Returns:
        True если есть хотя бы одно разрешение, False иначе
    """
    user_permissions = get_user_permissions(user)
    return bool(user_permissions & permissions)


def user_has_all_permissions(user: User, permissions: Set[Permission]) -> bool:
    """
    Проверяет есть ли у пользователя все указанные разрешения.
    
    Args:
        user: Пользователь из БД
        permissions: Множество проверяемых разрешений
        
    Returns:
        True если есть все разрешения, False иначе
    """
    user_permissions = get_user_permissions(user)
    return permissions.issubset(user_permissions) 