from sqlalchemy import (Column, ColumnElement, Index, Select, Table, func,
                        select, text)
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import InstrumentedAttribute
from sqlalchemy.sql._typing import _DDLColumnArgument

from db.base import ModelType

# TODO: make this class for all tables in one


class FuzzySearchService:
    """Search service by Trigrams with `pg_trgm` Postgres extension."""

    index_dialect_kw = dict(
        postgresql_using="gin",
        postgresql_ops={"columns": "gin_trgm_ops"},
    )

    def __init__(
        self,
        *on_columns: Column[str]
        | InstrumentedAttribute[str]
        | Column[str | None]
        | InstrumentedAttribute[str | None],
        similarity_limit: float | None = None,
        init_index: str | bool = False,
        model: ModelType,
    ) -> None:
        self._entities: set[Table] = {column.table for column in on_columns}
        if len(self._entities) > 1:
            raise ValueError(
                "FuzzySearchService supports querying only through *ONE* table. "
                "Use MaterializedSearchService instead. "
            )

        self._columns = on_columns
        self._similarity_limit = similarity_limit
        self._model = model
        self.index: Index | None = None
        if init_index:
            self.index = Index(
                init_index if isinstance(init_index, str) else None,
                self.concat_columns(*on_columns).label("columns"),
                **self.index_dialect_kw,  # type: ignore
            )

    @property
    def columns(self):
        return self._columns

    @classmethod
    def concat_columns(cls, *columns: _DDLColumnArgument) -> ColumnElement[str]:
        if not columns:
            raise ValueError("No columns. ")

        joined_columns = func.coalesce(columns[0], "")
        for idx in range(1, len(columns)):
            joined_columns = joined_columns.concat(func.coalesce(columns[idx], ""))  # type: ignore
        return joined_columns

    async def set_similarity_limit(
        self, session: AsyncSession, limit: float | None = None
    ) -> None:
        """
        Set limit for current database session (engine).
        """
        if limit is None and self._similarity_limit is None:
            raise ValueError("None limit. ")
        await session.execute(select(func.set_limit(text(str(self._similarity_limit)))))

    def __call__(
        self,
        term: str,
        *,
        order: bool = True,
        include_similarity_ratio: bool = False,
        additional_where: list = [],
    ) -> Select:
        """
        Search `term` string.
        """
        columns = self.concat_columns(*self.columns)
        entities = self._entities.copy()
        if include_similarity_ratio:
            entities.add(func.similarity(columns, term).label("similarity_ratio"))  # type: ignore

        subquery = (
            select(self._model.id)
            .where(columns.self_group().bool_op("%")(term), *additional_where)
            .subquery()
        )

        statement = select(self._model).where(self._model.id.in_(subquery))

        if order:
            statement = statement.order_by(func.similarity(columns, term).desc())

        return statement
