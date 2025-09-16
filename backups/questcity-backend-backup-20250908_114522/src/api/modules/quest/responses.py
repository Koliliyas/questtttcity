from src.api import exceptions as api_ex
from src.api.modules.merch.exceptions import MerchNotFoundHTTPError
from src.api.modules.quest import exceptions as module_ex
from src.api.responses import base_responses_with_auth
from src.api.utils import get_responses

get_all_quests_responses = get_responses(base_responses_with_auth)

get_quest_responses = get_responses(
    [module_ex.QuestNotFoundHTTPError] + base_responses_with_auth
)

update_quest_responses = get_responses(
    [
        module_ex.QuestNotFoundHTTPError,
        module_ex.QuestNameAlreadyExistsHTTPError,
        module_ex.ActivityNotFoundHTTPError,
        module_ex.ToolNotFoundHTTPError,
        module_ex.CategoryNotFoundHTTPError,
        module_ex.VehicleNotFoundHTTPError,
        module_ex.PlacesNotFoundHTTPError,
        module_ex.PlacePreferenceNotFoundHTTPError,
        module_ex.PointNotFoundHTTPError,
        MerchNotFoundHTTPError,
        module_ex.InsufficientPointsForDeletionHTTPError,
        module_ex.InsufficientPlacesForDeletionHTTPError,
        api_ex.InvalidFileHTTPError,
        api_ex.S3ClientHTTPError,
    ]
    + base_responses_with_auth
)

create_category_responses = get_responses(
    [module_ex.CategoryNameAlreadyExistsHTTPError] + base_responses_with_auth
)
update_category_responses = get_responses(
    [
        module_ex.CategoryNotFoundHTTPError,
        api_ex.S3ClientHTTPError,
    ]
    + base_responses_with_auth
)
create_place_responses = get_responses(
    [module_ex.PlaceNameAlreadyExistsHTTPError] + base_responses_with_auth
)

create_vehicle_responses = get_responses(
    [module_ex.VehicleNameAlreadyExistsHTTPError] + base_responses_with_auth
)
create_activity_responses = get_responses(
    [module_ex.ActivityNameAlreadyExistsHTTPError] + base_responses_with_auth
)
create_tool_responses = get_responses(
    [module_ex.ToolNameAlreadyExistsHTTPError] + base_responses_with_auth
)
create_quest_responses = get_responses(
    [
        module_ex.CategoryNotFoundHTTPError,
        module_ex.VehicleNotFoundHTTPError,
        module_ex.PlacesNotFoundHTTPError,
        module_ex.ActivityNotFoundHTTPError,
        module_ex.ToolNotFoundHTTPError,
        module_ex.QuestNameAlreadyExistsHTTPError,
        api_ex.S3ClientHTTPError,
    ]
    + base_responses_with_auth
)
