from aioinject import Injected
from aioinject.ext.fastapi import inject
from fastapi import APIRouter, Depends, status
from result import Err, Ok

from api.modules.quest.responses import (create_activity_responses,
                                         create_category_responses,
                                         create_place_responses,
                                         create_quest_responses,
                                         create_tool_responses,
                                         create_vehicle_responses,
                                         get_all_quests_responses,
                                         get_quest_responses,
                                         update_category_responses,
                                         update_quest_responses)
from api.modules.quest.schemas.point import (FileReadSettings, PlaceModel,
                                             PlaceSettings,
                                             PointReadForCurrentQuestSchema,
                                             PointReadSchema, PointType)
from api.modules.quest.schemas.quest import (Credits, CurrentQuestSchema,
                                             ItemReadSchema, ItemRequestSchema,
                                             ItemWithImageRead,
                                             ItemWithImageRequestSchema,
                                             ItemWithImageUpdateSchema,
                                             MainPreferences, MerchReadSchema,
                                             PriceSettings, QuestAsItem,
                                             QuestCreteSchema, QuestReadSchema,
                                             QuestUpdateRequestSchema)
from api.modules.quest.utils import exceptions_mapper
from core.authentication.dependencies import get_user_with_role
from core.merch.dto import MerchCreateDTO, MerchUpdateDTO
from core.merch.service import MerchService
from core.quest.dto import (ItemCreateDTO, ItemWithImageDTO, PlaceCreateDTO,
                            PlaceUpdateDTO, PointCreateDTO, PointUpdateDTO,
                            QuestCreateDTO, QuestUpdateDTO)
from core.quest.services import ItemService, QuestService
from db.models import User

router = APIRouter()


@router.get("/", response_model=list[QuestAsItem], responses=get_all_quests_responses)
@inject
async def get_all_quests(
    quest_service: Injected[QuestService],
    user: User = Depends(get_user_with_role("user")),
) -> list[QuestAsItem]:
    return await quest_service.get_all_quests()


@router.get(
    "/get-quest/{id}",
    status_code=status.HTTP_200_OK,
    response_model=QuestReadSchema,
    responses=get_quest_responses,
)
@inject
async def get_quest(
    id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(get_user_with_role("user")),
):
    quest = await quest_service.get_quest(id)

    if isinstance(quest, Err):
        await exceptions_mapper(quest.err_value, quest_service)

    return QuestReadSchema(
        name=quest.name,
        image=quest.image,
        merch=MerchReadSchema.model_validate_list(quest.merch),
        credits=Credits(
            auto=quest.auto_accrual,
            cost=quest.cost,
            reward=quest.reward,
        ),
        main_preferences=MainPreferences(
            category_id=quest.category_id,
            group=quest.group,
            vehicle_id=quest.vehicle_id,
            price=PriceSettings(
                is_subscription=quest.is_subscription,
                pay_extra=quest.pay_extra,
            ),
            timeframe=quest.timeframe,
            level=quest.level,
            milage=quest.milage,
            place_id=quest.place_id,
        ),
        points=[
            PointReadSchema(
                name_of_location=point.name_of_location,
                order=point.order,
                description=point.description,
                places=PlaceModel.model_validate_list(point.places),
            )
            for point in quest.points
        ],
    )


@router.get(
    "/me/{id}",
    response_model=CurrentQuestSchema,
    responses=get_quest_responses,
)
@inject
async def get_current_quest(
    id: int,
    quest_service: Injected[QuestService],
    user: User = Depends(get_user_with_role("user")),
):
    quest = await quest_service.get_quest(id, True)
    if isinstance(quest, Err):
        await exceptions_mapper(quest.err_value, quest_service)

    return CurrentQuestSchema(
        mentor_preferences=quest.mentor_preference,
        points=[
            PointReadForCurrentQuestSchema(
                name_of_location=point.name_of_location,
                description=point.description,
                order=point.order,
                type=PointType.model_validate(point),
                tool_id=point.tool_id,
                places=PlaceSettings.model_validate_list(point.places),
                files=FileReadSettings.model_validate(point) if point.file else None,
            )
            for point in quest.points
        ],
    )


