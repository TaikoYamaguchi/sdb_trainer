"""user date_weight

Revision ID: 88f971406917
Revises: bdb32e0fab7e
Create Date: 2022-10-09 05:01:35.960954-07:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '88f971406917'
down_revision = 'bdb32e0fab7e'
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
   if not table_has_column("user", "body_stats"):
        op.add_column("user", sa.Column("body_stats", JSONB))



def downgrade():
    pass


