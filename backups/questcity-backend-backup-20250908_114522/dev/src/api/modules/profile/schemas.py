from core.schemas import BaseSchema


class ProfileUpdateSchema(BaseSchema):
    image: str | None = None
    instagram_username: str | None = None


class ProfileUpdateAdminSchema(BaseSchema):
    image: str | None = None
    instagram_username: str | None = None
    credits: int | None = None
