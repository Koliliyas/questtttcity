class CategoryNotFoundException(Exception):
    pass


class VehicleNotFoundException(Exception):
    pass


class PlaceNotFoundException(Exception):
    pass


class ActivityNotFoundException(Exception):
    pass


class ToolNotFoundException(Exception):
    pass


class QuestWithNameAlreadyExistsException(Exception):
    pass


class QuestNotFoundException(Exception):
    pass


class QuestItemAlreadyExistsException(Exception):
    pass


class PointNotFoundException(Exception):
    pass


class PlacePreferenceNotFoundException(Exception):
    pass


class InsufficientPointForDeleteException(Exception):
    pass


class InsufficientPlaceForDeleteException(Exception):
    pass


class ReviewAlreadyExists(Exception):
    pass


class ReviewNotFound(Exception):
    pass


class ReviewResponseAlreadyExists(Exception):
    pass
