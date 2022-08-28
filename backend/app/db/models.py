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
    liked = Column(MutableList.as_mutable(ARRAY(String)))
    dislike = Column(MutableList.as_mutable(ARRAY(String)))
    disliked = Column(MutableList.as_mutable(ARRAY(String)))
    favor_exercise = Column(MutableList.as_mutable(ARRAY(String)))
    selfIntroduce = Column(String, nullable=True)
    history_cnt = Column(Integer, nullable=False)
    comment_cnt = Column(Integer, nullable=False)
    
    
class Workout(Base):
    __tablename__ = "workout"
    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, unique=True, index=True, nullable=False)
    routinedatas = Column(JSON, index=True, nullable=False)
    date = Column(DateTime, nullable=False)

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
    nickname = Column(String,unique=True, index=True,  nullable=False)
    comment_length = Column(Integer, nullable=False)
    isVisible = Column(Boolean, nullable=False, default=True)
    ip = Column(String, nullable=True)

class Exercises(Base):
    __tablename__ = "exercises"
    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, unique=True, index=True, nullable=False)
    exercises = Column(JSON, index=True, nullable=False)
    date = Column(DateTime, nullable=False)
    modified_number = Column(Integer, nullable=False)

class Comment(Base):
    __tablename__ = "comment"
    id = Column(Integer, primary_key=True, index=True)
    history_id = Column(Integer, nullable=False)
    reply_id = Column(Integer, nullable=False)
    writer_email = Column(String, nullable=False)
    writer_nickname = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    likes = Column(MutableList.as_mutable(ARRAY(String)))
    dislikes = Column(MutableList.as_mutable(ARRAY(String)))
    password = Column(String, nullable=True)
    comment_created_at = Column(DateTime, nullable=False)
    comment_modified_at = Column(DateTime, nullable=False)
    ip = Column(String, nullable=True)

class TemporaryImage(Base):
    __tablename__ = "temporaryImage"
    id = Column(Integer, primary_key=True, index=True)
    image= Column(String, nullable=True)
    views= Column(Integer, nullable=True)

class TemporaryVideo(Base):
    __tablename__ = "temporaryVideo"
    id = Column(Integer, primary_key=True, index=True)
    video= Column(String, nullable=True)
    views= Column(Integer, nullable=True)

class Version(Base):
    __tablename__ = "version"
    version_num= Column(String, primary_key=True, nullable=False)

class Famous(Base):
    __tablename__ = "famous"
    id = Column(Integer, primary_key=True, index=True)
    type = Column(Integer, nullable=False)
    user_email = Column(String, unique=True, index=True, nullable=False)
    image = Column(MutableList.as_mutable(ARRAY(String)))
    routinedata = Column(DateTime, nullable=False)
    date = Column(DateTime, nullable=False)
