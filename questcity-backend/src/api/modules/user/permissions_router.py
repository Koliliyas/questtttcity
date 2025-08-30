"""
API endpoints для работы с разрешениями пользователей.
"""
from typing import List, Dict, Any

from fastapi import APIRouter, Depends
from pydantic import BaseModel

from src.core.authorization.dependencies import get_user_permissions_info, require_authenticated
from src.db.models.user import User


# Схемы для API
class UserPermissionsResponse(BaseModel):
    """Ответ с информацией о разрешениях пользователя."""
    user_id: str
    role: int
    role_name: str
    is_active: bool
    is_verified: bool
    can_edit_quests: bool
    can_lock_users: bool
    permissions: List[str]
    permission_count: int


class PermissionCheckRequest(BaseModel):
    """Запрос на проверку разрешения."""
    permission: str


class PermissionCheckResponse(BaseModel):
    """Ответ на проверку разрешения."""
    permission: str
    has_permission: bool
    reason: str


router = APIRouter(prefix="/permissions", tags=["permissions"])


@router.get("/me", response_model=UserPermissionsResponse)
async def get_my_permissions(
    permissions_info: Dict[str, Any] = Depends(get_user_permissions_info),
) -> UserPermissionsResponse:
    """
    Получить информацию о разрешениях текущего пользователя.
    
    Возвращает полную информацию о ролях, флагах и разрешениях пользователя.
    Полезно для фронтенда чтобы показать/скрыть элементы интерфейса.
    """
    return UserPermissionsResponse(**permissions_info)


@router.post("/check", response_model=PermissionCheckResponse)
async def check_permission(
    request: PermissionCheckRequest,
    user: User = Depends(require_authenticated),
) -> PermissionCheckResponse:
    """
    Проверить есть ли у пользователя конкретное разрешение.
    
    Args:
        request: Запрос с названием разрешения
        
    Returns:
        Результат проверки разрешения
    """
    from core.authorization.permissions import Permission, user_has_permission
    
    try:
        # Пытаемся найти разрешение по названию
        permission = Permission(request.permission)
        has_permission = user_has_permission(user, permission)
        
        if has_permission:
            reason = "Permission granted"
        else:
            if not user.is_active:
                reason = "User is not active"
            elif not user.is_verified and permission not in {Permission.VIEW_OWN_PROFILE, Permission.EDIT_OWN_PROFILE}:
                reason = "User is not verified"
            else:
                reason = "Insufficient privileges"
                
        return PermissionCheckResponse(
            permission=request.permission,
            has_permission=has_permission,
            reason=reason
        )
        
    except ValueError:
        return PermissionCheckResponse(
            permission=request.permission,
            has_permission=False,
            reason=f"Unknown permission: {request.permission}"
        )


@router.get("/available", response_model=List[Dict[str, str]])
async def get_available_permissions() -> List[Dict[str, str]]:
    """
    Получить список всех доступных разрешений в системе.
    
    Returns:
        Список разрешений с описанием
    """
    from core.authorization.permissions import Permission
    
    # Описания разрешений для API документации
    permission_descriptions = {
        Permission.VIEW_OWN_PROFILE: "Просмотр собственного профиля",
        Permission.EDIT_OWN_PROFILE: "Редактирование собственного профиля",
        Permission.VIEW_USERS: "Просмотр списка пользователей",
        Permission.EDIT_USER_PROFILES: "Редактирование профилей пользователей",
        Permission.LOCK_USERS: "Блокировка пользователей",
        Permission.UNLOCK_USERS: "Разблокировка пользователей",
        Permission.DELETE_USERS: "Удаление пользователей",
        Permission.MANAGE_USER_ROLES: "Управление ролями пользователей",
        Permission.VIEW_QUESTS: "Просмотр квестов",
        Permission.CREATE_QUESTS: "Создание квестов",
        Permission.EDIT_QUESTS: "Редактирование квестов",
        Permission.DELETE_QUESTS: "Удаление квестов",
        Permission.MODERATE_QUESTS: "Модерация квестов",
        Permission.MANAGE_CATEGORIES: "Управление категориями",
        Permission.MANAGE_PLACES: "Управление местами",
        Permission.MANAGE_VEHICLES: "Управление транспортом",
        Permission.MANAGE_TOOLS: "Управление инструментами",
        Permission.MANAGE_ACTIVITIES: "Управление активностями",
        Permission.CREATE_CHATS: "Создание чатов",
        Permission.SEND_MESSAGES: "Отправка сообщений",
        Permission.DELETE_MESSAGES: "Удаление сообщений",
        Permission.MODERATE_CHATS: "Модерация чатов",
        Permission.WRITE_REVIEWS: "Написание отзывов",
        Permission.MODERATE_REVIEWS: "Модерация отзывов",
        Permission.RESPOND_TO_REVIEWS: "Ответ на отзывы",
        Permission.VIEW_MERCH: "Просмотр мерча",
        Permission.MANAGE_MERCH: "Управление мерчем",
        Permission.MANAGE_FRIENDS: "Управление друзьями",
        Permission.SEND_FRIEND_REQUESTS: "Отправка заявок в друзья",
        Permission.MANAGE_FAVORITES: "Управление избранным",
        Permission.VIEW_ADMIN_PANEL: "Доступ к админ-панели",
        Permission.MANAGE_SYSTEM_SETTINGS: "Управление настройками системы",
        Permission.VIEW_LOGS: "Просмотр логов системы",
        Permission.MANAGE_BACKUPS: "Управление резервными копиями",
    }
    
    return [
        {
            "permission": permission.value,
            "description": permission_descriptions.get(permission, "Описание отсутствует"),
            "category": permission.value.split("_")[0].title()
        }
        for permission in Permission
    ] 