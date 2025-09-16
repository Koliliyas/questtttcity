from enum import Enum, StrEnum


class GroupType(Enum):
    ALONE = 1
    TWO = 2
    THREE = 3
    FOUR = 4


class Timeframe(Enum):
    ONE_HOUR = 1
    THREE_HOURS = 3
    TEN_HOURS = 10
    DAY = 24


class Level(StrEnum):
    EASY = "Easy"
    MIDDLE = "Medium"
    HARD = "Hard"


class Milage(StrEnum):
    UP_TO_TEN = "5-10"
    UP_TO_THIRTY = "10-30"
    UP_TO_HUNDRED = "30-100"
    MORE_THAN_HUNDRED = ">100"
