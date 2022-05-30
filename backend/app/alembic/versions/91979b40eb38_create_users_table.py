"""create users table

Revision ID: 91979b40eb38
Revises: 
Create Date: 2020-03-23 14:53:53.101322

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
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

    if "user" not in tables:
        op.create_table(
            "user",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("email", sa.String(50), nullable=False, unique=True),
            sa.Column("hashed_password", sa.String(100), nullable=False),
            sa.Column("username", sa.String(50), nullable=False),
            sa.Column("nickname", sa.String(50), nullable=False, unique=True),
            sa.Column("phone_number", sa.String(20), nullable=False),
            sa.Column("height", sa.Float, nullable=False),
            sa.Column("weight", sa.Float, nullable=False),
            sa.Column("height_unit", sa.String, nullable=False),
            sa.Column("weight_unit", sa.String, nullable=False),
            sa.Column("created_at", sa.DateTime, nullable=True),
            sa.Column("image", sa.String, nullable=True),
            sa.Column("level", sa.Integer, nullable=False),
            sa.Column("point", sa.Integer, nullable=False),
            sa.Column("is_active", sa.Boolean, default=True),
            sa.Column("is_superuser", sa.Boolean, default=False)
        )
    if "workout" not in tables:
        op.create_table(
            "workout",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("user_email", sa.String(50), nullable=False),
            sa.Column("name", sa.String(50), nullable=False),
            sa.Column("exercises", JSONB),
            sa.Column("date", sa.DateTime, nullable=False),
            sa.Column("routine_time", sa.Float, nullable=False)
        )

    if "history" not in tables:
        op.create_table(
            "history",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("user_email", sa.String(50), nullable=False),
            sa.Column("exercises", JSONB),
            sa.Column("date", sa.DateTime, nullable=False),
            sa.Column("new_record", sa.Integer, nullable=False),
            sa.Column("workout_time", sa.Integer, nullable=False)
        )
    if "exercises" not in tables:
        op.create_table(
            "exercises",
            sa.Column("id", sa.Integer, primary_key=True),
            sa.Column("user_email", sa.String(50), nullable=False),
            sa.Column("exercises", JSONB),
            sa.Column("date", sa.DateTime, nullable=False),
            sa.Column("modified_number", sa.Float, nullable=False)
        )


def downgrade():
    op.drop_table("user")
    op.drop_table("workout")
    op.drop_table("history")
    op.drop_table("exercises")
