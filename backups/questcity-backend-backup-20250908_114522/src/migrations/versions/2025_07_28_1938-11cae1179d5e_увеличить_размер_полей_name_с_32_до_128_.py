"""Увеличить размер полей name с 32 до 128 символов

Revision ID: 11cae1179d5e
Revises: ab208ca58172
Create Date: 2025-07-28 19:38:53.959650

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '11cae1179d5e'
down_revision: Union[str, None] = 'ab208ca58172'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Увеличиваем размер полей name до 128 символов
    op.alter_column('activity', 'name', type_=sa.String(128))
    op.alter_column('tool', 'name', type_=sa.String(128))
    op.alter_column('point', 'name_of_location', type_=sa.String(128))
    op.alter_column('point', 'type_word', type_=sa.String(128))
    op.alter_column('category', 'name', type_=sa.String(128))  # было String(16)
    op.alter_column('quest', 'name', type_=sa.String(128))
    op.alter_column('vehicle', 'name', type_=sa.String(128))  # было String(16)


def downgrade() -> None:
    # Возвращаем обратно оригинальные размеры
    op.alter_column('activity', 'name', type_=sa.String(32))
    op.alter_column('tool', 'name', type_=sa.String(32))
    op.alter_column('point', 'name_of_location', type_=sa.String(32))
    op.alter_column('point', 'type_word', type_=sa.String(32))
    op.alter_column('category', 'name', type_=sa.String(16))  # возвращаем String(16)
    op.alter_column('quest', 'name', type_=sa.String(32))
    op.alter_column('vehicle', 'name', type_=sa.String(16))  # возвращаем String(16)
