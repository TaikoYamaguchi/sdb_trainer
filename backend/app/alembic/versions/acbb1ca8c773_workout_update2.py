"""workout update2

Revision ID: acbb1ca8c773
Revises: 2c2d1560dc31
Create Date: 2022-06-19 08:03:02.583442-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'acbb1ca8c773'
down_revision = '2c2d1560dc31'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()

    if "workout" not in tables:
            op.create_table(
                "workout",
                sa.Column("id", sa.Integer, primary_key=True),
                sa.Column("user_email", sa.String(50), nullable=False),
                sa.Column("routinedatas", JSONB),
                sa.Column("date", sa.DateTime, nullable=False),
            )
    pass


def downgrade():
    pass


