from typing import Any, Iterable, TypeVar

from pydantic import BaseModel, ConfigDict, EmailStr, constr

# TypeVar for Self-type annotation compatibility with Python 3.9
T = TypeVar('T', bound='BaseSchema')

UsernameStr = constr(min_length=3, max_length=15)
FirstNameStr = constr(min_length=1, max_length=128)
LastNameStr = constr(min_length=1, max_length=128)

# class UsernameStr(constr):
#     min_length = 3
#     max_length = 15

# class FirstNameStr(constr):
#     min_length = 1
#     max_length = 128

# class LastNameStr(constr):
#     min_length = 1
#     max_length = 128


def snake_to_camel(name: str) -> str:
    """Преобразования названия из нотации snake_case в нотацию camelCase (стандартный формат для JavaScript приложений).

    Args:
        name (str): изначальное название в snake_case.

    Returns:
        str: полученное название в camelCase.
    """
    first, *rest = name.split("_")
    return first + "".join(map(str.capitalize, rest))


class BaseSchema(BaseModel):
    """
    Базовый класс для всех схем проекта.
    """

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
        alias_generator=snake_to_camel,
    )

    @classmethod
    def model_validate_list(cls: type[T], models: Iterable[Any]) -> list[T]:
        """Трансформация коллекции объектов в список объектов-схем.

        Args:
            models (Iterable[Any]): коллекция объектов (чаще всего ORM).

        Returns:
            list[T]: список объектов-схем pydantic.
        """
        return [cls.model_validate(model) for model in models]


class CustomEmailStr(EmailStr):
    @classmethod
    def _validate(cls, input_value: str, /) -> str:
        result = super()._validate(input_value)
        if len(input_value) > 29:
            raise ValueError(
                f"Email '{input_value}' exceeds the maximum length of 30 characters."
            )

        return result
