
from app.db.crud import get_user_by_email
from fastapi.param_functions import Depends
from app.core.auth import get_current_active_user, get_current_user
import datetime
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import sqlalchemy
import typing as t
import asyncio

from . import models, schemas

def get_comments_by_history_id(db: Session, history_id: int) -> t.List[schemas.CommentOut]:
    return db.query(models.Comment).order_by(
        sqlalchemy.sql.expression.case(
            ((models.Comment.reply_id == 0, models.Comment.id),),
            else_=models.Comment.reply_id
        ), models.Comment.id
    ).filter(models.Comment.history_id == history_id).all()

def get_comments_all(db: Session) -> t.List[schemas.CommentOut]:
    return db.query(models.Comment).all()

def create_comment(db: Session, comment: schemas.CommentCreate, ip):
    db_comment = models.Comment(
        history_id=comment.history_id,
        reply_id=comment.reply_id,
        writer_email=comment.writer_email,
        writer_nickname=comment.writer_nickname,
        content=comment.content,
        likes=[],
        dislikes=[],
        password = "",
        ip = ip,
        comment_created_at=datetime.datetime.utcnow() + datetime.timedelta(hours=9),
        comment_modified_at=datetime.datetime.utcnow() + datetime.timedelta(hours=9),
    )
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    if (comment.history_id != 0):

        db_history = db.query(models.History).filter(models.History.id == comment.history_id).first()
        setattr(db_history, "comment_length", db_history.comment_length+1)
        db.add(db_history)
        db.commit()
        db.refresh(db_history)

    if (comment.writer_email != "Anonymous"):
        db_user = get_user_by_email(db, comment.writer_email)
        setattr(db_user, "comment_cnt", len(db.query(models.Comment).filter(models.Comment.writer_email == comment.writer_email).all()))
        db.add(db_user)
        db.commit()
        db.refresh((db_user))
    return db_comment

def delete_auth_comment(db: Session, comment_id: int, user:schemas.User):
    db_comment = db.query(models.Comment).filter(models.Comment.id == comment_id).first()
    print(db_comment)
    if user.is_superuser == True :
        db.delete(db_comment)
        db.commit()
    else :
        if user.email == db_comment.writer_email:
                db.delete(db_comment)
                db.commit()
                if (db_comment.history_id != 0):
                    db_history = db.query(models.History).filter(models.History.id == db_comment.history_id).first()
                    setattr(db_history, "comment_length", db_history.comment_length-1)
                    db.add(db_history)
                    db.commit()
                    db.refresh(db_history)
                db_user = get_user_by_email(db, db_comment.writer_email)
                setattr(db_user, "comment_cnt", len(db.query(models.Comment).filter(models.Comment.writer_email == db_comment.writer_email).all()))
                db.add(db_user)
                db.commit()
                db.refresh((db_user))
        else :
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="작성자가 아닙니다",
            )
    return db_comment


def manage_like_by_comment_id(db: Session,likeContent:schemas.ManageLikeComment) -> schemas.CommentOut:
    db_comment = db.query(models.Comment).filter(models.Comment.id == likeContent.comment_id).first()
    if likeContent.disorlike == "like": 
        if likeContent.status == "append":
            db_comment.likes.append(likeContent.email)
        if likeContent.status == "remove":
            db_comment.likes.remove(likeContent.email)
        setattr(db_comment, "likes", db_comment.likes)
    if likeContent.disorlike == "dislike": 
        if likeContent.status == "append":
            db_comment.dislikes.append(likeContent.email)
        if likeContent.status == "remove":
            db_comment.dislikes.remove(likeContent.email)
        setattr(db_comment, "dislikes", db_comment.dislikes)
    db.commit()
    db.refresh(db_comment)
    return db_comment


def get_comments_by_comment_id(db: Session, comment_id: int) -> schemas.CommentOut:
    return db.query(models.Comment).filter(models.Comment.id == comment_id).first()
