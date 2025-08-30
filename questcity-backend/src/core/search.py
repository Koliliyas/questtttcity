import logging
from sqlalchemy import (Column, ColumnElement, Index, Select, Table, func,
                        select, text)
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import InstrumentedAttribute
from sqlalchemy.sql._typing import _DDLColumnArgument

from src.db.base import ModelType

# Security logger for search operations
security_logger = logging.getLogger('security.search')

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
        
        Safely sets the similarity limit using parameterized query to prevent SQL injection.
        """
        effective_limit = limit if limit is not None else self._similarity_limit
        
        if effective_limit is None:
            raise ValueError("None limit provided and no default similarity_limit set.")
        
        # Validate limit is a proper float between 0 and 1
        if not isinstance(effective_limit, (int, float)):
            raise ValueError(f"Similarity limit must be a number, got: {type(effective_limit)}")
        
        if not (0.0 <= effective_limit <= 1.0):
            raise ValueError(f"Similarity limit must be between 0.0 and 1.0, got: {effective_limit}")
        
        # Use parameterized query to prevent SQL injection
        # PostgreSQL's set_limit function expects a float parameter
        await session.execute(text("SELECT set_limit(:limit)"), {"limit": effective_limit})

    def __call__(
        self,
        term: str,
        *,
        order: bool = True,
        include_similarity_ratio: bool = False,
        additional_where: list = [],
    ) -> Select:
        """
        Search `term` string using safe parameterized queries.
        
        Args:
            term: Search term (validated for safety)
            order: Whether to order results by similarity 
            include_similarity_ratio: Include similarity score in results
            additional_where: Additional WHERE conditions
            
        Returns:
            SQLAlchemy Select statement with parameterized queries
            
        Raises:
            ValueError: If term is invalid or potentially malicious
        """
        # Input validation to prevent potential issues
        if not isinstance(term, str):
            raise ValueError(f"Search term must be a string, got: {type(term)}")
        
        if not term.strip():
            raise ValueError("Search term cannot be empty or whitespace only")
        
        # Limit term length to prevent DoS attacks
        if len(term) > 1000:
            raise ValueError(f"Search term too long: {len(term)} characters (max 1000)")
        
        # Check for suspicious patterns that might indicate injection attempts
        suspicious_patterns = [
            ';', '--', '/*', '*/', 'xp_', 'sp_', 'DROP', 'DELETE', 'INSERT', 
            'UPDATE', 'CREATE', 'ALTER', 'EXEC', 'EXECUTE', 'UNION'
        ]
        
        term_upper = term.upper()
        for pattern in suspicious_patterns:
            if pattern in term_upper:
                # Log suspicious search attempt
                security_logger.warning(
                    f"Suspicious search pattern detected: '{pattern}' in term", 
                    extra={
                        'event': 'suspicious_search_blocked',
                        'search_term': term[:100],  # Log first 100 chars only
                        'suspicious_pattern': pattern,
                        'model': self._model.__name__ if hasattr(self._model, '__name__') else str(self._model)
                    }
                )
                raise ValueError(f"Search term contains suspicious pattern: '{pattern}'")
        
        # Sanitize term - remove potential control characters
        sanitized_term = ''.join(char for char in term if ord(char) >= 32 or char in '\t\n\r')
        if sanitized_term != term:
            raise ValueError("Search term contains invalid control characters")
        # Use sanitized term for all database operations
        # SQLAlchemy automatically parameterizes these values, preventing SQL injection
        columns = self.concat_columns(*self.columns)
        entities = self._entities.copy()
        if include_similarity_ratio:
            entities.add(func.similarity(columns, sanitized_term).label("similarity_ratio"))  # type: ignore

        subquery = (
            select(self._model.id)
            .where(columns.self_group().bool_op("%")(sanitized_term), *additional_where)
            .subquery()
        )

        statement = select(self._model).where(self._model.id.in_(subquery))

        if order:
            statement = statement.order_by(func.similarity(columns, sanitized_term).desc())

        return statement
