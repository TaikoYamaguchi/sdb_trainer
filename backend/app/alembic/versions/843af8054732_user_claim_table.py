"""user_claim_table

Revision ID: 843af8054732
Revises: d6670fe01a23
Create Date: 2022-12-31 00:18:19.639137

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '843af8054732'
down_revision = 'd6670fe01a23'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()

    pass


def downgrade():
    pass


