class PendingUnlockRequestExistsError(Exception):
    pass


class ActiveUserError(Exception):
    pass


class UnlockRequestNotFoundError(Exception):
    pass
