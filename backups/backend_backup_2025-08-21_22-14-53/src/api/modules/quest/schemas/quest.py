import base64
from typing import Optional

from pydantic import BaseModel, Field, field_validator

from src.api.modules.quest.schemas.mixins import (DescriptionNotEmptyMixin,
                                              IdIsRequiredMixin,
                                              ImageValidateMixin)
from src.core.quest.enums import GroupType, Level, Milage, Timeframe
from src.core.schemas import BaseSchema
from src.api.modules.quest.schemas.point import (
    PointCreateSchema, PointReadForCurrentQuestSchema, PointReadSchema,
    PointUpdateSchema)


# Item create schemas:
class ItemRequestSchema(BaseSchema):
    name: str = Field(..., min_length=2, max_length=128)

    @field_validator("name")
    def validate_name(cls, value: str) -> str:
        if not value:
            raise ValueError("Name can't be empty.")

        if value.isdigit():
            raise ValueError("Name field must contains letters.")

        return value


class ItemWithImageRequestSchema(ImageValidateMixin, ItemRequestSchema):
    image: str


# Item update schemas:
class ItemUpdateSchema(ItemRequestSchema):
    name: Optional[str] = Field(None, min_length=2, max_length=16)

    @field_validator("name")
    def validate_name(cls, value: str) -> str:
        if value is not None:
            return super().validate_name(value)

        return value


class ItemWithImageUpdateSchema(ImageValidateMixin, ItemUpdateSchema):
    image: Optional[str] = None


# Item read schemas:
class ItemReadSchema(ItemRequestSchema):
    id: int


class ItemWithImageRead(ItemReadSchema):
    image: str


class MerchRequestSchema(DescriptionNotEmptyMixin, ImageValidateMixin, BaseSchema):
    description: str
    price: int
    image: str


class Credits(BaseModel):
    """Кредиты и награды для квестов - соответствует полям cost/reward модели Quest."""
    auto: bool = Field(default=False)  # Quest.auto_accrual
    cost: int = Field(default=0)  # Quest.cost
    reward: int = Field(default=0)  # Quest.reward - делаем с default значением


class PriceSettings(BaseModel):
    """Настройки цены для квестов - соответствует полям модели Quest."""
    type: str = "default"  # Можно будет маппить на Quest.is_subscription
    is_subscription: bool = False  # Quest.is_subscription
    amount: float = Field(default=0)  # Quest.pay_extra


class MainPreferences(BaseModel):
    """Основные предпочтения для квестов - используется в роутере для агрегации данных."""
    category_id: int = Field(..., description="ID категории квеста")
    vehicle_id: int = Field(..., description="ID транспорта")
    place_id: int = Field(..., description="ID места")
    group: GroupType = Field(..., description="Тип группы")
    timeframe: Optional[Timeframe] = Field(None, description="Временные рамки")
    level: Level = Field(..., description="Уровень сложности")
    mileage: Milage = Field(..., description="Пробег")
    types: list[int] = Field(default_factory=list)  # ID типов активности
    places: list[int] = Field(default_factory=list)  # ID мест  
    vehicles: list[int] = Field(default_factory=list)  # ID транспорта
    tools: list[int] = Field(default_factory=list)  # ID инструментов


class PlaceSettingsRead(BaseModel):
    """Настройки места для квеста - используется в ответе QuestReadSchema."""
    type: str = "default"
    settings: Optional["PlaceModelRead"] = None


class PlaceModelRead(BaseModel):
    """Модель места для ответа."""
    id: int
    title: str


class QuestCreteSchema(DescriptionNotEmptyMixin, ImageValidateMixin, BaseSchema):
    name: str = Field(..., min_length=1, max_length=32)
    description: str
    image: str

    merch: list[MerchRequestSchema] = Field(default_factory=list)
    credits: Credits = Field(default_factory=lambda: Credits(cost=0, reward=0))
    main_preferences: MainPreferences = Field(default_factory=lambda: MainPreferences())
    mentor_preference: str = Field(default="")

    points: list[PointCreateSchema] = Field(default_factory=list)

    @field_validator("mentor_preference")
    def validate_mentor_preference(cls, value: str) -> str:
        # Упрощенная валидация - если пустая строка, возвращаем как есть
        if not value:
            return ""
        
        # Если это base64, валидируем
        if value.startswith("data:"):
            try:
                _, value = value.split(",", 1)
                base64.b64decode(value, validate=True)
            except (ValueError, TypeError) as exception:
                raise ValueError("Invalid base64 string.") from exception
        
        return value


