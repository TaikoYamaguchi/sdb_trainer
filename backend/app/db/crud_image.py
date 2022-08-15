
import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from . import models, schemas

def create_temporary_image(db: Session, file_name:str):
    print(file_name)
    db_image = models.TemporaryImage(
        image=file_name,
        views=0
    )
    db.add(db_image)
    db.commit()
    db.refresh(db_image)
    return db_image


def get_image_by_id(db: Session, image_id:int):
    
    db_image = db.query(models.TemporaryImage).filter(models.TemporaryImage.id == image_id).first()
    setattr(db_image, "views", db_image.views+1)
    db.add(db_image)
    db.commit()
    db.refresh(db_image)
    return db_image.image
