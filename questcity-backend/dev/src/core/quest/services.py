from typing import Type, Union

from botocore.exceptions import ClientError
from fastapi_pagination import Params
from result import Err, Ok

from api.modules.quest.schemas.point import Tool
from api.modules.quest.schemas.quest import (ItemWithImageUpdateSchema,
                                             MainPreferences, PriceSettings,
                                             QuestAsItem)
from core.exceptions import S3ServiceClientException
from core.merch.dto import MerchCreateDTO, MerchUpdateDTO
from core.merch.service import MerchService
from core.quest.dto import (BaseReviewDTO, BaseReviewResponseDTO,
                            ItemCreateDTO, ItemWithImageDTO, PointCreateDTO,
                            PointUpdateDTO, QuestCreateDTO, QuestUpdateDTO)
from core.quest.exceptions import (ActivityNotFoundException,
                                   CategoryNotFoundException,
                                   InsufficientPlaceForDeleteException,
                                   InsufficientPointForDeleteException,
                                   PlaceNotFoundException,
                                   PlacePreferenceNotFoundException,
                                   PointNotFoundException,
                                   QuestItemAlreadyExistsException,
                                   QuestNotFoundException,
                                   QuestWithNameAlreadyExistsException,
                                   ReviewAlreadyExists, ReviewNotFound,
                                   ReviewResponseAlreadyExists,
                                   ToolNotFoundException,
                                   VehicleNotFoundException)
from core.quest.repositories import (CategoryRepository,
                                     PlacePreferenceRepository,
                                     PlaceRepository, PointRepository,
                                     QuestRepository, ReviewRepository,
                                     ToolRepository, TypeRepository,
                                     VehicleRepository)
from core.repositories import S3Repository
from core.services import BaseService
from db.models.quest.quest import Category, Place, Quest, Review, Vehicle


class ItemService(BaseService):
    ITEMS_ERRORS: dict[str, Exception] = {
        "categories": CategoryNotFoundException,
        "vehicles": VehicleNotFoundException,
        "places": PlaceNotFoundException,
        "activity": ActivityNotFoundException,  # Исправлено: "types" -> "activity"
        "tools": ToolNotFoundException,
    }

    def __init__(
        self,
        place_repository: PlaceRepository,
        category_repository: CategoryRepository,
        vehicle_repository: VehicleRepository,
        type_repository: TypeRepository,
        tool_repository: ToolRepository,
        s3: S3Repository,
    ):
        super().__init__(s3)
        self._items_repositories: dict[
            str,
            Union[
                PlaceRepository,
                CategoryRepository,
                VehicleRepository,
                TypeRepository,
                ToolRepository,
                S3Repository,
            ],
        ] = {
            "places": place_repository,
            "categories": category_repository,
            "vehicles": vehicle_repository,
            "activity": type_repository,  # Исправлено: "types" -> "activity"
            "tools": tool_repository,
        }

    async def get_items(self, repository: str):
        return await self._items_repositories[repository].get_all()

    async def create_item(
        self,
        service_name: str,
        dto: ItemCreateDTO | ItemWithImageDTO,
    ):
        if await self._items_repositories[service_name].get_by_attr(
            "name",
            dto.name,
        ):
            return Err(QuestItemAlreadyExistsException())

        if isinstance(dto, ItemWithImageDTO):
            dto.image = await self._s3.upload_file(
                f"quests/{service_name}",
                dto.image,
            )
            self.temporary_files_links.append(dto.image)

        return Ok(await self._items_repositories[service_name].create(dto))

    async def update_item(
        self,
        item_name: str,
        data: ItemWithImageUpdateSchema,
        oid: int,
    ):
        try:
            item_obj = await self.check_exist_item(item_name, oid)
        except (
            CategoryNotFoundException,
            VehicleNotFoundException,
            PlaceNotFoundException,
            ActivityNotFoundException,
            ToolNotFoundException,
        ) as exception:
            return Err(exception)

        if "image" in item_obj.__table__.columns:
            if data.image is not None:
                try:
                    data.image = await self._s3.upload_file(
                        f"quests/{item_name}",
                        data.image,
                    )
                except ClientError:
                    return Err(S3ServiceClientException())

                self.temporary_files_links.append(data.image)
                self.old_files_links.append(item_obj.image)

        updated_item = await self._items_repositories[item_name].update_category(
            obj=item_obj,
            data=data,
        )

        return Ok(updated_item)

    async def check_exist_item(
        self,
        item_name: str,
        item_id: int,
    ) -> Place | Category | Vehicle | Type | Tool:
        item_obj = await self._items_repositories[item_name].get_by_oid(item_id)

        if item_obj is None:
            raise self.ITEMS_ERRORS[item_name]

        return item_obj


