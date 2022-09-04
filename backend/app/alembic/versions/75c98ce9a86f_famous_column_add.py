"""famous_column_add

Revision ID: 75c98ce9a86f
Revises: ee85ef9960c7
Create Date: 2022-09-04 13:31:29.195301

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '75c98ce9a86f'
down_revision = 'ee85ef9960c7'
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

    if not table_has_column("famous", "like"):
            op.add_column("famous", sa.Column("like", sa.ARRAY(sa.String), server_default='{}'))
    if not table_has_column("famous", "dislike"):
            op.add_column("famous", sa.Column("dislike", sa.ARRAY(sa.String), server_default='{}'))
    if not table_has_column("famous", "level"):
            op.add_column("famous", sa.Column("level", sa.Integer, nullable=False))
    if not table_has_column("famous", "subscribe"):
            op.add_column("famous", sa.Column("subscribe", sa.Integer, nullable=False))

    pass


def downgrade():
    pass


