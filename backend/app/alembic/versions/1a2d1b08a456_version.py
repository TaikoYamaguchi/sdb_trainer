"""version

Revision ID: 1a2d1b08a456
Revises: 7437a45e7ba7
Create Date: 2022-08-25 20:40:42.473693

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '1a2d1b08a456'
down_revision = '7437a45e7ba7'
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()

    if "version" not in tables:
            op.create_table(
                "version",
                sa.Column("version_num", sa.String(50), nullable=False, server_default="0.1.0"),
            )

    pass


def downgrade():
    pass


