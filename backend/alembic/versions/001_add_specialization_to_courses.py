"""Add specialization column to courses

Revision ID: 001
Revises: 
Create Date: 2026-01-21 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add specialization column to courses table if it doesn't exist
    op.add_column('courses', sa.Column('specialization', sa.String(100), nullable=True))
    # Create index on specialization column
    op.create_index('ix_courses_specialization', 'courses', ['specialization'])


def downgrade() -> None:
    # Drop index and column
    op.drop_index('ix_courses_specialization', table_name='courses')
    op.drop_column('courses', 'specialization')
