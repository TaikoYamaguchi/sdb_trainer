"""create_notification_table

Revision ID: 3de82dbf4ebd
Revises: 843af8054732
Create Date: 2023-07-01 01:23:26.504626-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '3de82dbf4ebd'
down_revision = '843af8054732'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()

    if "notification" not in tables:
                op.create_table(
                    "notification",
                    sa.Column("id", sa.Integer, primary_key=True),
                    sa.Column("title", sa.String(50), nullable=False),
                    sa.Column("content", JSONB),
                    sa.Column("images", sa.ARRAY(sa.String), nullable=True),
                    sa.Column("ispopup", sa.Boolean, default=False),
                    sa.Column("date", sa.DateTime, nullable=False),
                )



    pass


def downgrade():
    pass