class QuestAsItem(BaseSchema):
    id: int
    name: str
    image: str
    rating: float

    main_preferences: MainPreferences


class MerchReadSchema(BaseSchema):
    id: int
    description: str
    price: int
    image: str


class QuestReadSchema(BaseSchema):
    """Схема для детального ответа о квесте - соответствует реальной модели Quest."""
    
    # Основная информация (маппинг с моделью Quest)
    id: int
    title: str  # Quest.name
    short_description: str  # Quest.description
    full_description: str  # Quest.description (то же поле)
    image_url: str  # Quest.image
    
    # Категория (загружается через связь)
    category_id: int  # Quest.category_id
    category_title: Optional[str] = None  # Quest.category.name
    category_image_url: Optional[str] = None  # Quest.category.image
    
    # Сложность и характеристики квеста  
    difficulty: str  # Quest.level.value
    price: float  # Quest.pay_extra
    duration: str  # Quest.timeframe.value
    player_limit: int = 0  # Не существует в модели Quest
    age_limit: int = 0  # Не существует в модели Quest
    is_for_adv_users: bool = False  # Не существует в модели Quest
    type: str  # Quest.group.value
    
    # Кредиты и награды - делаем опциональными с default
    credits: Optional[Credits] = Field(default_factory=lambda: Credits(cost=0, reward=0))
    
    # Mentor preference - добавляем поле
    mentor_preference: Optional[str] = Field(default="", description="Mentor preference setting")
    
    # Связанные данные - все с default значениями
    merch_list: list[MerchReadSchema] = Field(default_factory=list)
    main_preferences: Optional[MainPreferences] = Field(default_factory=lambda: MainPreferences())
    points: list[PointReadSchema] = Field(default_factory=list)
    place_settings: Optional[PlaceSettingsRead] = Field(default_factory=lambda: PlaceSettingsRead(type="default"))
    price_settings: Optional[PriceSettings] = Field(default_factory=lambda: PriceSettings())


class CurrentQuestSchema(BaseSchema):
    mentor_preference: str
    points: list[PointReadForCurrentQuestSchema]


class QuestParameterModel(BaseSchema):
    """Схема для ответа при создании/обновлении квеста администратором."""
    id: int
    name: str
    description: Optional[str] = None
    image: Optional[str] = None
    category_id: int
    level: Optional[str] = None
    timeframe: Optional[str] = None
    group: Optional[str] = None
    cost: Optional[int] = None
    reward: Optional[int] = None
    pay_extra: Optional[float] = None
    is_subscription: Optional[bool] = None
    vehicle_id: Optional[int] = None


# Update quest schemas:
class UpdateMerhSchema(IdIsRequiredMixin, MerchRequestSchema):
    id: Optional[int] = None
    is_delete: bool = False
    image: Optional[str] = None


class QuestUpdateRequestSchema(BaseSchema):
    """Схема для обновления квеста - упрощенная версия."""
    name: Optional[str] = Field(None, min_length=1, max_length=32)
    description: Optional[str] = None
    image: Optional[str] = None
    merch: list[UpdateMerhSchema] = Field(default_factory=list)
    points: list[PointUpdateSchema] = Field(default_factory=list)
    mentor_preference: Optional[str] = None
    credits: Optional[Credits] = None
    main_preferences: Optional[MainPreferences] = None


class QuestUpdateResponse(BaseModel):
    """Простой ответ на редактирование квеста."""
    id: int
    name: str
    message: str = "Quest updated successfully"


class QuestEditSchema(BaseModel):
    """Упрощенная схема для редактирования квеста."""
    name: str = Field(..., min_length=1, max_length=32)
    description: str
    image: str
    category_id: int
    vehicle_id: int
    place_id: int
    group: int  # Простое число вместо enum
    timeframe: int  # Простое число вместо enum
    level: str  # Строка вместо enum
    mileage: str  # Строка вместо enum
    cost: int
    reward: int
    mentor_preference: str = ""
    points: list = Field(default_factory=list)  # Упрощенный список