class QuestService(BaseService):
    def __init__(
        self,
        merch_service: MerchService,
        point_repository: PointRepository,
        place_preference_repository: PlacePreferenceRepository,
        quest_repository: QuestRepository,
        items_service: ItemService,
        s3: S3Repository,
    ) -> None:
        super().__init__(s3)
        self._quest_repository = quest_repository
        self._merch_service = merch_service
        self._point_repository = point_repository
        self._place_preference_repository = place_preference_repository
        self._items_service = items_service

    async def get_all_quests(self) -> list[QuestAsItem]:
        return [
            QuestAsItem(
                id=item.id,
                name=item.name,
                image=item.image,
                rating=item.rating,
                main_preferences=MainPreferences(
                    category_id=item.category_id,
                    group=item.group,
                    vehicle_id=item.vehicle_id,
                    price=PriceSettings(
                        is_subscription=item.is_subscription,
                        pay_extra=item.pay_extra,
                    ),
                    timeframe=item.timeframe,
                    level=item.level,
                    milage=item.milage,
                    place_id=item.place_id,
                ),
            )
            for item in await self._quest_repository.get_all()
        ]

    async def get_quest(
        self,
        oid: int,
        me: bool = False,
    ) -> Err[QuestNotFoundException] | Quest:
        quest = None

        if me:
            quest = await self._quest_repository.get_current_quest(oid)
        else:
            quest = await self._quest_repository.get_quest(oid)

        if quest is None:
            return Err(QuestNotFoundException())

        return quest

    async def create_quest(
        self,
        quest_dto: QuestCreateDTO,
        merch_dtos: list[MerchCreateDTO],
        points_dtos: list[PointCreateDTO],
    ):
        if await self._quest_repository.get_by_attr("name", quest_dto.name) is not None:
            return Err(QuestWithNameAlreadyExistsException())

        if isinstance(
            check_result := await self._check_quest_dto(quest_dto),
            Err,
        ):
            return check_result

        if isinstance(
            check_result := await self._check_points_dtos(points_dtos),
            Err,
        ):
            return check_result

        try:
            quest_dto.image = await self._s3.upload_file(
                "quests",
                quest_dto.image,
            )
            self.temporary_files_links.append(quest_dto.image)
            quest_dto.mentor_preference = await self._s3.upload_file(
                "quests",
                quest_dto.mentor_preference,
            )
            self.temporary_files_links.append(quest_dto.mentor_preference)

        except ClientError:
            return Err(S3ServiceClientException())

        quest = await self._quest_repository.create(quest_dto)

        for merch_dto in merch_dtos:
            merch_dto.quest_id = quest.id
            result = await self._merch_service.create_merch(dto=merch_dto)

            if isinstance(result, Err):
                return result

        for point_dto in points_dtos:
            point_dto.quest_id = quest.id
            result = await self._create_point(point_dto)

            if isinstance(result, Err):
                return result

        return Ok(quest)

    async def update_quest(
        self,
        quest_dto: QuestUpdateDTO,
        merchs_dtos: list[MerchUpdateDTO],
        points_dtos: list[PointUpdateDTO],
    ):
        quest_obj = await self._quest_repository.get_quest_before_update(quest_dto.id)

        if quest_obj is None:
            return Err(QuestNotFoundException())

        if (
            quest_dto.name != quest_obj.name
            and await self._quest_repository.get_by_attr("name", quest_dto.name)
            is not None
        ):
            return Err(QuestWithNameAlreadyExistsException())

        if isinstance(
            check_result := await self._check_quest_dto(quest_dto),
            Err,
        ):
            return check_result

        if isinstance(
            check_result := await self._check_points_dtos(points_dtos),
            Err,
        ):
            return check_result

        try:
            if quest_dto.image != quest_obj.image:
                if quest_dto.image is None:
                    quest_dto.image = quest_obj.image

                else:
                    quest_dto.image = await self._s3.upload_file(
                        "quests",
                        quest_dto.image,
                    )
                    self.temporary_files_links.append(quest_dto.image)
                    self.old_files_links.append(quest_obj.image)

            if quest_dto.mentor_preference != quest_obj.mentor_preference:
                if quest_dto.mentor_preference is None:
                    quest_dto.mentor_preference = quest_obj.mentor_preference

                else:
                    quest_dto.mentor_preference = await self._s3.upload_file(
                        "quests",
                        quest_dto.mentor_preference,
                    )
                    self.temporary_files_links.append(quest_dto.mentor_preference)
                    self.old_files_links.append(quest_obj.image)

        except ClientError:
            return Err(S3ServiceClientException())

        updated_quest_obj = await self._quest_repository.update(
            instance=quest_obj,
            dto=quest_dto,
        )

        for dto in merchs_dtos:
            result = await self._merch_service.update_merch(dto)

            if isinstance(result, Err):
                return result

        for dto in points_dtos:
            result = await self._update_point(dto=dto, quest_obj=quest_obj)

            if isinstance(result, Err):
                return result

        return Ok(updated_quest_obj)

    async def delete_point(self, oid: int):
        point = await self._point_repository.get_by_oid(oid)

        if point is None:
            return Err(PointNotFoundException())

        if not await self._point_repository.check_qty(point.quest_id):
            return Err(InsufficientPointForDeleteException())

        # TODO: Если ссылка на Tool?
        if point.file is not None:
            self.old_files_links.append(point.file)

        await self._point_repository.delete(point)

    async def delete_place_settings(self, oid: int):
        place = await self._place_preference_repository.get_by_oid(oid)

        if place is None:
            return Err(PlacePreferenceNotFoundException())

        if not await self._place_preference_repository.check_qty(place.point_id):
            return Err(InsufficientPlaceForDeleteException())

        await self._place_preference_repository.delete(place)

    async def _create_point(self, dto: PointCreateDTO):
        try:
            if dto.file is not None:
                dto.file = await self._s3.upload_file(
                    "quests/points",
                    dto.file,
                )
                self.temporary_files_links.append(dto.file)

        except ClientError:
            return Err(S3ServiceClientException())

        places = dto.places

        point = await self._point_repository.add_point(dto)

        for place_dto in places:
            place_dto.point_id = point.id
            await self._place_preference_repository.create(place_dto)

        return point

    async def _update_point(self, dto: PointUpdateDTO, quest_obj: Quest):
        if dto.id is not None:
            point = next(point for point in quest_obj.points if point.id == dto.id)

            if dto.file != point.file:
                if dto.file is None:
                    self.old_files_links.append(point.file)

                else:
                    dto.file = await self._s3.upload_file(
                        release="quest/points",
                        file_data=dto.file,
                    )

                    self.temporary_files_links.append(dto.file)
                    self.old_files_links.append(point.file)

            places_dtos = dto.places

            await self._point_repository.update_point(obj=point, dto=dto)

            for place_dto in places_dtos:
                if place_dto.id is not None:
                    place_obj = next(
                        place for place in point.places if place.id == place_dto.id
                    )
                    if place_obj is None:
                        return Err(PlacePreferenceNotFoundException())

                    await self._place_preference_repository.update(
                        instance=place_obj,
                        dto=place_dto,
                    )

                else:
                    await self._place_preference_repository.create(place_dto)

        else:
            return await self._create_point(dto)

    async def _check_quest_dto(self, dto: QuestCreateDTO | QuestUpdateDTO):
        try:
            await self._items_service.check_exist_item(
                "categories",
                dto.category_id,
            )
            await self._items_service.check_exist_item(
                "vehicles",
                dto.vehicle_id,
            )
            await self._items_service.check_exist_item(
                "places",
                dto.place_id,
            )
        except (
            CategoryNotFoundException,
            VehicleNotFoundException,
            PlaceNotFoundException,
        ) as exception:
            return Err(exception)

    async def _check_points_dtos(
        self,
        dtos: list[PointCreateDTO] | list[PointUpdateDTO],
    ):
        for dto in dtos:
            if isinstance(dto, PointUpdateDTO) and dto.id is not None:
                if await self._point_repository.get_by_oid(dto.id) is None:
                    return Err(PointNotFoundException())

            try:
                await self._items_service.check_exist_item(
                    "activity",  # Исправлено: "types" -> "activity"
                    dto.type_id,
                )

                if dto.tool_id is not None:
                    await self._items_service.check_exist_item(
                        "tools",
                        dto.tool_id,
                    )

            except (
                ActivityNotFoundException,
                ToolNotFoundException,
            ) as exception:
                return Err(exception)


class ReviewService:
    def __init__(
        self, review_repository: ReviewRepository, quest_repository: QuestRepository
    ):
        self._review_repository = review_repository
        self._quest_repository = quest_repository

    async def create(self, dto: BaseReviewDTO):
        if await self._quest_repository.get_by_oid(dto.quest_id) is None:
            return Err(QuestNotFoundException())

        if await self._review_repository.is_exists(
            Review.user_id == dto.user_id, Review.quest_id == dto.quest_id
        ):
            return Err(ReviewAlreadyExists())

        await self._review_repository.create(dto=dto)

        return Ok(1)

    async def get_all(self, quest_id: int, params: Params):
        return await self._review_repository.get_all(quest_id, params)

    async def create_response(self, dto: BaseReviewResponseDTO):
        if not await self._review_repository.is_exists(Review.id == dto.review_id):
            return Err(ReviewNotFound())

        if await self._review_repository.is_has_response(
            review_id=dto.review_id, user_id=dto.user_id
        ):
            return Err(ReviewResponseAlreadyExists())

        await self._review_repository.create_response(dto)

        return Ok(1)
