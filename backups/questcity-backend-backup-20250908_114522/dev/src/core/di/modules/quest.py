import aioinject

from core.di._types import Providers
from core.quest.repositories import (CategoryRepository,
                                     PlacePreferenceRepository,
                                     PlaceRepository, PointRepository,
                                     QuestRepository, ReviewRepository,
                                     ToolRepository, TypeRepository,
                                     VehicleRepository)
from core.quest.services import ItemService, QuestService, ReviewService

PROVIDERS: Providers = [
    aioinject.Scoped(ReviewRepository),
    aioinject.Scoped(CategoryRepository),
    aioinject.Scoped(PlacePreferenceRepository),
    aioinject.Scoped(PlaceRepository),
    aioinject.Scoped(PointRepository),
    aioinject.Scoped(QuestRepository),
    aioinject.Scoped(ToolRepository),
    aioinject.Scoped(TypeRepository),
    aioinject.Scoped(VehicleRepository),
    aioinject.Scoped(QuestService),
    aioinject.Scoped(ItemService),
    aioinject.Scoped(ReviewService),
]
