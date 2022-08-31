import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas


def create_famous(db: Session, famous: schemas.FamousCreate):
    db_famous = models.Famous(
        type=famous.type,
        user_email=famous.user_email,
        image=famous.image,
        routinedata = famous.routinedata,
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
    )
    print(famous.user_email)
    db.add(db_famous)
    db.commit()
    db.refresh(db_famous)
    return db_famous

def get_famouss_by_type(db: Session, type: int) -> schemas.FamousOut:
    famouss = db.query(models.Famous).filter(models.Famous.type == type).all()
    return famouss


def get_famouss_by_id(db: Session, input_id: int) -> schemas.FamousOut:
    famouss_id = db.query(models.Famous).get(input_id)
    print(famouss_id)
    return famouss_id

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


def delete_famous(db: Session, id: int):

    db_famous = get_famouss_by_id(db, id)
    if not db_famous:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")

    db.delete(db_famous)
    db.commit()
    return db_famous

