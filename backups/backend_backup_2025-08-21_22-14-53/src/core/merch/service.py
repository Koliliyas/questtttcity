from dataclasses import asdict

from botocore.exceptions import ClientError
from result import Err

from src.core.exceptions import S3ServiceClientException
from src.core.merch.dto import MerchCreateDTO, MerchUpdateDTO
from src.core.merch.exceptions import MerchNotFoundException
from src.core.merch.repository import MerchRepository
from src.core.repositories import S3Repository
from src.core.services import BaseService
from src.db.models.merch import Merch


class MerchService(BaseService):
    def __init__(self, merch_repository: MerchRepository, s3: S3Repository):
        super().__init__(s3)
        self._merch_repository = merch_repository

    async def create_merch(
        self,
        dto: MerchCreateDTO,
    ):
        print(f"DEBUG: create_merch - Создаем merchandise")
        print(f"  - description: '{dto.description}'")
        print(f"  - price: {dto.price}")
        print(f"  - image length: {len(dto.image) if dto.image else 0}")
        print(f"  - quest_id: {dto.quest_id}")
        
        try:
            if dto.image:
                print(f"  - Загружаем изображение в S3...")
                dto.image = await self._s3.upload_file(
                    release="merchs",
                    file_data=dto.image,
                )
                self.temporary_files_links.append(dto.image)
                print(f"  - Изображение загружено: {dto.image}")

        except ClientError as e:
            print(f"ERROR: create_merch - Ошибка S3: {e}")
            return Err(S3ServiceClientException())

        print(f"  - Сохраняем merchandise в БД...")
        instance = await self._merch_repository.create(dto)
        print(f"SUCCESS: create_merch - Merchandise создан с id={instance.id}")
        from result import Ok
        return Ok(instance)

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
                        release="merchs",
                        file_data=dto.image,
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
