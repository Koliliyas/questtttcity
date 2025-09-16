from fastapi import status

from api.exceptions import APIErrorSchema, BaseHTTPError


class SelfFriendRequestHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "SELF_FRIEND_REQUEST"
    error_schema = APIErrorSchema(
        code=code, message="Cannot send a friend request to yourself."
    )


class FriendRequestAlreadyExistsHTTPError(BaseHTTPError):
    status_code = status.HTTP_409_CONFLICT
    code = "FRIEND_REQUEST_ALREADY_EXISTS"
    error_schema = APIErrorSchema(
        code=code, message="A friend request already exists between these users."
    )


class UserNotEligibleForFriendRequestHTTPError(BaseHTTPError):
    status_code = status.HTTP_400_BAD_REQUEST
    code = "USER_NOT_ELIGIBLE_FOR_FRIEND_REQUEST"
    error_schema = APIErrorSchema(
        code=code, message="User is not eligible to receive a friend request."
    )


class FriendRequestNotFoundHTTPError(BaseHTTPError):
    status_code = status.HTTP_404_NOT_FOUND
    code = "FRIEND_REQUEST_NOT_FOUND"
    error_schema = APIErrorSchema(code=code, message="Friend request not found.")
