"""add_autoincrement_to_primary_keys

Revision ID: ab208ca58172
Revises: acf3258978d2
Create Date: 2025-07-28 17:46:23.629326

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ab208ca58172'
down_revision: Union[str, None] = 'acf3258978d2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Создаем SEQUENCE для quest.id и устанавливаем его как DEFAULT
    op.execute("CREATE SEQUENCE IF NOT EXISTS quest_id_seq")
    op.execute("SELECT setval('quest_id_seq', COALESCE((SELECT MAX(id) FROM quest), 1))")
    op.execute("ALTER TABLE quest ALTER COLUMN id SET DEFAULT nextval('quest_id_seq')")
    op.execute("ALTER SEQUENCE quest_id_seq OWNED BY quest.id")
    
    # Создаем SEQUENCE для других таблиц с int32_pk
    tables_to_fix = ['category', 'place', 'vehicle', 'point', 'merch', 'review']
    
    for table in tables_to_fix:
        op.execute(f"CREATE SEQUENCE IF NOT EXISTS {table}_id_seq")
        op.execute(f"SELECT setval('{table}_id_seq', COALESCE((SELECT MAX(id) FROM {table}), 1))")
        op.execute(f"ALTER TABLE {table} ALTER COLUMN id SET DEFAULT nextval('{table}_id_seq')")
        op.execute(f"ALTER SEQUENCE {table}_id_seq OWNED BY {table}.id")


def downgrade() -> None:
    # Удаляем DEFAULT и SEQUENCE для quest
    op.execute("ALTER TABLE quest ALTER COLUMN id DROP DEFAULT")
    op.execute("DROP SEQUENCE IF EXISTS quest_id_seq")
    
    # Удаляем DEFAULT и SEQUENCE для других таблиц
    tables_to_fix = ['category', 'place', 'vehicle', 'point', 'merch', 'review']
    
    for table in tables_to_fix:
        op.execute(f"ALTER TABLE {table} ALTER COLUMN id DROP DEFAULT")
        op.execute(f"DROP SEQUENCE IF EXISTS {table}_id_seq")