@router.patch(
    "/update-quest/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=update_quest_responses,
)
@inject
async def update_quest(
    id: int,
    quest_data: QuestUpdateRequestSchema,
    quest_service: Injected[QuestService],
    merch_service: Injected[MerchService],
    user: User = Depends(get_user_with_role("admin")),
) -> None:
    quest_dto = QuestUpdateDTO(
        id=id,
        name=quest_data.name,
        description=quest_data.description,
        image=quest_data.image,
        mentor_preference=quest_data.mentor_preferences,
        auto_accrual=quest_data.credits.auto,
        cost=quest_data.credits.cost,
        reward=quest_data.credits.reward,
        is_subscription=quest_data.main_preferences.price.is_subscription,
        pay_extra=quest_data.main_preferences.price.pay_extra,
        level=quest_data.main_preferences.level,
        milage=quest_data.main_preferences.milage,
        category_id=quest_data.main_preferences.category_id,
        vehicle_id=quest_data.main_preferences.vehicle_id,
        place_id=quest_data.main_preferences.place_id,
        group=quest_data.main_preferences.group,
        timeframe=quest_data.main_preferences.timeframe,
    )

    merchs_dtos = []
    for merch_data in quest_data.merch:
        if merch_data.is_delete:
            continue

        merchs_dtos.append(
            MerchUpdateDTO(
                id=merch_data.id,
                description=merch_data.description,
                price=merch_data.price,
                image=merch_data.image,
                quest_id=id,
            )
        )

    points_dtos = []
    for point_data in quest_data.points:
        if point_data.is_delete:
            continue

        point_dto = PointUpdateDTO(
            id=point_data.id,
            name_of_location=point_data.name_of_location,
            description=point_data.description,
            order=point_data.order,
            type_id=point_data.type.type_id,
            type_photo=point_data.type.type_photo,
            type_code=point_data.type.type_code,
            type_word=point_data.type.type_word,
            tool_id=point_data.tool_id,
            file=point_data.files.file if point_data.files is not None else None,
            is_divide=point_data.files.is_divide
            if point_data.files is not None
            else None,
            quest_id=id,
            places=[],
        )

        for place_data in point_data.places:
            if place_data.is_delete:
                continue

            point_dto.places.append(
                PlaceUpdateDTO(
                    id=place_data.id,
                    part=place_data.part,
                    longitude=place_data.longitude,
                    latitude=place_data.latitude,
                    detections_radius=place_data.detections_radius,
                    point_id=point_data.id,
                    height=place_data.height,
                    interaction_inaccuracy=place_data.interaction_inaccuracy,
                    random_occurrence=place_data.random_occurrence,
                )
            )

        if len(point_dto.places) == 1:
            point_dto.places[0].part = 1
            point_dto.is_divide = False

        points_dtos.append(point_dto)

    result = await quest_service.update_quest(
        quest_dto=quest_dto,
        merchs_dtos=merchs_dtos,
        points_dtos=points_dtos,
    )

    if isinstance(result, Ok):
        # FIXME: Refactoring move to quest_service
        for merch in quest_data.merch:
            if merch.is_delete:
                error_or_nothing = await merch_service.delete_merch(merch.id)

                if isinstance(error_or_nothing, Err):
                    await exceptions_mapper(
                        error_or_nothing.err_value,
                        merch_service,
                        quest_service,
                    )

        for point in quest_data.points:
            if point.is_delete:
                error_or_nothing = await quest_service.delete_point(point.id)

                if isinstance(error_or_nothing, Err):
                    await exceptions_mapper(
                        error_or_nothing.err_value,
                        quest_service,
                        merch_service,
                    )

                continue

            for place in point.places:
                if place.is_delete:
                    error_or_nothing = await quest_service.delete_place_settings(
                        place.id
                    )

                    if isinstance(error_or_nothing, Err):
                        await exceptions_mapper(
                            error_or_nothing.err_value,
                            quest_service,
                            merch_service,
                        )

        if quest_service.old_files_links:
            await quest_service.clear_old_files_after()

        if merch_service.old_files_links:
            await merch_service.clear_old_files_after()

    else:
        await exceptions_mapper(result.err_value, quest_service, merch_service)


