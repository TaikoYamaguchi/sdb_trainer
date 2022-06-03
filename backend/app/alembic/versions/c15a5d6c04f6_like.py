"""like

Revision ID: c15a5d6c04f6
Revises: ef82ee932943
Create Date: 2022-06-03 08:25:38.590936-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'c15a5d6c04f6'
down_revision = 'ef82ee932943'
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
    if not table_has_column("user", "like"):
        op.add_column("user", sa.Column("like", sa.ARRAY(sa.String)))
    if not table_has_column("user", "dislike"):
        op.add_column("user", sa.Column("dislike", sa.ARRAY(sa.String)))
    if not table_has_column("history", "like"):
        op.add_column("history", sa.Column("like", sa.ARRAY(sa.String)))
    if not table_has_column("history", "dislike"):
        op.add_column("history", sa.Column("dislike", sa.ARRAY(sa.String)))
    if not table_has_column("history", "image"):
        op.add_column("history", sa.Column("image", sa.ARRAY(sa.String)))
    if not table_has_column("history", "comment"):
        op.add_column("history", sa.Column("comment", sa.String))
    pass


def downgrade():
    pass


