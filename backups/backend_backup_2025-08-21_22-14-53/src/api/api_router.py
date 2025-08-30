from fastapi import APIRouter

from src.api.health import router as health_router
from src.api.v1.router import router as v1_router

router_v1 = APIRouter(
    prefix="/v1",
)

# Добавляем health endpoints (без версии для совместимости с load balancers)
router_v1.include_router(router=health_router)

# Добавляем versioned API
router_v1.include_router(router=v1_router)
