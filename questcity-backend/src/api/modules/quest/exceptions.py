from fastapi import status

from src.api.exceptions import APIErrorSchema, BaseHTTPError


class CategoryNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "CATEGORY_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Category not found.")


class VehicleNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "VEHICLE_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Vehicle not found.")


class PlacesNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "PLACES_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Places not found.")


class ActivityNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "ACTIVITY_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Activity not found.")


class ToolNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "TOOL_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Tool not found.")


class QuestNameAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "QUEST_NAME_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Quest with this name already exists.",
    )


class QuestNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "QUEST_NOT_FOUND"
    error_schema = APIErrorSchema(
        code=code,
        message="Quest with this id not found.",
    )


class CategoryNameAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "CATEGORY_NAME_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Category with this name already exists.",
    )


class PlaceNameAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "PLACE_NAME_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Place with this name already exists.",
    )


class VehicleNameAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "VEHICLE_NAME_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Vehicle with this name already exists.",
    )


class ActivityNameAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "ACTIVITY_NAME_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Activity with this name already exists.",
    )


class ToolNameAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "TOOL_NAME_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Tool with this name already exists.",
    )


class PointNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "POINT_NOT_FOUND"
    error_schema = APIErrorSchema(
        code=code,
        message="Point not found.",
    )


class PlacePreferenceNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "PLACE_SETTINGS_NOT_FOUND"
    error_schema = APIErrorSchema(
        code=code,
        message="Place settings for point not found.",
    )


class InsufficientPointsForDeletionHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "INSUFFICIENT_POINTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Can't delete this Point. Should be more than two.",
    )


class InsufficientPlacesForDeletionHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "INSUFFICIENT_PLACES_PREFERENCES"
    error_schema = APIErrorSchema(
        code=code,
        message="Can't delete this place preference. Should be more than one.",
    )


class QuestItemAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "QUEST_ITEM_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code,
        message="Quest item with name already exists.",
    )
