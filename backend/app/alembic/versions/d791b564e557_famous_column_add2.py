"""famous_column_add2

Revision ID: d791b564e557
Revises: 75c98ce9a86f
Create Date: 2022-09-05 21:17:48.655589

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'd791b564e557'
down_revision = '75c98ce9a86f'
branch_labels = None
depends_on = None


def table_has_column(table, column):
    conn = op.get_bind()
    insp = Inspector.from_engine(conn)
    has_column = False
    for col in insp.get_columns(table):
        if column not in col['name']:
            continue
        has_column = True
    return has_column


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()

    if not table_has_column("famous", "category"):
            op.add_column("famous", sa.Column("category", sa.Integer, nullable=True))


    pass


def downgrade():
    pass
