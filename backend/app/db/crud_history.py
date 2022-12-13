import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t
from sqlakeyset import get_page
import json

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

    if (history.user_email != "Anonymous"):
        db_user = get_user_by_email(db, history.user_email)
        setattr(db_user, "history_cnt", len(db.query(models.History).filter(models.History.user_email == history.user_email).all()))
        db.add(db_user)
        db.commit()
        db.refresh((db_user))
    return db_history

def get_user_by_email(db: Session, email: str) -> schemas.UserBase:
    user=db.query(models.User).filter(models.User.email == email).first()
    return user

def get_histories_by_email(db: Session, email: str) -> t.List[schemas.HistoryOut]:
    
    histories = db.query(models.History).filter(models.History.user_email == email).order_by(models.History.id.desc()).all()
    return histories

def delete_all_histories_by_email(db: Session, email: str):
    try:
        histories = db.query(models.History).filter(models.History.user_email == email).delete()
        db.commit()
    except:
        db.rollback()

def get_histories(db: Session, skip, limit) -> t.List[schemas.HistoryOut]:
    histories = db.query(models.History).order_by(models.History.id.desc()).offset(skip).limit(limit).all()
    return histories

def get_histories_all(db: Session) -> t.List[schemas.HistoryOut]:
    histories = db.query(models.History).order_by(models.History.id.desc()).all()
    return histories

def get_histories_by_page(db: Session, page, id) -> t.List[schemas.HistoryOut]:
    histories = db.query(models.History).order_by(models.History.id.desc())
    print(histories)
    page2 = get_page(histories, per_page=page, page=((id,), False))
    return page2

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

def visible_auth_history(db:Session,history:schemas.ManageVisibleHistory, user:schemas.User) -> schemas.HistoryOut:
    db_history = db.query(models.History).filter(models.History.id == history.history_id).first()
    if user.email == db_history.user_email:
        if history.status == "true":
            setattr(db_history, "isVisible", True)
            db.commit()
            db.refresh((db_history))
        elif history.status == "false":
            setattr(db_history, "isVisible", False)
            db.commit()
            db.refresh((db_history))

    else :
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="작성자가 아닙니다",
        )
    return db_history

def delete_auth_history(db: Session, history_id: int, user:schemas.User):
    db_history = db.query(models.History).filter(models.History.id == history_id).first()
    if user.is_superuser == True :
        db.delete(db_history)
        db.commit()
    else :
        if user.email == db_history.user_email:
                db.delete(db_history)
                db_user = get_user_by_email(db, db_history.user_email)
                setattr(db_user, "history_cnt", len(db.query(models.History).filter(models.History.user_email == db_history.user_email).all()))
                db.add(db_user)
                db.commit()
                db.refresh((db_user))
        else :
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="작성자가 아닙니다",
            )
    return db_history

def edit_image_by_history_id(db: Session,user:schemas.User,history_id:int, image_id : int) -> schemas.HistoryOut:
    db_history = db.query(models.History).filter(models.History.id == history_id).first()
    db_history.image.append(f"http://43.200.121.48:8000/api/images/{image_id}")
    setattr(db_history, "image", db_history.image)
    db.commit()
    db.refresh(db_history)
    return db_history

def remove_image_by_history_id(db: Session,user:schemas.User,history_id:int) -> schemas.HistoryOut:
    db_history = db.query(models.History).filter(models.History.id == history_id).first()
    db_history.image = []
    setattr(db_history, "image", db_history.image)
    db.commit()
    db.refresh(db_history)
    return db_history


def edit_history_all(db:Session, historys: schemas.HistoryAll):
    db_history = get_histories_all(db)
    if not db_history:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")

    historys = historys.dict(exclude_unset=True)['sdbdatas']
    historys = json.loads(historys)

    for x in historys:
        print(x)
        for y in db_history:
            if x['id'] == y.id:
                for key,value in x.items():
                    setattr(y, key, value)

    db.add_all(db_history)
    db.commit()
    db.expire_all()
    return db_history

    



