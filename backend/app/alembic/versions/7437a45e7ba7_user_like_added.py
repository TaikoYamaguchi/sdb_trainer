"""user_like_added

Revision ID: 7437a45e7ba7
Revises: acbb1ca8c773
Create Date: 2022-07-24 02:15:11.089682-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '7437a45e7ba7'
down_revision = 'acbb1ca8c773'
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

    if not table_has_column("user", "liked"):
        op.add_column("user", sa.Column("liked", sa.ARRAY(sa.String), server_default='{}'))
    if not table_has_column("user", "disliked"):
        op.add_column("user", sa.Column("disliked", sa.ARRAY(sa.String), server_default='{}'))

    pass


def downgrade():
    pass


