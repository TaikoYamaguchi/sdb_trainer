"""famous_column_alter

Revision ID: d6670fe01a23
Revises: 88f971406917
Create Date: 2022-10-22 17:34:43.077767

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'd6670fe01a23'
down_revision = '88f971406917'
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

    op.drop_column("famous", "category")
    if not table_has_column("famous", "category"):
                op.add_column("famous", sa.Column("category", sa.ARRAY(sa.String), server_default='{}'))

    pass


def downgrade():
    pass


