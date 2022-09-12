"""famous

Revision ID: bd64108238db
Revises: 1a2d1b08a456
Create Date: 2022-08-28 07:19:12.540089-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'bd64108238db'
down_revision = '1a2d1b08a456'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()

    if "famous" not in tables:
            op.create_table(
                "famous",
                sa.Column("id", sa.Integer, primary_key=True),
                sa.Column("type", sa.Integer, nullable=False),
                sa.Column("user_email", sa.String(50), nullable=False),
                sa.Column("image", sa.String(50), nullable=True),
                sa.Column("routinedata", JSONB),
                sa.Column("date", sa.DateTime, nullable=False),
            )


    pass


def downgrade():
    pass


