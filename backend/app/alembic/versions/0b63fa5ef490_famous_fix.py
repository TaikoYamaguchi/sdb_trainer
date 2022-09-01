"""famous_fix

Revision ID: 0b63fa5ef490
Revises: 756849a7d396
Create Date: 2022-09-01 21:32:16.590549

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '0b63fa5ef490'
down_revision = '756849a7d396'
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


