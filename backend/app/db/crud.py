import datetime

from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas
from app.core.security import get_password_hash


def get_user(db: Session, user_id: int):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

def get_users(
    db: Session, skip: int = 0, limit: int = 100
) -> t.List[schemas.UserOut]:
    return db.query(models.User).all()

def create_user(db: Session, user: schemas.UserCreate):
    db_nickname = get_user_by_nickname(db,user.nickname)
    if db_nickname:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="닉네임이 중복 됐습니다")
    db_email= get_user_by_email(db,user.email)
    if db_email:
        raise HTTPException(status.HTTP_403_NOT_FOUND, detail="이메일이 중복 됐습니다")
    hashed_password = get_password_hash(user.password)
    db_user = models.User(
        email=user.email,
        nickname=user.nickname,
        username=user.username,
        phone_number=user.phone_number,
        level=1,
        point=0,
        height=user.height,
        weight=user.weight,
        height_unit=user.height_unit,
        weight_unit=user.weight_unit,
        image=user.image,
        isMan=user.isMan,
        is_active=True,
        is_superuser=False,
        like=[],
        dislike=[],
        hashed_password=hashed_password,
        created_at=datetime.datetime.utcnow()+datetime.timedelta(hours=9),
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def get_user_by_email(db: Session, email: str) -> schemas.UserBase:
    return db.query(models.User).filter(models.User.email == email).first()

def get_user_by_nickname(db: Session, nickname: str) -> schemas.UserBase:
    return db.query(models.User).filter(models.User.nickname == nickname).first()


def get_user_by_phone_number(db: Session, phone_number: str) -> schemas.UserBase:
    return db.query(models.User).filter(models.User.phone_number == phone_number).first()

def edit_user(
    db: Session, email: str, user: schemas.UserEdit
) -> schemas.UserBase:
    db_nickname = get_user_by_nickname(db,user.nickname)
    if db_nickname:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="닉네임이 중복 됐습니다")

    db_user = get_user_by_email(db, email)
    if not db_user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    update_data = user.dict(exclude_unset=True)

    if user.password != "":
        update_data["hashed_password"] = get_password_hash(user.password)
        del update_data["password"]

    for key, value in update_data.items():
        setattr(db_user, key, value)

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


