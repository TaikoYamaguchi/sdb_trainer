import datetime

from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas
from app.core.security import get_password_hash
from app.core.sms import send_pro_sms


def get_user(db: Session, user_id: int):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


def get_users(
    db: Session, skip: int = 0, limit: int = 100
) -> t.List[schemas.UserOut]:
    return db.query(models.User).all()

def get_pros(
    db: Session, skip: int = 0, limit: int = 500
) -> t.List[schemas.ProOut]:
    return db.query(models.User).filter(models.User.isPro == True).order_by(models.User.point.desc()).all()

def get_pros_random(
    db: Session, skip: int = 0, limit: int = 500
) -> t.List[schemas.ProOut]:
    return db.query(models.User).filter(models.User.isPro == True).order_by(func.random()).all()

def get_pro_by_email(db: Session,email:str) -> schemas.ProOut:
    return db.query(models.User).filter(models.User.email == email).first()

def get_user_by_email(db: Session, email: str) -> schemas.UserBase:
    return db.query(models.User).filter(models.User.email == email).first()

def get_phone_number_by_email(db: Session, email: str) -> schemas.UserCreate:
    return db.query(models.User).filter(models.User.email == email).first()

def get_user_by_phone_number(db: Session, phone_number: str) -> schemas.UserBase:
    return db.query(models.User).filter(models.User.phone_number == phone_number).first()


def get_user_by_nickname(db: Session, nickname: str) -> schemas.UserBase:
    return db.query(models.User).filter(models.User.nickname == nickname).first()


def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = models.User(
        email=user.email,
        phone_number=user.phone_number,
        nickname=user.nickname,
        level=1,
        point=0,
        image=user.image,
        selfIntroduce=user.selfIntroduce,
        is_active=True,
        is_superuser=False,
        hashed_password=hashed_password,
        created_at=datetime.datetime.utcnow()+datetime.timedelta(hours=9),
        post_cnt=0,
        comment_cnt=0,
        reply_cnt=0,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_lesson(db: Session, lesson: schemas.LessonBase,ip:str ):
    db_lesson = models.Lesson(
        clientEmail=lesson.clientEmail,
        clientNickname=lesson.clientNickname,
        proEmail=lesson.proEmail,
        proNickname=lesson.proNickname,
        proName=lesson.proName,
        lessonInfo=lesson.lessonInfo,
        lessonScore=lesson.lessonScore,
        lessonRegion=lesson.lessonRegion,
        lessonPoint=lesson.lessonPoint,
        lessonClub=lesson.lessonClub,
        lessonPhone=lesson.lessonPhone,
        ip=ip,
        created_at=datetime.datetime.utcnow() + datetime.timedelta(hours=9),
    )
    db.add(db_lesson)
    db.commit()
    db.refresh(db_lesson)
    db_mail = models.Mail(
        fromEmail="ipgolf@ipgolf.co.kr",
        fromNickname="입골프운영팀",
        toEmail=lesson.proEmail,
        toNickname=lesson.proNickname,
        title="레슨 문의가 있습니다.",
        category="lesson",
        lessonInfo=lesson.lessonInfo,
        lessonScore=lesson.lessonScore,
        lessonRegion=lesson.lessonRegion,
        lessonPoint=lesson.lessonPoint,
        lessonClub=lesson.lessonClub,
        lessonPhone=lesson.lessonPhone,
        isRead=False,
        ip=ip,
        created_at=datetime.datetime.utcnow() + datetime.timedelta(hours=9),
    )
    db.add(db_mail)
    db.commit()
    db.refresh(db_mail)
    pro = get_phone_number_by_email(db, lesson.proEmail)
    send_pro_sms(pro.phone_number)

    return db_lesson


def delete_user(db: Session, user_id: int):
    user = get_user(db, user_id)
    if not user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    db.delete(user)
    db.commit()
    return user


def edit_user(
    db: Session, email: str, user: schemas.UserEdit
) -> schemas.User:
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

def edit_pro(
    db: Session, email: str, user: schemas.ProEdit
) -> schemas.ProOut:
    db_user = get_pro_by_email(db, email)
    if not db_user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    update_data = user.dict(exclude_unset=True)
    if db_user.recommender != user.recommender:
        edit_user_point(db, email,"recommender"   )
        if user.recommender:
            edit_user_point(db, user.recommender,"referrer"   )

    print(db_user.recommender)
    print(user.recommender)

    for key, value in update_data.items():
        setattr(db_user, key, value)

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def edit_user_point(
    db: Session, email: str, method: str
) -> schemas.User:
    db_user = get_user_by_email(db, email)
    if not db_user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")

    if method == "write_post" :
        setattr(db_user, "point", db_user.point+20)
    if method == "delete_post" :
        setattr(db_user, "point", db_user.point-20)
    elif method == "write_comment" :
        setattr(db_user, "point", db_user.point+5)
    elif method == "delete_comment" :
        setattr(db_user, "point", db_user.point-5)
    elif method == "like_post" :
        setattr(db_user, "point", db_user.point+10)
    elif method == "delike_post" :
        setattr(db_user, "point", db_user.point-10)
    elif method == "like_comment" :
        setattr(db_user, "point", db_user.point+3)
    elif method == "delike_comment" :
        setattr(db_user, "point", db_user.point-3)
    elif method == "post_liked" :
        setattr(db_user, "point", db_user.point+10)
    elif method == "post_deliked" :
        setattr(db_user, "point", db_user.point-10)
    elif method == "comment_liked" :
        setattr(db_user, "point", db_user.point+5)
    elif method == "comment_deliked" :
        setattr(db_user, "point", db_user.point-5)
    elif method == "recommender":
        setattr(db_user, "point", db_user.point+30)
    elif method == "referrer":
        setattr(db_user, "point", db_user.point+100)

    print(db_user.point)
    print(db_user.level)

    if db_user.point <= 500 and db_user.level != 1:
        setattr(db_user, "level", 1)
    elif  500 < db_user.point <= 1500 and db_user.level != 2:
        setattr(db_user, "level", 2)
    elif  1500 < db_user.point <= 3000 and db_user.level != 3:
        setattr(db_user, "level", 3)
    elif  3000 < db_user.point <= 7000 and db_user.level != 4:
        setattr(db_user, "level", 4)
    elif  7000 < db_user.point and db_user.level != 5:
        setattr(db_user, "level", 5)

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
