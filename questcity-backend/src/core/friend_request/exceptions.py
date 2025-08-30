class SelfFriendRequestError(Exception):
    pass


class FriendRequestAlreadyExistsError(Exception):
    pass


class UserNotEligibleForFriendRequestError(Exception):
    pass


class FriendRequestNotFoundError(Exception):
    pass
