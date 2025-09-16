from fastapi import APIRouter

from api.v1.router import router as v1_router

router_v1 = APIRouter(
    prefix="/v1",
)

router_v1.include_router(router=v1_router)
