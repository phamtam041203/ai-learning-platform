"""Alembic environment configuration"""

from dotenv import load_dotenv
load_dotenv()

from alembic import context
from sqlalchemy import engine_from_config, pool

from app.config import settings
from app.database import Base

# Import models để Alembic nhận metadata
from app.models import user, course, learning_activity, assessment, recommendation

config = context.config

# Set DB URL từ settings
config.set_main_option(
    "sqlalchemy.url",
    settings.DATABASE_URL
)

target_metadata = Base.metadata


def run_migrations_online():
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,   # optional nhưng nên có
        )

        with context.begin_transaction():
            context.run_migrations()


run_migrations_online()
