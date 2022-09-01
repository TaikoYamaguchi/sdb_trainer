"""famous_fix2

Revision ID: ee85ef9960c7
Revises: 0b63fa5ef490
Create Date: 2022-09-01 21:45:21.890980

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'ee85ef9960c7'
down_revision = '0b63fa5ef490'
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




def downgrade():
    op.drop_table("famous")



