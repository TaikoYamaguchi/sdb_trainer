import datetime
from pytz import timezone
from app.db.crud import get_user_by_email
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t
from sqlakeyset import get_page
import json

from sqlalchemy.sql import func

from . import models, schemas

def create_interview(db: Session, interview: schemas.InterviewCreate, ip:str):
    db_interview = models.Interview(
        user_email=interview.user_email,
        user_nickname=interview.user_email,
        progress = "open",
        title = interview.title,
        content = interview.content,
        like=[],
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
        tags=interview.tags,
        modified_number=0,
        ip = ip
    )
    print(interview.user_email)
    db.add(db_interview)
    db.commit()
    db.refresh(db_interview)
    return db_interview

def get_interviews_by_email(db: Session, email) -> t.List[schemas.InterviewOut]:
    interviews = db.query(models.Interview).filter(models.Interview.user_email == email).order_by(models.Interview.id.desc()).all()
    return interviews

def get_interviews(db: Session, skip, limit) -> t.List[schemas.InterviewOut]:
    interviews = db.query(models.Interview).order_by(models.Interview.id.desc()).offset(skip).limit(limit).all()
    return interviews



def get_interviews_by_page(db: Session, page, id) -> t.List[schemas.InterviewOut]:
    interviews = db.query(models.Interview).order_by(models.Interview.id.desc())
    page2 = get_page(interviews, per_page=page, page=((id,), False))
    return page2

def manage_like_by_interview_id(db: Session,likeContent:schemas.ManageLikeInterview) -> schemas.InterviewOut:
    db_interview = db.query(models.Interview).filter(models.Interview.id == likeContent.interview_id).first()
    if likeContent.disorlike == "like": 
        if likeContent.status == "append":
            db_interview.like.append(likeContent.email)
        if likeContent.status == "remove":
            db_interview.like.remove(likeContent.email)
        setattr(db_interview, "like", db_interview.like)
    if likeContent.disorlike == "dislike": 
        if likeContent.status == "append":
            db_interview.dislike.append(likeContent.email)
        if likeContent.status == "remove":
            db_interview.dislike.remove(likeContent.email)
        setattr(db_interview, "dislike", db_interview.dislike)
    db.commit()
    db.refresh(db_interview)
    return db_interview

def delete_auth_interview(db: Session, interview_id: int, user:schemas.User):
    db_interview = db.query(models.Interview).filter(models.Interview.id == interview_id).first()
    if user.is_superuser == True :
        db.delete(db_interview)
        db.commit()
    else :
        if user.email == db_interview.user_email:
                db.delete(db_interview)
                db.commit()
        else :
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="작성자가 아닙니다",
            )
    return db_interview
