import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas

def create_history(db: Session, history: schemas.HistoryCreate):
    db_history = models.History(
        user_email=history.user_email,
        exercises = history.exercises,
        new_record=history.new_record,
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
        workout_time=history.workout_time,
        like=[],
        dislike=[],
        image=[],
        comment=""
    )
    print(history.user_email)
    db.add(db_history)
    db.commit()
    db.refresh(db_history)
    return db_history

def get_histories_by_email(db: Session, email: str) -> t.List[schemas.HistoryOut]:
    histories = db.query(models.History).filter(models.History.user_email == email).order_by(models.History.id.desc()).all()
    return histories

def get_histories(db: Session) -> t.List[schemas.HistoryOut]:
    histories = db.query(models.History).order_by(models.History.id.desc()).all()
    return histories


