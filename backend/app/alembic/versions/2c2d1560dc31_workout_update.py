"""workout update

Revision ID: 2c2d1560dc31
Revises: 8c7ea9b88a28
Create Date: 2022-06-19 06:56:30.233400-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '2c2d1560dc31'
down_revision = '8c7ea9b88a28'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()

    op.drop_table("workout")
    pass


def downgrade():
    pass


