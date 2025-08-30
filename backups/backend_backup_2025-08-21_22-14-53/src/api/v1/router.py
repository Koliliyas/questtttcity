from fastapi import APIRouter

from src.api.modules.authentication.router import router as auth_router
from src.api.modules.chat.router import router as chat_router
from src.api.modules.favorite.router import router as favorite_router
from src.api.modules.friend.router import router as friend_router
from src.api.modules.friend_request.router import router as friend_request_router
from src.api.modules.merch.router import router as merch_router
from src.api.modules.profile.router import router as profile_router
from src.api.modules.quest.router import router as quest_router
from src.api.modules.reviews.router import router as review_router
from src.api.modules.unlock_request.router import router as unlock_request_router
from src.api.modules.user.router import router as user_router
from src.api.modules.user.permissions_router import router as permissions_router

router = APIRouter()

router.include_router(router=auth_router)
router.include_router(router=user_router)
router.include_router(router=permissions_router)
router.include_router(router=unlock_request_router)
router.include_router(router=quest_router, prefix="/quests", tags=["Quests"])
router.include_router(
    router=friend_router,
    prefix="/friends",
    tags=["Friends"],
)
router.include_router(
    router=friend_request_router,
    prefix="/friend-requests",
    tags=["Friend Requests"],
)
router.include_router(router=chat_router, prefix="/chats", tags=["Chats"])
router.include_router(router=profile_router)
router.include_router(router=merch_router, prefix="/merch", tags=["Merch"])
router.include_router(router=review_router)
router.include_router(router=favorite_router)
