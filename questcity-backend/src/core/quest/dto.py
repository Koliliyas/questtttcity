from dataclasses import dataclass
from typing import Optional
from uuid import UUID

# Убираем импорт enum, так как больше не используем их в DTO
# from src.core.quest.enums import GroupType, Level, Milage, TakePhoto, Timeframe


@dataclass
class QuestCreateDTO:
    name: str
    description: str
    image: str
    mentor_preference: str
    auto_accrual: bool
    cost: int
    reward: int
    is_subscription: bool
    pay_extra: int
    level: str  # Изменено с Level на str
    milage: str  # Изменено с Milage на str
    category_id: int
    vehicle_id: int
    place_id: int

    group: int  # Изменено с GroupType на int
    timeframe: Optional[int]  # Изменено с Timeframe на int


@dataclass
class PlaceCreateDTO:
    longitude: float
    latitude: float
    detections_radius: float
    height: float
    interaction_inaccuracy: float
    part: Optional[int]
    random_occurrence: Optional[float]
    point_id: Optional[int] = None


@dataclass
class PointCreateDTO:
    name_of_location: str
    description: str
    order: int
    type_id: int
    places: list[PlaceCreateDTO]
    type_photo: Optional[str]  # Изменено с TakePhoto на str
    type_code: Optional[int]  # Исправлено: str -> int
    type_word: Optional[str]
    tool_id: Optional[int]
    file: Optional[str]
    is_divide: Optional[bool]
    quest_id: Optional[int] = None


# Update DTOs:
@dataclass
class QuestUpdateDTO(QuestCreateDTO):
    id: Optional[int]
    image: Optional[str]
    mentor_preference: Optional[str]


@dataclass
class PlaceUpdateDTO:
    longitude: float
    latitude: float
    detections_radius: float
    height: float
    interaction_inaccuracy: float
    part: Optional[int]
    random_occurrence: Optional[float]
    id: Optional[int]
    point_id: Optional[int]


@dataclass
class PointUpdateDTO:
    id: Optional[int]
    quest_id: int
    name_of_location: str
    description: str
    order: int
    type_id: int
    tool_id: Optional[int]
    file: Optional[str]
    is_divide: Optional[bool]
    places: list[PlaceUpdateDTO]
    type_photo: Optional[str] = None
    type_code: Optional[int] = None  # Исправлено: str -> int
    type_word: Optional[str] = None


# Item DTOs:
@dataclass
class ItemCreateDTO:
    name: str


@dataclass
class ItemWithImageDTO(ItemCreateDTO):
    image: str


@dataclass
class ItemUpdateDTO:
    name: Optional[str]
    image: Optional[str]


@dataclass
class BaseReviewDTO:
    text: str
    rating: int
    user_id: UUID
    quest_id: int


@dataclass
class BaseReviewResponseDTO:
    text: str
    review_id: int
    user_id: UUID
