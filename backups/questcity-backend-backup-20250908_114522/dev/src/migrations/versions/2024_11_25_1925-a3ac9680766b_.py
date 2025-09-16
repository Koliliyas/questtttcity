"""empty message

Revision ID: a3ac9680766b
Revises: 
Create Date: 2024-11-25 19:25:50.495415

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = 'a3ac9680766b'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    op.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm;")


def downgrade() -> None:
    op.execute("DROP EXTENSION IF EXISTS pg_trgm;")