"""
FastAPI dependencies для проверки разрешений.
Заменяют старые get_user_with_role на более гранулярные проверки.
"""
from typing import Set

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.api.exceptions import PermissionDeniedHTTPError
from src.core.authentication.dependencies import get_current_user
from src.core.authorization.permissions import Permission, user_has_permission, user_has_any_permission, user_has_all_permissions
from src.db.dependencies import create_session_depends
from src.db.models.user import User


def require_permission(permission: Permission):
    """
    Dependency factory для проверки одного разрешения.
    
    Args:
        permission: Требуемое разрешение
        
    Returns:
        FastAPI dependency функция
    """
    async def dependency(user: User = Depends(get_current_user)) -> User:
        if not user_has_permission(user, permission):
            raise PermissionDeniedHTTPError(f"Permission required: {permission.value}")
        return user
    
    return dependency


def require_any_permission(permissions: Set[Permission]):
    """
    Dependency factory для проверки любого из разрешений.
    
    Args:
        permissions: Множество разрешений (нужно хотя бы одно)
        
    Returns:
        FastAPI dependency функция
    """
    async def dependency(user: User = Depends(get_current_user)) -> User:
        if not user_has_any_permission(user, permissions):
            permission_names = [p.value for p in permissions]
            raise PermissionDeniedHTTPError(f"Any of permissions required: {permission_names}")
        return user
    
    return dependency


def require_all_permissions(permissions: Set[Permission]):
    """
    Dependency factory для проверки всех разрешений.
    
    Args:
        permissions: Множество разрешений (нужны все)
        
    Returns:
        FastAPI dependency функция
    """
    async def dependency(user: User = Depends(get_current_user)) -> User:
        if not user_has_all_permissions(user, permissions):
            permission_names = [p.value for p in permissions]
            raise PermissionDeniedHTTPError(f"All permissions required: {permission_names}")
        return user
    
    return dependency


# === ГОТОВЫЕ DEPENDENCIES ДЛЯ ЧАСТЫХ СЛУЧАЕВ ===

# Базовые
require_authenticated = require_permission(Permission.VIEW_OWN_PROFILE)

# Квесты
require_view_quests = require_permission(Permission.VIEW_QUESTS)
require_create_quests = require_permission(Permission.CREATE_QUESTS)
require_edit_quests = require_permission(Permission.EDIT_QUESTS)
require_delete_quests = require_permission(Permission.DELETE_QUESTS)
require_moderate_quests = require_permission(Permission.MODERATE_QUESTS)

# Пользователи
require_view_users = require_permission(Permission.VIEW_USERS)
require_edit_user_profiles = require_permission(Permission.EDIT_USER_PROFILES)
require_lock_users = require_permission(Permission.LOCK_USERS)
require_manage_user_roles = require_permission(Permission.MANAGE_USER_ROLES)

# Чаты
require_create_chats = require_permission(Permission.CREATE_CHATS)
require_send_messages = require_permission(Permission.SEND_MESSAGES)
require_delete_messages = require_permission(Permission.DELETE_MESSAGES)
require_moderate_chats = require_permission(Permission.MODERATE_CHATS)

# Отзывы
require_write_reviews = require_permission(Permission.WRITE_REVIEWS)
require_moderate_reviews = require_permission(Permission.MODERATE_REVIEWS)
require_respond_to_reviews = require_permission(Permission.RESPOND_TO_REVIEWS)

# Мерч
require_view_merch = require_permission(Permission.VIEW_MERCH)
require_manage_merch = require_permission(Permission.MANAGE_MERCH)

# Категории и теги
require_manage_categories = require_permission(Permission.MANAGE_CATEGORIES)
require_manage_places = require_permission(Permission.MANAGE_PLACES)
require_manage_vehicles = require_permission(Permission.MANAGE_VEHICLES)
require_manage_tools = require_permission(Permission.MANAGE_TOOLS)
require_manage_activities = require_permission(Permission.MANAGE_ACTIVITIES)

# Дополнительные разрешения
require_view_user_favorites = require_permission(Permission.VIEW_USER_FAVORITES)
require_manage_unlock_requests = require_permission(Permission.MANAGE_UNLOCK_REQUESTS)

# Комплексные разрешения
require_quest_management = require_any_permission({
    Permission.CREATE_QUESTS,
    Permission.EDIT_QUESTS,
    Permission.DELETE_QUESTS,
    Permission.MODERATE_QUESTS,
})

require_user_management = require_any_permission({
    Permission.EDIT_USER_PROFILES,
    Permission.LOCK_USERS,
    Permission.MANAGE_USER_ROLES,
})

require_content_moderation = require_any_permission({
    Permission.MODERATE_QUESTS,
    Permission.MODERATE_REVIEWS,
    Permission.MODERATE_CHATS,
})

# Администрирование
require_admin_panel = require_permission(Permission.VIEW_ADMIN_PANEL)
require_system_management = require_permission(Permission.MANAGE_SYSTEM_SETTINGS)


async def get_user_permissions_info(
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(create_session_depends),
) -> dict:
    """
    Dependency для получения информации о разрешениях пользователя.
    Полезно для фронтенда чтобы показать/скрыть элементы интерфейса.
    
    Returns:
        Словарь с информацией о разрешениях
    """
    from core.authorization.permissions import get_user_permissions, Role
    
    user_permissions = get_user_permissions(user)
    
    return {
        "user_id": str(user.id),
        "role": user.role,
        "role_name": Role(user.role).name if user.role in [r.value for r in Role] else "UNKNOWN",
        "is_active": user.is_active,
        "is_verified": user.is_verified,
        "can_edit_quests": user.can_edit_quests,
        "can_lock_users": user.can_lock_users,
        "permissions": [p.value for p in sorted(user_permissions, key=lambda x: x.value)],
        "permission_count": len(user_permissions),
    }


def check_resource_ownership(resource_user_id, current_user: User) -> bool:
    """
    Проверяет является ли пользователь владельцем ресурса.
    
    Args:
        resource_user_id: ID владельца ресурса
        current_user: Текущий пользователь
        
    Returns:
        True если пользователь владелец или имеет права на редактирование
    """
    # Владелец ресурса
    if str(current_user.id) == str(resource_user_id):
        return True
    
    # Администраторы и пользователи с правами редактирования профилей
    if user_has_permission(current_user, Permission.EDIT_USER_PROFILES):
        return True
        
    return False


def require_resource_ownership(resource_user_id_field: str = "user_id"):
    """
    Dependency factory для проверки владения ресурсом.
    
    Args:
        resource_user_id_field: Имя поля с ID владельца ресурса
        
    Returns:
        FastAPI dependency функция
    """
    async def dependency(
        request_data: dict,
        user: User = Depends(get_current_user)
    ) -> User:
        resource_user_id = request_data.get(resource_user_id_field)
        if not resource_user_id:
            raise PermissionDeniedHTTPError("Resource owner not specified")
            
        if not check_resource_ownership(resource_user_id, user):
            raise PermissionDeniedHTTPError("Access denied: not resource owner")
            
        return user
    
    return dependency 