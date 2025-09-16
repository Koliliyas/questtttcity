import os
from typing import Type, Union, Any

from botocore.exceptions import ClientError
from fastapi_pagination import Params
from result import Err, Ok
from sqlalchemy import text

from src.api.modules.quest.schemas.point import Tool
from src.api.modules.quest.schemas.quest import (ItemWithImageUpdateSchema,
                                             MainPreferences, PriceSettings,
                                             QuestAsItem)
from src.core.exceptions import S3ServiceClientException
from src.core.merch.dto import MerchCreateDTO, MerchUpdateDTO
from src.core.merch.service import MerchService
from src.core.quest.dto import (BaseReviewDTO, BaseReviewResponseDTO,
                            ItemCreateDTO, ItemWithImageDTO, PointCreateDTO,
                            PointUpdateDTO, QuestCreateDTO, QuestUpdateDTO)
from src.core.quest.exceptions import (ActivityNotFoundException,
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
from src.core.quest.repositories import (CategoryRepository,
                                     PlacePreferenceRepository,
                                     PlaceRepository, PointRepository,
                                     QuestRepository, ReviewRepository,
                                     ToolRepository, TypeRepository,
                                     VehicleRepository)
from src.core.repositories import S3Repository
from src.core.services import BaseService
from src.db.models.quest.quest import Category, Place, Quest, Review, Vehicle
from src.core.di.modules.default import MockS3Repository


class ItemService(BaseService):
    ITEMS_ERRORS: dict[str, Exception] = {
        "categories": CategoryNotFoundException,
        "vehicles": VehicleNotFoundException,
        "place": PlaceNotFoundException,
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
        # Используем мок S3 для разработки
        if os.getenv("ENVIRONMENT", "development") != "production":
            s3 = MockS3Repository()
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
            "place": place_repository,
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
        import logging
        logger = logging.getLogger(__name__)
        
        logger.info(f"check_exist_item - Проверяем {item_name} с ID = {item_id}")
        
        repository = self._items_repositories[item_name]
        logger.info(f"check_exist_item - Репозиторий: {type(repository).__name__}")
        
        item_obj = await repository.get_by_oid(item_id)
        logger.info(f"check_exist_item - Результат: {item_obj}")

        if item_obj is None:
            logger.error(f"check_exist_item - {item_name} с ID = {item_id} не найден!")
            raise self.ITEMS_ERRORS[item_name]

        logger.info(f"check_exist_item - {item_name} с ID = {item_id} найден: {item_obj}")
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
        # Используем мок S3 для разработки
        if os.getenv("ENVIRONMENT", "development") != "production":
            s3 = MockS3Repository()
        super().__init__(s3)
        self._quest_repository = quest_repository
        self._merch_service = merch_service
        self._point_repository = point_repository
        self._place_preference_repository = place_preference_repository
        self._items_service = items_service
        # Хранилище для mock изображений в разработке (hash -> base64)
        self._mock_images = {}

    async def get_all_quests(self) -> list[QuestAsItem]:
        return [
            QuestAsItem(
                id=item.id,
                name=item.name,
                image=item.image,
                rating=item.rating,
                main_preferences=MainPreferences(
                    category_id=item.category_id,
                    vehicle_id=item.vehicle_id,
                    place_id=item.place_id,
                    group=item.group,
                    timeframe=item.timeframe,
                    level=item.level,
                    mileage=item.milage,
                    types=[],  # Пустой список для совместимости
                    places=[],  # Пустой список для совместимости
                    vehicles=[],  # Пустой список для совместимости
                    tools=[],  # Пустой список для совместимости
                ),
            )
            for item in await self._quest_repository.get_all()
        ]

    async def get_quest(
        self,
        oid: int,
        me: bool = False,
    ) -> Err[QuestNotFoundException] | Ok[Quest]:
        quest = None

        if me:
            quest = await self._quest_repository.get_current_quest(oid)
        else:
            quest = await self._quest_repository.get_quest(oid)

        if quest is None:
            return Err(QuestNotFoundException())

        return Ok(quest)

    async def get_quest_by_id(self, quest_id: int) -> Err[QuestNotFoundException] | Ok[Quest]:
        """Получение квеста по ID. Обертка для get_quest для совместимости с роутером."""
        return await self.get_quest(quest_id, me=False)

    async def get_merch_list_by_quest_id(self, quest_id: int) -> list:
        """Получение списка мерча для квеста через MerchService."""
        try:
            # Используем существующий MerchService для получения мерча по quest_id
            # Но нужно добавить метод в MerchRepository для поиска по quest_id
            from sqlalchemy import select
            from src.db.models.merch import Merch
            
            print(f"DEBUG: get_merch_list_by_quest_id - Поиск мерча для quest_id={quest_id}")
            
            # Временно получаем через прямой запрос к базе
            async with self._quest_repository._session as session:
                result = await session.execute(
                    select(Merch).where(Merch.quest_id == quest_id)
                )
                merchs = result.scalars().all()
                
                print(f"  - Найдено мерча в БД: {len(merchs)}")
                for i, merch in enumerate(merchs):
                    print(f"  - merch[{i}]: id={merch.id}, description='{merch.description}', price={merch.price}")
                
                merch_list = [
                    {
                        "id": merch.id,
                        "description": merch.description,
                        "price": merch.price,
                        "image": merch.image
                    }
                    for merch in merchs
                ]
                
                print(f"  - Возвращаем мерча: {len(merch_list)}")
                return merch_list
        except Exception as e:
            print(f"ERROR: get_merch_list_by_quest_id - Ошибка: {e}")
            return []

    async def get_preferences_by_quest_id(self, quest_id: int) -> list:
        """Получение предпочтений для квеста (типов активности из точек)."""
        try:
            from sqlalchemy import select, distinct
            from db.models.quest.point import Point, Activity
            
            # Получаем уникальные типы активности из точек квеста
            async with self._quest_repository._session as session:
                result = await session.execute(
                    select(distinct(Activity.id), Activity.name)
                    .join(Point, Point.type_id == Activity.id)
                    .where(Point.quest_id == quest_id)
                )
                activities = result.all()
                
                return [
                    {"id": activity_id, "name": activity_name}
                    for activity_id, activity_name in activities
                ]
        except Exception:
            return []

    async def get_quest_points_list(self, quest_id: int) -> list:
        """Получение точек квеста через PointRepository."""
        try:
            from sqlalchemy import select
            from src.db.models.quest.point import Point, PlaceSettings
            
            # Получаем точки квеста со связанными местами
            async with self._quest_repository._session as session:
                result = await session.execute(
                    select(Point)
                    .where(Point.quest_id == quest_id)
                    .order_by(Point.order)
                )
                points = result.scalars().all()
                
                points_list = []
                for point in points:
                    # Получаем места для точки
                    places_result = await session.execute(
                        select(PlaceSettings).where(PlaceSettings.point_id == point.id)
                    )
                    places = places_result.scalars().all()
                    
                    point_data = {
                        "id": point.id,
                        "name": point.name_of_location,
                        "order": point.order,
                        "description": point.description,
                        "type_id": point.type_id,
                        "tool_id": point.tool_id,
                        "places": [
                            {
                                "latitude": place.latitude,
                                "longitude": place.longitude
                            }
                            for place in places
                        ]
                    }
                    
                    points_list.append(point_data)
                
                return points_list
        except Exception as e:
            print(f"ERROR: get_quest_points_list - Ошибка: {e}")
            import traceback
            print(f"ERROR: get_quest_points_list - Traceback: {traceback.format_exc()}")
            return []

    async def get_places_by_quest_id(self, quest_id: int) -> list:
        """Получение мест для квеста (из связи quest.place)."""
        try:
            from sqlalchemy import select
            from db.models.quest.quest import Place
            
            # Получаем место квеста
            async with self._quest_repository._session as session:
                result = await session.execute(
                    select(Place.id, Place.name)
                    .join(Quest, Quest.place_id == Place.id)
                    .where(Quest.id == quest_id)
                )
                place = result.first()
                
                if place:
                    return [{"id": place.id, "name": place.name}]
                
                return []
        except Exception:
            return []

    async def get_place_settings_by_quest_id(self, quest_id: int):
        """Получение настроек места для квеста."""
        try:
            from sqlalchemy import select
            from db.models.quest.quest import Place
            
            # Получаем место квеста
            async with self._quest_repository._session as session:
                result = await session.execute(
                    select(Place.id, Place.name, Quest.is_subscription)
                    .join(Quest, Quest.place_id == Place.id)
                    .where(Quest.id == quest_id)
                )
                row = result.first()
                
                if row:
                    place_id, place_name, is_subscription = row
                    
                    class MockType:
                        def __init__(self, value):
                            self.value = value
                    
                    class MockPlace:
                        def __init__(self, id, title):
                            self.id = id
                            self.title = title
                    
                    class MockPlaceSettings:
                        def __init__(self):
                            place_type = "subscription" if is_subscription else "default"
                            self.type = MockType(place_type)
                            self.place = MockPlace(place_id, place_name)
                    
                    return MockPlaceSettings()
                
        except Exception:
            pass
        
        # Fallback к дефолтным настройкам
        class MockType:
            def __init__(self, value):
                self.value = value
        
        class MockPlace:
            def __init__(self, id, title):
                self.id = id
                self.title = title
        
        class MockPlaceSettings:
            def __init__(self):
                self.type = MockType("default")
                self.place = MockPlace(1, "Место по умолчанию")
        
        return MockPlaceSettings()

    async def get_current_quest_by_user_id(self, user_id: int):
        """Заглушка: получение текущего квеста пользователя."""
        # TODO: Реализовать получение текущего квеста
        return Err(QuestNotFoundException())

    async def get_quest_progress_by_user_id(self, user_id: int, quest_id: int) -> int:
        """Заглушка: получение прогресса квеста пользователя."""
        # TODO: Реализовать получение прогресса
        return 0

    async def get_quest_points_for_current_quest(self, quest_id: int) -> list:
        """Заглушка: получение точек для текущего квеста."""
        # TODO: Реализовать получение точек текущего квеста
        return []

    async def update_point(self, point_dto) -> None:
        """Заглушка: обновление точки квеста."""
        # TODO: Реализовать обновление точки
        pass

    async def update_place_settings(self, place_dto) -> None:
        """Заглушка: обновление настроек места."""
        # TODO: Реализовать обновление настроек места  
        pass

    async def create_point(self, point_dto) -> None:
        """Заглушка: создание точки квеста."""
        # TODO: Реализовать создание точки
        pass

    async def create_place_settings(self, place_dto) -> None:
        """Заглушка: создание настроек места."""
        # TODO: Реализовать создание настроек места
        pass

    async def create_quest(
        self,
        quest_dto: QuestCreateDTO,
        merch_dtos: list[MerchCreateDTO],
        points_dtos: list[PointCreateDTO],
    ):
        print(f"DEBUG: create_quest - Начинаем создание квеста")
        print(f"  - quest_dto.name: '{quest_dto.name}'")
        print(f"  - merch_dtos length: {len(merch_dtos)}")
        print(f"  - points_dtos length: {len(points_dtos)}")
        
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
            # Обрабатываем изображения - всегда конвертируем в URL
            if quest_dto.image:
                if quest_dto.image.startswith("data:"):
                    # Base64 изображение - загружаем в S3 или создаем mock URL
                    if os.getenv("ENVIRONMENT", "development") != "production":
                        # В разработке создаем mock URL для base64
                        quest_dto.image = f"mock://quests/base64_{hash(quest_dto.image) % 1000000}.png"
                    else:
                        # В продакшене загружаем base64 в S3
                        quest_dto.image = await self._s3.upload_file(
                            "quests",
                            quest_dto.image,
                        )
                        self.temporary_files_links.append(quest_dto.image)
                elif not quest_dto.image.startswith(("http://", "https://", "mock://")):
                    # Путь к файлу - создаем mock URL или загружаем в S3
                    if os.getenv("ENVIRONMENT", "development") != "production":
                        quest_dto.image = f"mock://quests/{quest_dto.image}"
                    else:
                        quest_dto.image = await self._s3.upload_file(
                            "quests",
                            quest_dto.image,
                        )
                        self.temporary_files_links.append(quest_dto.image)
            
            # Обрабатываем mentor_preference аналогично
            if quest_dto.mentor_preference:
                # Проверяем, является ли это простой строкой (mentor_required/no_mentor)
                if quest_dto.mentor_preference in ["mentor_required", "no_mentor"]:
                    # Оставляем как есть - это не файл
                    pass
                elif quest_dto.mentor_preference.startswith("data:"):
                    if os.getenv("ENVIRONMENT", "development") != "production":
                        quest_dto.mentor_preference = f"mock://quests/mentor_{hash(quest_dto.mentor_preference) % 1000000}.png"
                    else:
                        quest_dto.mentor_preference = await self._s3.upload_file(
                            "quests",
                            quest_dto.mentor_preference,
                        )
                        self.temporary_files_links.append(quest_dto.mentor_preference)
                elif not quest_dto.mentor_preference.startswith(("http://", "https://", "mock://")):
                    if os.getenv("ENVIRONMENT", "development") != "production":
                        quest_dto.mentor_preference = f"mock://quests/{quest_dto.mentor_preference}"
                    else:
                        quest_dto.mentor_preference = await self._s3.upload_file(
                            "quests",
                            quest_dto.mentor_preference,
                        )
                        self.temporary_files_links.append(quest_dto.mentor_preference)

        except ClientError:
            return Err(S3ServiceClientException())

        quest = await self._quest_repository.create(quest_dto)
        
        print(f"DEBUG: create_quest - Квест создан с id={quest.id}")
        print(f"  - Обрабатываем merchandise: {len(merch_dtos)} элементов")

        for i, merch_dto in enumerate(merch_dtos):
            print(f"  - Создаем merch[{i}]: description='{merch_dto.description}', price={merch_dto.price}")
            merch_dto.quest_id = quest.id
            result = await self._merch_service.create_merch(dto=merch_dto)

            if isinstance(result, Err):
                print(f"ERROR: create_quest - Ошибка создания merch[{i}]: {result.err_value}")
                return result
            else:
                print(f"SUCCESS: create_quest - merch[{i}] создан успешно")

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

        # Проверяем уникальность имени, исключая текущий квест
        if quest_dto.name != quest_obj.name:
            existing_quest = await self._quest_repository.get_by_attr("name", quest_dto.name)
            if existing_quest is not None and existing_quest.id != quest_obj.id:
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
                    # Обрабатываем изображения - всегда конвертируем в URL
                    if quest_dto.image.startswith("data:"):
                        # Base64 изображение - загружаем в S3 или создаем mock URL
                        if os.getenv("ENVIRONMENT", "development") != "production":
                            # В разработке создаем mock URL для base64
                            quest_dto.image = f"mock://quests/base64_{hash(quest_dto.image) % 1000000}.png"
                        else:
                            # В продакшене загружаем base64 в S3
                            quest_dto.image = await self._s3.upload_file(
                                "quests",
                                quest_dto.image,
                            )
                            self.temporary_files_links.append(quest_dto.image)
                            self.old_files_links.append(quest_obj.image)
                    elif not quest_dto.image.startswith(("http://", "https://", "mock://")):
                        # Путь к файлу - создаем mock URL или загружаем в S3
                        if os.getenv("ENVIRONMENT", "development") != "production":
                            quest_dto.image = f"mock://quests/{quest_dto.image}"
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
                    # Обрабатываем mentor_preference аналогично
                    # Проверяем, является ли это простой строкой (mentor_required/no_mentor)
                    if quest_dto.mentor_preference in ["mentor_required", "no_mentor"]:
                        # Оставляем как есть - это не файл
                        pass
                    elif quest_dto.mentor_preference.startswith("data:"):
                        # Base64 изображение - загружаем в S3 или создаем mock URL
                        if os.getenv("ENVIRONMENT", "development") != "production":
                            # В разработке создаем mock URL для base64
                            quest_dto.mentor_preference = f"mock://quests/mentor_{hash(quest_dto.mentor_preference) % 1000000}.png"
                        else:
                            # В продакшене загружаем base64 в S3
                            quest_dto.mentor_preference = await self._s3.upload_file(
                                "quests",
                                quest_dto.mentor_preference,
                            )
                            self.temporary_files_links.append(quest_dto.mentor_preference)
                            self.old_files_links.append(quest_obj.mentor_preference)
                    elif not quest_dto.mentor_preference.startswith(("http://", "https://", "mock://")):
                        # Путь к файлу - создаем mock URL или загружаем в S3
                        if os.getenv("ENVIRONMENT", "development") != "production":
                            quest_dto.mentor_preference = f"mock://quests/{quest_dto.mentor_preference}"
                        else:
                            quest_dto.mentor_preference = await self._s3.upload_file(
                                "quests",
                                quest_dto.mentor_preference,
                            )
                            self.temporary_files_links.append(quest_dto.mentor_preference)
                            self.old_files_links.append(quest_obj.mentor_preference)

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
                # Обрабатываем файлы - всегда конвертируем в URL
                if dto.file.startswith("data:"):
                    # Base64 файл - загружаем в S3 или создаем mock URL
                    if os.getenv("ENVIRONMENT", "development") != "production":
                        # В разработке создаем mock URL для base64
                        dto.file = f"mock://quests/points/base64_{hash(dto.file) % 1000000}.png"
                    else:
                        # В продакшене загружаем base64 в S3
                        dto.file = await self._s3.upload_file(
                            "quests/points",
                            dto.file,
                        )
                        self.temporary_files_links.append(dto.file)
                elif not dto.file.startswith(("http://", "https://", "mock://")):
                    # Путь к файлу - создаем mock URL или загружаем в S3
                    if os.getenv("ENVIRONMENT", "development") != "production":
                        dto.file = f"mock://quests/points/{dto.file}"
                    else:
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
                    # Обрабатываем файлы - всегда конвертируем в URL
                    if dto.file.startswith("data:"):
                        # Base64 файл - загружаем в S3 или создаем mock URL
                        if os.getenv("ENVIRONMENT", "development") != "production":
                            # В разработке создаем mock URL для base64
                            dto.file = f"mock://quests/points/base64_{hash(dto.file) % 1000000}.png"
                        else:
                            # В продакшене загружаем base64 в S3
                            dto.file = await self._s3.upload_file(
                                "quests/points",
                                dto.file,
                            )
                            self.temporary_files_links.append(dto.file)
                            self.old_files_links.append(point.file)
                    elif not dto.file.startswith(("http://", "https://", "mock://")):
                        # Путь к файлу - создаем mock URL или загружаем в S3
                        if os.getenv("ENVIRONMENT", "development") != "production":
                            dto.file = f"mock://quests/points/{dto.file}"
                        else:
                            dto.file = await self._s3.upload_file(
                                "quests/points",
                                dto.file,
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
            # Создаем новую точку напрямую, так как dto это PointUpdateDTO
            try:
                if dto.file is not None:
                    # Используем мок S3 для разработки
                    if os.getenv("ENVIRONMENT", "development") != "production":
                        if not dto.file.startswith(("http://", "https://", "data:")):
                            # Если это не URL и не base64, то это путь к файлу - создаем mock URL
                            dto.file = f"mock://quests/points/{dto.file}"
                        # Если это base64 (data:), оставляем как есть
                    else:
                        if not dto.file.startswith("data:"):
                            dto.file = await self._s3.upload_file(
                                "quests/points",
                                dto.file,
                            )
                            self.temporary_files_links.append(dto.file)

            except ClientError:
                return Err(S3ServiceClientException())

            places = dto.places

            # Создаем PointCreateDTO из PointUpdateDTO
            point_create_dto = PointCreateDTO(
                name_of_location=dto.name_of_location,
                description=dto.description,
                order=dto.order,
                type_id=dto.type_id,
                places=dto.places,
                type_photo=dto.type_photo,
                type_code=dto.type_code,
                type_word=dto.type_word,
                tool_id=dto.tool_id,
                file=dto.file,
                is_divide=dto.is_divide,
            )

            point = await self._point_repository.add_point(point_create_dto)

            for place_dto in places:
                place_dto.point_id = point.id
                await self._place_preference_repository.create(place_dto)

            return point

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
                "place",
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
        import logging
        logger = logging.getLogger(__name__)
        
        logger.info(f"_check_points_dtos - Начинаем проверку {len(dtos)} точек")
        
        for i, dto in enumerate(dtos):
            logger.info(f"_check_points_dtos - Проверяем точку {i}: type_id = {dto.type_id}")
            
            if isinstance(dto, PointUpdateDTO) and dto.id is not None:
                if await self._point_repository.get_by_oid(dto.id) is None:
                    return Err(PointNotFoundException())

            try:
                logger.info(f"_check_points_dtos - Вызываем check_exist_item для activity с ID = {dto.type_id}")
                
                # ДОПОЛНИТЕЛЬНОЕ ЛОГИРОВАНИЕ: Проверяем TypeRepository напрямую
                logger.info(f"_check_points_dtos - Проверяем TypeRepository напрямую...")
                type_repo = TypeRepository(self._quest_repository._session)
                direct_result = await type_repo.get_by_oid(dto.type_id)
                logger.info(f"_check_points_dtos - TypeRepository.get_by_oid({dto.type_id}) = {direct_result}")
                
                await self._items_service.check_exist_item(
                    "activity",  # Исправлено: "types" -> "activity"
                    dto.type_id,
                )
                logger.info(f"_check_points_dtos - Активность с ID = {dto.type_id} найдена")

                if dto.tool_id is not None:
                    await self._items_service.check_exist_item(
                        "tools",
                        dto.tool_id,
                    )

            except (
                ActivityNotFoundException,
                ToolNotFoundException,
            ) as exception:
                print(f"ERROR: _check_points_dtos - Исключение при проверке точки {i}: {exception}")
                return Err(exception)

    async def delete_quest(self, quest_id: int) -> Err[QuestNotFoundException] | Ok[int]:
        """Удаление квеста по ID."""
        try:
            # Проверяем существование квеста
            quest = await self._quest_repository.get_by_oid(quest_id)
            if not quest:
                return Err(QuestNotFoundException())
            
            # 1. Получаем ID точек квеста для удаления place_settings
            print(f"Getting points for quest {quest_id}...")
            points_query = text("SELECT id FROM point WHERE quest_id = :quest_id")
            result = await self._quest_repository._session.execute(points_query, {"quest_id": quest_id})
            point_ids = [row[0] for row in result.fetchall()]
            
            if point_ids:
                # 2. Удаляем place_settings для всех точек квеста
                print(f"Deleting place_settings for {len(point_ids)} points...")
                place_settings_query = text("DELETE FROM place_settings WHERE point_id = ANY(:point_ids)")
                await self._quest_repository._session.execute(place_settings_query, {"point_ids": point_ids})
            
            # 3. Удаляем связанные точки (points)
            print(f"Deleting points for quest {quest_id}...")
            points_query = text("DELETE FROM point WHERE quest_id = :quest_id")
            await self._quest_repository._session.execute(points_query, {"quest_id": quest_id})
            
            # 4. Удаляем связанный мерч (merch)
            print(f"Deleting merch for quest {quest_id}...")
            merch_query = text("DELETE FROM merch WHERE quest_id = :quest_id")
            await self._quest_repository._session.execute(merch_query, {"quest_id": quest_id})
            
            # 5. Удаляем связанные отзывы (reviews)
            print(f"Deleting reviews for quest {quest_id}...")
            reviews_query = text("DELETE FROM review WHERE quest_id = :quest_id")
            await self._quest_repository._session.execute(reviews_query, {"quest_id": quest_id})
            
            # 6. Теперь удаляем сам квест
            print(f"Deleting quest {quest_id}...")
            await self._quest_repository.delete(quest)
            
            print(f"Quest {quest_id} and all related data deleted successfully!")
            return Ok(quest_id)
            
        except Exception as e:
            print(f"ERROR: Failed to delete quest {quest_id}: {e}")
            return Err(QuestNotFoundException())

    async def create_quest_point(self, quest_id: int, point_dto: PointCreateDTO) -> Err[Exception] | Ok[Any]:
        """Создание точки квеста."""
        try:
            # Проверяем существование квеста
            quest = await self._quest_repository.get_by_oid(quest_id)
            if not quest:
                return Err(QuestNotFoundException())
            
            # Проверяем DTO точки
            check_result = await self._check_points_dtos([point_dto])
            if isinstance(check_result, Err):
                return check_result
            
            # Создаем точку
            point = await self._point_repository.create(point_dto)
            return Ok(point)
            
        except Exception as e:
            return Err(e)

    async def update_quest_point(self, quest_id: int, point_id: int, point_dto: PointUpdateDTO) -> Err[Exception] | Ok[Any]:
        """Обновление точки квеста."""
        try:
            # Проверяем существование квеста
            quest = await self._quest_repository.get_by_oid(quest_id)
            if not quest:
                return Err(QuestNotFoundException())
            
            # Проверяем существование точки
            point = await self._point_repository.get_by_oid(point_id)
            if not point:
                return Err(PointNotFoundException())
            
            # Проверяем, что точка принадлежит квесту
            if point.quest_id != quest_id:
                return Err(PointNotFoundException())
            
            # Проверяем DTO точки
            check_result = await self._check_points_dtos([point_dto])
            if isinstance(check_result, Err):
                return check_result
            
            # Обновляем точку
            updated_point = await self._point_repository.update_point(point_dto, point)
            return Ok(updated_point)
            
        except Exception as e:
            return Err(e)

    async def delete_quest_point(self, quest_id: int, point_id: int) -> Err[Exception] | Ok[int]:
        """Удаление точки квеста."""
        try:
            # Проверяем существование квеста
            quest = await self._quest_repository.get_by_oid(quest_id)
            if not quest:
                return Err(QuestNotFoundException())
            
            # Проверяем существование точки
            point = await self._point_repository.get_by_oid(point_id)
            if not point:
                return Err(PointNotFoundException())
            
            # Проверяем, что точка принадлежит квесту
            if point.quest_id != quest_id:
                return Err(PointNotFoundException())
            
            # Удаляем точку
            await self._point_repository.delete(point)
            return Ok(point_id)
            
        except Exception as e:
            return Err(e)

    async def get_quest_point_by_id(self, quest_id: int, point_id: int) -> Err[Exception] | Ok[Any]:
        """Получение точки квеста по ID."""
        try:
            # Проверяем существование квеста
            quest = await self._quest_repository.get_by_oid(quest_id)
            if not quest:
                return Err(QuestNotFoundException())
            
            # Получаем точку
            point = await self._point_repository.get_by_oid(point_id)
            if not point:
                return Err(PointNotFoundException())
            
            # Проверяем, что точка принадлежит квесту
            if point.quest_id != quest_id:
                return Err(PointNotFoundException())
            
            return Ok(point)
            
        except Exception as e:
            return Err(e)

    def get_mock_image(self, image_hash: str) -> str | None:
        """Получение base64 изображения по mock hash."""
        return self._mock_images.get(image_hash)


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
