from dataclasses import dataclass
from typing import Optional


@dataclass
class MerchCreateDTO:
    description: str
    price: float
    image: str

    quest_id: Optional[int] = None


@dataclass
class MerchUpdateDTO:
    id: Optional[int]
    description: str
    price: float
    image: Optional[str]
    quest_id: Optional[int] = None
