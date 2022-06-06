"""favor_exercise

Revision ID: 0620ce90fc8c
Revises: c15a5d6c04f6
Create Date: 2022-06-04 09:07:23.677473-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '0620ce90fc8c'
down_revision = 'c15a5d6c04f6'
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
    if not table_has_column("user", "favor_exercise"):
        op.add_column("user", sa.Column("favor_exercise", sa.ARRAY(sa.String)))


    pass


def downgrade():
    pass


