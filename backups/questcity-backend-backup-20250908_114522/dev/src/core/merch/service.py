from dataclasses import asdict

from botocore.exceptions import ClientError
from result import Err

from core.exceptions import S3ServiceClientException
from core.merch.dto import MerchCreateDTO, MerchUpdateDTO
from core.merch.exceptions import MerchNotFoundException
from core.merch.repository import MerchRepository
from core.repositories import S3Repository
from core.services import BaseService
from db.models.merch import Merch


class MerchService(BaseService):
    def __init__(self, merch_repository: MerchRepository, s3: S3Repository):
        super().__init__(s3)
        self._merch_repository = merch_repository

    async def create_merch(
        self,
        dto: MerchCreateDTO,
    ):
        try:
            dto.image = await self._s3.upload_file(
                "merchs",
                dto.image,
            )
            self.temporary_files_links.append(dto.image)

        except ClientError:
            return Err(S3ServiceClientException())

        instance = await self._merch_repository.create(dto)
        return instance

    async def update_merch(
        self,
        dto: MerchUpdateDTO,
    ):
        if dto.id is not None:
            instance = await self._merch_repository.get_by_oid(dto.id)

            if instance is None:
                return Err(MerchNotFoundException())

            if dto.image != instance.image:
                if dto.image is None:
                    dto.image = instance.image
                try:
                    dto.image = await self._s3.upload_file(
                        content=dto.image,
                        release="merchs",
                    )

                    self.temporary_files_links.append(dto.image)
                    self.old_files_links.append(instance.image)

                except ClientError:
                    return Err(S3ServiceClientException())

            return await self._merch_repository.update(
                instance=instance,
                dto=dto,
            )

        data = asdict(dto)
        data.pop("id")
        return await self.create_merch(dto=MerchCreateDTO(**data))

    async def delete_merch(self, oid: int):
        merch = await self._merch_repository.get_by_oid(oid)

        if merch is None:
            return Err(MerchNotFoundException())

        self.old_files_links.append(merch.image)

        await self._merch_repository.delete(merch)

    async def get_merch(self, oid: int) -> Err[MerchNotFoundException] | Merch:
        instance = await self._merch_repository.get_by_oid(oid)

        if instance is None:
            return Err(MerchNotFoundException())

        return instance
