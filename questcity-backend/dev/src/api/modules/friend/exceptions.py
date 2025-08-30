from fastapi import status

from api.exceptions import APIErrorSchema, BaseHTTPError


class UserNotEligibleForFriendHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "USER_NOT_ELIGIBLE_FOR_FRIEND"
    error_schema = APIErrorSchema(
        code=code, message="User is not eligible for creating a friendship."
    )


class FriendshipAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "FRIENDSHIP_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code, message="Friendship between the users already exists."
    )


class FriendshipNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "FRIENDSHIP_NOT_FOUND"
    error_schema = APIErrorSchema(
        code=code, message="The specified friendship does not exist or is invalid."
    )
