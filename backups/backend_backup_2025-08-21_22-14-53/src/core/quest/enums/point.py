from enum import StrEnum


class TakePhoto(StrEnum):
    FACE_VERIFICATION = "Face verification"
    DIRECTION_CHECK = "Photo direction check"
    MATCHING = "Photo Matching"
    
    def __repr__(self):
        return f"{self.__class__.__name__}.{self.name}"
    
    def __str__(self):
        return self.value