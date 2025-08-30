from typing import assert_never

from api import exceptions as api_core_exc
from api.modules.merch import exceptions as api_merch_exc
from api.modules.quest import exceptions as quest_api_exc
from core import exceptions as core_exc
from core.merch import exceptions as merch_exc
from core.quest import exceptions as quest_exc
from core.services import BaseService

ERROR_MAPPING = {
    quest_exc.QuestNotFoundException: quest_api_exc.QuestNotFoundHTTPError,
    quest_exc.QuestWithNameAlreadyExistsException: quest_api_exc.QuestNameAlreadyExistsHTTPError,
    quest_exc.QuestItemAlreadyExistsException: quest_api_exc.QuestItemAlreadyExistsHTTPError,
    quest_exc.ActivityNotFoundException: quest_api_exc.ActivityNotFoundHTTPError,
    quest_exc.ToolNotFoundException: quest_api_exc.ToolNotFoundHTTPError,
    quest_exc.CategoryNotFoundException: quest_api_exc.CategoryNotFoundHTTPError,
    quest_exc.PlaceNotFoundException: quest_api_exc.PlacesNotFoundHTTPError,
    quest_exc.VehicleNotFoundException: quest_api_exc.VehicleNotFoundHTTPError,
    quest_exc.PlacePreferenceNotFoundException: quest_api_exc.PlacePreferenceNotFoundHTTPError,
    quest_exc.PointNotFoundException: quest_api_exc.PointNotFoundHTTPError,
    quest_exc.InsufficientPointForDeleteException: quest_api_exc.InsufficientPointsForDeletionHTTPError,
    quest_exc.InsufficientPlaceForDeleteException: quest_api_exc.InsufficientPlacesForDeletionHTTPError,
    merch_exc.MerchNotFoundException: api_merch_exc.MerchNotFoundHTTPError,
    core_exc.S3ServiceClientException: api_core_exc.S3ClientHTTPError,
}


async def exceptions_mapper(err_value: Exception, *services: BaseService):
    error = ERROR_MAPPING.get(type(err_value))

    for service in services:
        if service.temporary_files_links:
            await service.clear_files_after_fail()

    if error:
        raise error()

    assert_never(err_value)
