"""comment_image_video

Revision ID: 8c7ea9b88a28
Revises: 5527ccd0ca75
Create Date: 2022-06-19 19:06:47.527603

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector


# revision identifiers, used by Alembic.
revision = '8c7ea9b88a28'
down_revision = '5527ccd0ca75'
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

    if not table_has_column("user", "selfIntroduce"):
        op.add_column("user", sa.Column("selfIntroduce", sa.String, nullable=True,server_default=""))

    if not table_has_column("user", "history_cnt"):
        op.add_column("user", sa.Column("history_cnt", sa.Integer, nullable=False,server_default="0"))

    if not table_has_column("user", "comment_cnt"):
        op.add_column("user", sa.Column("comment_cnt", sa.Integer, nullable=False,server_default="0"))

    if not table_has_column("history", "comment_length"):
        op.add_column("history", sa.Column("comment_length", sa.Integer, nullable=False,server_default="0"))

    if not table_has_column("history", "ip"):
        op.add_column("history", sa.Column("ip", sa.String, nullable=True))

    if not table_has_column("history", "isVisible"):
        op.add_column("history", sa.Column("isVisible", sa.Boolean, nullable=False, server_default="True"))

    if "comment" not in tables:
        op.create_table(
            "comment",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("history_id", sa.Integer, nullable=False),
            sa.Column("reply_id", sa.Integer, nullable=False),
            sa.Column("writer_email", sa.String(50), nullable=False),
            sa.Column("writer_nickname", sa.String(50), nullable=False),
            sa.Column("content", sa.Text, nullable=False),
            sa.Column("likes", sa.ARRAY(sa.String)),
            sa.Column("dislikes", sa.ARRAY(sa.String)),
            sa.Column("password", sa.String, nullable=True),
            sa.Column("comment_created_at", sa.DateTime, nullable=False),
            sa.Column("comment_modified_at", sa.DateTime, nullable=False),
            sa.Column("ip", sa.String, nullable=True),
        )

    if "temporaryVideo" not in tables:
        op.create_table(
            "temporaryVideo",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("video", sa.String, nullable=True),
            sa.Column("views", sa.Integer, nullable=True),
        )

    if "temporaryImage" not in tables:
        op.create_table(
            "temporaryImage",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("image", sa.String, nullable=True),
            sa.Column("views", sa.Integer, nullable=True),
        )

    pass


def downgrade():
    pass