@router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    responses=create_quest_responses,
)
@inject
async def create_quest(
    quest_data: QuestCreteSchema,
    quest_service: Injected[QuestService],
    merch_service: Injected[MerchService],
    user: User = Depends(get_user_with_role("admin")),
) -> None:
    quest_dto = QuestCreateDTO(
        name=quest_data.name,
        description=quest_data.description,
        image=quest_data.image,
        mentor_preference=quest_data.mentor_preferences,
        auto_accrual=quest_data.credits.auto,
        cost=quest_data.credits.cost,
        reward=quest_data.credits.reward,
        group=quest_data.main_preferences.group,
        is_subscription=quest_data.main_preferences.price.is_subscription,
        pay_extra=quest_data.main_preferences.price.pay_extra,
        timeframe=quest_data.main_preferences.timeframe,
        level=quest_data.main_preferences.level,
        milage=quest_data.main_preferences.milage,
        category_id=quest_data.main_preferences.category_id,
        vehicle_id=quest_data.main_preferences.vehicle_id,
        place_id=quest_data.main_preferences.place_id,
    )

    merchs_dtos = [
        MerchCreateDTO(
            description=merch.description,
            price=merch.price,
            image=merch.image,
        )
        for merch in quest_data.merch
    ]

    points_dtos = [
        PointCreateDTO(
            name_of_location=point.name_of_location,
            description=point.description,
            order=point.order,
            type_id=point.type.type_id,
            type_photo=point.type.type_photo,
            type_code=point.type.type_code,
            type_word=point.type.type_word,
            tool_id=point.tool_id,
            file=point.files.file if point.files is not None else None,
            is_divide=point.files.is_divide if point.files is not None else None,
            places=[
                PlaceCreateDTO(
                    part=place.part,
                    longitude=place.longitude,
                    latitude=place.latitude,
                    detections_radius=place.detections_radius,
                    height=place.height,
                    random_occurrence=place.random_occurrence,
                    interaction_inaccuracy=place.interaction_inaccuracy,
                )
                for place in point.places
            ],
        )
        for point in quest_data.points
    ]

    result = await quest_service.create_quest(
        quest_dto,
        merchs_dtos,
        points_dtos,
    )

    if isinstance(result, Err):
        await exceptions_mapper(result.err_value, quest_service, merch_service)


@router.get("/categories", response_model=list[ItemWithImageRead])
@inject
async def get_categories(item_service: Injected[ItemService]):
    return await item_service.get_items("categories")


@router.post(
    "/categories",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=create_category_responses,
)
@inject
async def create_category(
    category_data: ItemWithImageRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(get_user_with_role("admin")),
) -> None:
    result = await item_service.create_item(
        "categories",
        ItemWithImageDTO(
            name=category_data.name,
            image=category_data.image,
        ),
    )
    if isinstance(result, Err):
        await exceptions_mapper(result.err_value, item_service)


@router.patch(
    "/categories/{id}",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=update_category_responses,
)
@inject
async def update_category(
    id: int,
    request_data: ItemWithImageUpdateSchema,
    item_service: Injected[ItemService],
    user: User = Depends(get_user_with_role("admin")),
):
    result = await item_service.update_item(
        "categories",
        request_data,
        id,
    )

    if isinstance(result, Err):
        await exceptions_mapper(result.err_value, item_service)

    else:
        await item_service.clear_old_files_after()


@router.get("/places", response_model=list[ItemReadSchema])
@inject
async def get_places(item_service: Injected[ItemService]):
    return await item_service.get_items("places")


@router.post(
    "/places",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=create_place_responses,
)
@inject
async def create_place(
    place_data: ItemRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(get_user_with_role("admin")),
) -> None:
    result = await item_service.create_item(
        "places",
        ItemCreateDTO(**place_data.model_dump()),
    )
    if isinstance(result, Err):
        await exceptions_mapper(result.err_value, item_service)


@router.get("/vehicles", response_model=list[ItemReadSchema])
@inject
async def get_vehicles(item_service: Injected[ItemService]):
    return await item_service.get_items("vehicles")


@router.post(
    "/vehicles",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=create_vehicle_responses,
)
@inject
async def create_vehicle(
    vehicle_data: ItemRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(get_user_with_role("admin")),
) -> None:
    result = await item_service.create_item(
        "vehicles",
        ItemCreateDTO(**vehicle_data.model_dump()),
    )
    if isinstance(result, Err):
        await exceptions_mapper(result.err_value, item_service)


@router.get("/types", response_model=list[ItemReadSchema])
@inject
async def get_point_types(item_service: Injected[ItemService]):
    return await item_service.get_items("types")


@router.post(
    "/types",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=create_activity_responses,
)
@inject
async def create_point_type(
    type_data: ItemRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(get_user_with_role("admin")),
) -> None:
    result = await item_service.create_item(
        "types",
        ItemCreateDTO(**type_data.model_dump()),
    )
    if isinstance(result, Err):
        await exceptions_mapper(result.err_value, item_service)


@router.get("/tools", response_model=list[ItemWithImageRead])
@inject
async def get_points_tools(item_service: Injected[ItemService]):
    return await item_service.get_items("tools")


@router.post(
    "/tools",
    status_code=status.HTTP_204_NO_CONTENT,
    responses=create_tool_responses,
)
@inject
async def create_point_tool(
    tool_data: ItemWithImageRequestSchema,
    item_service: Injected[ItemService],
    user: User = Depends(get_user_with_role("admin")),
) -> None:
    result = await item_service.create_item(
        "tools",
        ItemWithImageDTO(
            name=tool_data.name,
            image=tool_data.image,
        ),
    )
    if isinstance(result, Err):
        await exceptions_mapper(result.err_value, item_service)
