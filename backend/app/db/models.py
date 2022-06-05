from sqlalchemy.dialects.postgresql.json import JSON
from app.db.sqlal_mutable_array import MutableList
from sqlalchemy import Boolean, Column, Integer, String, Text, DateTime, ARRAY, Float
from sqlalchemy.dialects.postgresql import JSONB

from .session import Base

class User(Base):
    __tablename__ = "user"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    username = Column(String, index=True, nullable=False)
    nickname = Column(String, unique=True, index=True, nullable=False)
    phone_number= Column(String, unique=True, index=True, nullable=False)
    height = Column(Float, nullable=False)
    weight = Column(Float, nullable=False)
    height_unit = Column(String, nullable=False)
    weight_unit = Column(String, nullable=False)
    created_at = Column(DateTime, nullable=False)
    image= Column(String, nullable=True)
    level = Column(Integer, nullable=False)
    point = Column(Integer, nullable=False)
    isMan = Column(Boolean, nullable=False, default=True)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    like = Column(MutableList.as_mutable(ARRAY(String)))
    dislike = Column(MutableList.as_mutable(ARRAY(String)))
    favor_exercise = Column(MutableList.as_mutable(ARRAY(String)))
    
    
class Workout(Base):
    __tablename__ = "workout"
    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, unique=True, index=True, nullable=False)
    exercises = Column(JSON, index=True, nullable=False)
    date = Column(DateTime, nullable=False)
    routine_time = Column(Float, nullable=False)

class History(Base):
    __tablename__ = "history"
    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, unique=True, index=True, nullable=False)
    exercises = Column(JSON, index=True, nullable=False)
    date = Column(DateTime, nullable=False)
    new_record = Column(Integer, nullable=False)
    workout_time = Column(Integer, nullable=False)
    like = Column(MutableList.as_mutable(ARRAY(String)))
    dislike = Column(MutableList.as_mutable(ARRAY(String)))
    image = Column(MutableList.as_mutable(ARRAY(String)))
    comment = Column(String)

class Exercises(Base):
    __tablename__ = "exercises"
    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, unique=True, index=True, nullable=False)
    exercises = Column(JSON, index=True, nullable=False)
    date = Column(DateTime, nullable=False)
    modified_number = Column(Integer, nullable=False)
