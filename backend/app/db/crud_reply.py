from app.db.crud import get_user_by_email
import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from . import models, schemas


def get_replies_by_post_id(db: Session, post_id: int) -> t.List[schemas.Reply]:
    return db.query(models.Reply).filter(models.Reply.post_id == post_id).all()

def create_reply(db: Session, reply: schemas.ReplyCreate, ip):
    db_reply = models.Reply(
        post_id=reply.post_id,
        writer_email=reply.writer_email,
        writer_nickname=reply.writer_nickname,
        content=reply.content,
        likes=[],
        dislikes=[],
        post_created_at=datetime.datetime.utcnow() + datetime.timedelta(hours=9),
        post_modified_at=datetime.datetime.utcnow() + datetime.timedelta(hours=9),
        ip=ip
    )
    db.add(db_reply)
    db.commit()
    db.refresh(db_reply)
    db_post = db.query(models.Post).filter(models.Post.id == reply.post_id).first()
    setattr(db_post, "post_commented_at", datetime.datetime.utcnow() + datetime.timedelta(hours=9))
    setattr(db_post, "reply_length", db_post.reply_length+1)
    db.add(db_post)
    db.commit()
    db.refresh(db_post)
    db_user = get_user_by_email(db, reply.writer_email)
    setattr(db_user, "reply_cnt", len(db.query(models.Reply).filter(models.Reply.writer_email == reply.writer_email).all()))
    db.add(db_user)
    db.commit()
    db.refresh((db_user))
    return db_reply

def manage_like_by_reply_id(db: Session,likeContent:schemas.ManageLikeReply) -> schemas.Reply:
    db_reply = db.query(models.Reply).filter(models.Reply.id == likeContent.reply_id).first()
    if likeContent.disorlike == "like":
        if likeContent.status == "append":
            db_reply.likes.append(likeContent.email)
        if likeContent.status == "remove":
            db_reply.likes.remove(likeContent.email)
        setattr(db_reply, "likes", db_reply.likes)
    if likeContent.disorlike == "dislike":
        if likeContent.status == "append":
            db_reply.dislikes.append(likeContent.email)
        if likeContent.status == "remove":
            db_reply.dislikes.remove(likeContent.email)
        setattr(db_reply, "dislikes", db_reply.dislikes)
    db.commit()
    db.refresh(db_reply)
    return db_reply

def delete_reply(db: Session, reply_id: int):
    db_reply = db.query(models.Reply).filter(models.Reply.id == reply_id).first()
    db.delete(db_reply)
    db.commit()
    db_post = db.query(models.Post).filter(models.Post.id == reply.post_id).first()
    setattr(db_post, "reply_length", db_post.reply_length-1)
    db.add(db_post)
    db.commit()
    db.refresh(db_post)
    db_user = get_user_by_email(db, db_reply.writer_email)
    setattr(db_user, "reply_cnt", len(db.query(models.Reply).filter(models.Reply.writer_email == db_reply.writer_email).all()))
    db.add(db_user)
    db.commit()
    db.refresh((db_user))
    return db_reply

def get_replies_by_word(db: Session, word: str) -> t.List[schemas.Reply]:
    return db.query(models.Reply).filter(models.Reply.content.contains(word)).all()
