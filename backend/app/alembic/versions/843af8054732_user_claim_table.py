"""user_claim_table

Revision ID: 843af8054732
Revises: d6670fe01a23
Create Date: 2022-12-31 00:18:19.639137

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '843af8054732'
down_revision = 'd6670fe01a23'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()

    if "interview" not in tables:
        op.create_table(
            "interview",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("user_email", sa.String(50), nullable=False),
            sa.Column("user_nickname", sa.String(50), nullable=False),
            sa.Column("progress", sa.String(50), nullable=False),
            sa.Column("title", sa.String(50), nullable=True),
            sa.Column("content", sa.String, nullable=False),
            sa.Column("like", sa.ARRAY(sa.String), nullable=True),
            sa.Column("date", sa.DateTime, nullable=False),
            sa.Column("reply_id", sa.Integer, nullable=True),
            sa.Column("modified_number", sa.Integer, nullable=False),
            sa.Column("ip", sa.String(50), nullable=False),
        )

def downgrade():
    pass


