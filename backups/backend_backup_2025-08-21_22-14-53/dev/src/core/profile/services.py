from result import Err, Ok

from core.profile.dto import ProfileUpdateDTO
from core.profile.exceptions import ProfileNotFoundError
from core.profile.repositories import ProfileRepository


class ProfileService:
    def __init__(self, profile_repository: ProfileRepository):
        self.__profile_repository = profile_repository

    async def update(self, profile_id: int, profile_dto: ProfileUpdateDTO):
        result = await self.__profile_repository.get(id_=profile_id)

        if result is None:
            return Err(ProfileNotFoundError())

        await self.__profile_repository.update(
            id_=profile_id, fields_to_update=profile_dto.get_non_none_fields()
        )

        return Ok(1)
