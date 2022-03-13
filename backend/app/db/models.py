from app.db.sqlal_mutable_array import MutableList
from sqlalchemy import Boolean, Column, Integer, String, Text, DateTime, ARRAY, Float

from .session import Base

class User(Base):
    __tablename__ = "user"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    nickname = Column(String, unique=True, index=True, nullable=False)
    selfIntroduce = Column(String, index=True, nullable=True)
    phone_number= Column(String, unique=True, index=True, nullable=False)
    image= Column(String, nullable=True)
    created_at = Column(DateTime, nullable=False)
    level = Column(Integer, nullable=False)
    point = Column(Integer, nullable=False)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    procareer = Column(String, nullable=True)
    proname = Column(String, nullable=True)
    isPro = Column(Boolean, nullable=False, default=False)
    address = Column(String, nullable=True)
    lat = Column(Float, nullable=True)
    lng = Column(Float, nullable=True)
    lecture_time = Column(Float, nullable=True)
    lecture_fee = Column(Float, nullable=True)
    lecture_count = Column(Integer, nullable=True)
    isMan = Column(String,nullable=True)
    recommender = Column(String, nullable=True)
    referrer = Column(ARRAY(String), nullable=True)
    post_cnt = Column(Integer, nullable=False)
    comment_cnt = Column(Integer, nullable=False)
    reply_cnt = Column(Integer, nullable=False)



