from dataclasses import dataclass

from src.core.dto import BaseUpdateDTO


@dataclass
class UnlockRequestCreateDTO:
    email: str
    reason: str
    message: str


@dataclass
class UnlockRequestUpdateDTO(BaseUpdateDTO):
    status: str
