"""history_nickname

Revision ID: 5527ccd0ca75
Revises: 0620ce90fc8c
Create Date: 2022-06-14 07:31:52.667570-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '5527ccd0ca75'
down_revision = '0620ce90fc8c'
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

    if not table_has_column("history", "nickname"):
        op.add_column("history", sa.Column("nickname", sa.String, nullable=True))

    pass


def downgrade():
    pass


