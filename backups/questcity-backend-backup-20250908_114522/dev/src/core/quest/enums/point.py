from enum import StrEnum


class TakePhoto(StrEnum):
    FACE_VERIFICATION = "Face verification"
    DIRECTION_CHECK = "Photo direction check"
    MATCHING = "Photo Matching"
