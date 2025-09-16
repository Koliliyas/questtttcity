"""Add performance indexes for quest search

Revision ID: ae5347a36282
Revises: 78dd5d17d997
Create Date: 2025-07-27 13:32:51.021931

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ae5347a36282'
down_revision: Union[str, None] = '78dd5d17d997'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Добавляем производительные индексы для поиска квестов."""
    
    # Композитный индекс для поиска по категории и уровню сложности
    op.create_index(
        'idx_quest_category_level',
        'quest',
        ['category_id', 'level'],
        postgresql_using='btree'
    )
    
    # Композитный индекс для поиска по месту и типу группы
    op.create_index(
        'idx_quest_place_group',
        'quest',
        ['place_id', 'group'],
        postgresql_using='btree'
    )
    
    # Индекс для сортировки по стоимости
    op.create_index(
        'idx_quest_cost',
        'quest',
        ['cost'],
        postgresql_using='btree'
    )
    
    # Индекс для фильтрации по подписке
    op.create_index(
        'idx_quest_subscription',
        'quest',
        ['is_subscription'],
        postgresql_using='btree'
    )
    
    # Композитный индекс для поиска активных квестов с сортировкой по дате создания
    op.create_index(
        'idx_quest_active_created',
        'quest',
        ['created_at'],
        postgresql_using='btree'
    )
    
    # Индекс для быстрого поиска по времени (timeframe)
    op.create_index(
        'idx_quest_timeframe',
        'quest',
        ['timeframe'],
        postgresql_using='btree',
        postgresql_where="timeframe IS NOT NULL"
    )
    
    # Композитный индекс для комплексного поиска
    # (категория + уровень + место + группа)
    op.create_index(
        'idx_quest_complex_search',
        'quest',
        ['category_id', 'level', 'place_id', 'group'],
        postgresql_using='btree'
    )
    
    # Индекс для поиска квестов по пробегу
    op.create_index(
        'idx_quest_milage',
        'quest',
        ['milage'],
        postgresql_using='btree'
    )
    
    # Индексы для связанных таблиц - ускорение JOIN'ов
    
    # Индекс для поиска отзывов по квесту (для вычисления рейтинга)
    op.create_index(
        'idx_review_quest_rating',
        'review',
        ['quest_id', 'rating'],
        postgresql_using='btree'
    )
    
    # Индекс для поиска избранных квестов пользователя
    op.create_index(
        'idx_favorite_user_quest',
        'favorite',
        ['user_id', 'quest_id'],
        postgresql_using='btree'
    )
    
    # Полнотекстовый поиск по названию и описанию квеста
    # Создаем GIN индекс для быстрого полнотекстового поиска
    op.execute("""
        CREATE INDEX idx_quest_fulltext_search 
        ON quest 
        USING gin(to_tsvector('russian', name || ' ' || description))
    """)


def downgrade() -> None:
    """Удаляем производительные индексы."""
    
    # Удаляем все созданные индексы
    op.drop_index('idx_quest_category_level', table_name='quest')
    op.drop_index('idx_quest_place_group', table_name='quest')
    op.drop_index('idx_quest_cost', table_name='quest')
    op.drop_index('idx_quest_subscription', table_name='quest')
    op.drop_index('idx_quest_active_created', table_name='quest')
    op.drop_index('idx_quest_timeframe', table_name='quest')
    op.drop_index('idx_quest_complex_search', table_name='quest')
    op.drop_index('idx_quest_milage', table_name='quest')
    
    # Удаляем индексы связанных таблиц
    op.drop_index('idx_review_quest_rating', table_name='review')
    op.drop_index('idx_favorite_user_quest', table_name='favorite')
    
    # Удаляем полнотекстовый индекс
    op.drop_index('idx_quest_fulltext_search', table_name='quest')
