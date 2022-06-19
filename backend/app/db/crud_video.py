
import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from . import models, schemas

def create_temporay_video(db: Session, file_name:str):
    print(file_name)
    db_video = models.TemporaryVideo(
        video=file_name,
        views=0
    )
    db.add(db_video)
    db.commit()
    db.refresh(db_video)
    return db_video


def get_video_by_name(db: Session, video:str):
    
    db_video = db.query(models.TemporaryVideo).filter(models.TemporaryVideo.video == "/app/app/videos/"+ video).first()
    setattr(db_video, "views", db_video.views+1)
    db.add(db_video)
    db.commit()
    db.refresh(db_video)
    return db_video.video
