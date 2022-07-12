from app.core.sms import verification_user
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
        favor_exercise=[],
        selfIntroduce="",
        history_cnt=0,
        comment_cnt=0,
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

def get_users_by_nickname(db: Session, nickname: str) -> t.List[schemas.UserOut]:
    return db.query(models.User).filter(models.User.nickname.contains(nickname)).all()


def get_user_by_phone_number(db: Session, phone_number: str) -> schemas.UserBase:
    return db.query(models.User).filter(models.User.phone_number == phone_number).first()

def get_user_by_sms_verifiaction(db: Session, sms:schemas.FindUserCode) -> schemas.UserBase:
    status = verification_user(sms.phone_number, sms.verifyCode)
    if status == "approved":
        return db.query(models.User).filter(models.User.phone_number == sms.phone_number).first()

def get_friends_by_email(db: Session, email: str) -> t.List[schemas.UserBase]:
    user = db.query(models.User).filter(models.User.email==email).first()
    print(user.email)
    return db.query(models.User).filter(models.User.email.in_(user.like)).all()

def edit_user(
    db: Session, email: str, user: schemas.UserBase
) -> schemas.UserBase:
    db_nickname = get_user_by_nickname(db,user.nickname)
    if db_nickname:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="닉네임이 중복 됐습니다")

    db_user = get_user_by_email(db, email)
    if not db_user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    update_data = user.dict(exclude_unset=True)

    for key, value in update_data.items():
        setattr(db_user, key, value)

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def manage_like_by_liked_email(db: Session,likeContent:schemas.ManageLikeUser) -> schemas.UserOut:
    db_user = db.query(models.User).filter(models.User.email == likeContent.email).first()
    if likeContent.disorlike == "like": 
        if likeContent.status == "append":
            db_user.like.append(likeContent.liked_email)
        if likeContent.status == "remove":
            db_user.like.remove(likeContent.liked_email)
        setattr(db_user, "like", db_user.like)
    if likeContent.disorlike == "dislike": 
        if likeContent.status == "append":
            db_user.dislike.append(likeContent.liked_email)
        if likeContent.status == "remove":
            db_user.dislike.remove(likeContent.liked_email)
        setattr(db_user, "dislike", db_user.dislike)
    db.commit()
    db.refresh(db_user)
    return db_user

def edit_image_by_user_email(db: Session,user:schemas.User, image_id : int) -> schemas.UserOut:
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    setattr(db_user, "image", f"http://43.200.121.48:8000/api/images/{image_id}")
    db.commit()
    db.refresh(db_user)
    return db_user




