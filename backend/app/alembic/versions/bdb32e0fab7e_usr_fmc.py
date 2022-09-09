"""usr FMC

Revision ID: bdb32e0fab7e
Revises: d791b564e557
Create Date: 2022-09-09 21:46:56.696152

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = 'bdb32e0fab7e'
down_revision = 'd791b564e557'
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

    if not table_has_column("user", "fcm_token"):
        op.add_column("user", sa.Column("fcm_token", sa.String(50), server_default='', nullable=True))
    pass


def downgrade():
    pass


