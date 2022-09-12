import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas


def create_famous(db: Session, famous: schemas.FamousCreate):
    print(famous.user_email)
    db_famous = models.Famous(
        type=famous.type,
        user_email=famous.user_email,
        image=famous.image,
        routinedata = famous.routinedata,
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
        like=[],
        dislike=[],
        level=famous.level,
        subscribe=famous.subscribe,
        category=famous.category
    )
    print(famous.user_email)
    db.add(db_famous)
    db.commit()
    db.refresh(db_famous)
    return db_famous

def get_famouss_by_type(db: Session, type: int) -> t.List[schemas.FamousOut]:
    famouss = db.query(models.Famous).filter(models.Famous.type == type).all()
    return famouss

def get_famouss(db: Session) -> t.List[schemas.FamousOut]:
    famouss = db.query(models.Famous).order_by(models.Famous.id.desc()).all()
    return famouss


def get_famouss_by_id(db: Session, input_id: int) -> schemas.FamousOut:
    famous = db.query(models.Famous).filter(models.Famous.id == input_id).first()
    print(famous)
    return famous

def edit_famous(db: Session, famous: schemas.FamousCreate):

    db_famous = get_famouss_by_id(db, famous.id)
    if not db_famous:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    update_famous = famous.dict(exclude_unset=True)

    for key,value in update_famous.items():
        setattr(db_famous, key, value)

    db.add(db_famous)
    db.commit()
    db.refresh(db_famous)
    return db_famous

def subscribe_famous(db: Session, famous_id: int):

    db_famous = get_famouss_by_id(db, famous_id)
    setattr(db_famous, "subscribe", db_famous.subscribe+1)
    db.add(db_famous)
    db.commit()
    db.refresh(db_famous)
    return db_famous

def manage_like_by_famous_id(db: Session,likeContent:schemas.ManageLikeFamous) -> schemas.FamousOut:
    db_famous = db.query(models.Famous).filter(models.Famous.id == likeContent.famous_id).first()
    if likeContent.disorlike == "like":
        if likeContent.status == "append":
            db_famous.like.append(likeContent.email)
        if likeContent.status == "remove":
            db_famous.like.remove(likeContent.email)
        setattr(db_famous, "like", db_famous.like)
    if likeContent.disorlike == "dislike":
        if likeContent.status == "append":
            db_famous.dislike.append(likeContent.email)
        if likeContent.status == "remove":
            db_famous.dislike.remove(likeContent.email)
        setattr(db_famous, "dislike", db_famous.dislike)
    db.commit()
    db.refresh(db_famous)
    return db_famous



def edit_image_by_famous_id(db: Session,user:schemas.User,famous_id:int, image_id : int) -> schemas.FamousOut:
    db_famous = get_famouss_by_id(db, famous_id)
    setattr(db_famous, "image", f"http://43.200.121.48:8000/api/images/{image_id}")
    db.commit()
    db.refresh(db_famous)
    return db_famous


def delete_famous(db: Session, id: int):

    db_famous = get_famouss_by_id(db, id)
    if not db_famous:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")

    db.delete(db_famous)
    db.commit()
    return db_famous

