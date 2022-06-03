"""isMan

Revision ID: ef82ee932943
Revises: 91979b40eb38
Create Date: 2022-04-10 17:36:20.071209

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'ef82ee932943'
down_revision = '91979b40eb38'
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
    if not table_has_column("user", "isMan"):
        op.add_column("user", sa.Column("isMan", sa.ARRAY(sa.String)))

    pass


def downgrade():
    pass


