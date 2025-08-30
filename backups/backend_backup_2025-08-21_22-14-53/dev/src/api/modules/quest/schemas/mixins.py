import base64
import io

from PIL import Image
from pydantic import field_validator, model_validator


class DescriptionNotEmptyMixin:
    @field_validator("description")
    def description_not_empty_validator(cls, value: str) -> str:
        if not value:
            raise ValueError("Description field can't be empty.")
        return value


class IdIsRequiredMixin:
    @model_validator(mode="before")
    @classmethod
    def cant_delete_without_id(cls, data: dict):
        if data.get("is_delete") and data.get("id") is None:
            raise ValueError("Id is required when deleting merch.")

        return data


class ImageValidateMixin:
    @field_validator("image")
    def validate_image(cls, value: str) -> str:
        if value is not None:
            try:
                if value.startswith("data:"):
                    _, value = value.split(",", 1)

                image = Image.open(io.BytesIO(base64.b64decode(value, validate=True)))
                image.verify()

            except (ValueError, TypeError) as exception:
                raise ValueError("Invalid base64 string.") from exception
            except IOError as exception:
                raise ValueError("The data isn't a valid image.") from exception

        return value
