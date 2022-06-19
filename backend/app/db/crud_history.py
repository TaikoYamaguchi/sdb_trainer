import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas

def create_history(db: Session, history: schemas.HistoryCreate, ip:str):
    db_history = models.History(
        user_email=history.user_email,
        exercises = history.exercises,
        new_record=history.new_record,
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
        workout_time=history.workout_time,
        like=[],
        dislike=[],
        image=[],
        comment="",
        nickname=history.nickname,
        comment_length=0,
        isVisible=True,
        ip = ip
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

def get_friends_histories(db: Session, email:str) -> t.List[schemas.HistoryOut]:
    user = db.query(models.User).filter(models.User.email==email).first()
    histories = db.query(models.History).filter(models.History.user_email.in_(user.like)).order_by(models.History.id.desc()).all()
    return histories

def manage_like_by_history_id(db: Session,likeContent:schemas.ManageLikeHistory) -> schemas.HistoryOut:
    db_hisotry = db.query(models.History).filter(models.History.id == likeContent.history_id).first()
    if likeContent.disorlike == "like": 
        if likeContent.status == "append":
            db_hisotry.like.append(likeContent.email)
        if likeContent.status == "remove":
            db_hisotry.like.remove(likeContent.email)
        setattr(db_hisotry, "like", db_hisotry.like)
    if likeContent.disorlike == "dislike": 
        if likeContent.status == "append":
            db_hisotry.dislike.append(likeContent.email)
        if likeContent.status == "remove":
            db_hisotry.dislike.remove(likeContent.email)
        setattr(db_hisotry, "dislike", db_hisotry.dislike)
    db.commit()
    db.refresh(db_hisotry)
    return db_hisotry

def edit_comment_by_id(db: Session,history:schemas.HistoryCommentEdit) -> schemas.HistoryOut:
    db_history = db.query(models.History).filter(models.History.id == history.id).first()
    if(db_history.user_email == history.email):
        setattr(db_history, "comment", history.comment)
    db.commit()
    db.refresh(db_history)
    return db_history

def edit_exercies_by_id(db: Session,history:schemas.HistoryExercisesEdit) -> schemas.HistoryOut:
    db_history = db.query(models.History).filter(models.History.id == history.id).first()
    if(db_history.user_email == history.email):
        setattr(db_history, "exercises", history.exercises)
    db.commit()
    db.refresh(db_history)
    return db_history




