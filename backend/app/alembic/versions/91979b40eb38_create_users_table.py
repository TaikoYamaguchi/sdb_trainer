"""create users table

Revision ID: 91979b40eb38
Revises: 
Create Date: 2020-03-23 14:53:53.101322

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector

# revision identifiers, used by Alembic.
revision = "91979b40eb38"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    conn = op.get_bind()
    inspector = Inspector.from_engine(conn)
    tables = inspector.get_table_names()


    if "reply" not in tables:
        op.create_table(
            "reply",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("post_id", sa.Integer, nullable=False),
            sa.Column("writer_email", sa.String(50), nullable=False),
            sa.Column("writer_nickname", sa.String(50), nullable=False),
            sa.Column("content", sa.Text, nullable=False),
            sa.Column("likes", sa.ARRAY(sa.String)),
            sa.Column("dislikes", sa.ARRAY(sa.String)),
            sa.Column("post_created_at", sa.DateTime, nullable=False),
            sa.Column("post_modified_at", sa.DateTime, nullable=False)
        )
    if "comment" not in tables:
        op.create_table(
            "comment",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("post_id", sa.Integer, nullable=False),
            sa.Column("reply_id", sa.Integer, nullable=False),
            sa.Column("writer_email", sa.String(50), nullable=False),
            sa.Column("writer_nickname", sa.String(50), nullable=False),
            sa.Column("content", sa.Text, nullable=False),
            sa.Column("likes", sa.ARRAY(sa.String)),
            sa.Column("dislikes", sa.ARRAY(sa.String)),
            sa.Column("password", sa.String, nullable=True),
            sa.Column("isAnonymous", sa.Boolean, nullable=False),
            sa.Column("post_created_at", sa.DateTime, nullable=False),
            sa.Column("post_modified_at", sa.DateTime, nullable=False)
        )
    if "user" not in tables:
        op.create_table(
            "user",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("email", sa.String(50), nullable=False),
            sa.Column("hashed_password", sa.String(100), nullable=False),
            sa.Column("nickname", sa.String(50), nullable=False),
            sa.Column("phone_number", sa.String(20), nullable=False),
            sa.Column("image", sa.String, nullable=True),
            sa.Column("selfIntroduce", sa.String, nullable=True),
            sa.Column("created_at", sa.DateTime, nullable=True),
            sa.Column("level", sa.Integer, nullable=False),
            sa.Column("point", sa.Integer, nullable=False),
            sa.Column("is_active", sa.Boolean, default=True),
            sa.Column("is_superuser", sa.Boolean, default=False)
        )
    if "post" not in tables:
        op.create_table(
            "post",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("writer_email", sa.String(50), nullable=False),
            sa.Column("writer_nickname", sa.String(50), nullable=False),
            sa.Column("title", sa.Text, nullable=False),
            sa.Column("content", sa.Text, nullable=False),
            sa.Column("category", sa.String(30), nullable=False),
            sa.Column("views", sa.Integer, nullable=False),
            sa.Column("likes", sa.ARRAY(sa.String)),
            sa.Column("dislikes", sa.ARRAY(sa.String)),
            sa.Column("tags", sa.ARRAY(sa.String)),
            sa.Column("password", sa.String, nullable=True),
            sa.Column("isAnonymous", sa.Boolean, nullable=False),
            sa.Column("post_created_at", sa.DateTime, nullable=False),
            sa.Column("post_modified_at", sa.DateTime, nullable=False)
        )


def downgrade():
    op.drop_table("user")
    op.drop_table("post")
