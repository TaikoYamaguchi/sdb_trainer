import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas


def create_notification(db: Session, notification: schemas.NotificationCreate):
    print(notification.title)
    db_notification = models.Notification(
        title=notification.title,
        content=notification.content,
        images=notification.images,
        ispopup = notification.ispopup,
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
    )
    print(notification.title)
    db.add(db_notification)
    db.commit()
    db.refresh(db_notification)
    return db_notification


def get_notifications(db: Session) -> t.List[schemas.NotificationOut]:
    print("problem?")
    notifications = db.query(models.Notification).filter(models.Notification.ispopup == True).all()
    return notifications


def get_notifications_by_id(db: Session, input_id: int) -> schemas.NotificationOut:
    notification = db.query(models.Notification).filter(models.Notification.id == input_id).first()
    print(notification)
    return notification

def edit_notification(db: Session, notification: schemas.NotificationCreate):

    db_notification = get_notifications_by_id(db, notification.id)
    if not db_notification:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    update_notification = notification.dict(exclude_unset=True)

    for key,value in update_notification.items():
        setattr(db_notification, key, value)

    db.add(db_notification)
    db.commit()
    db.refresh(db_notification)
    return db_notification


def edit_image_by_notification_id(db: Session,user:schemas.User,notification_id:int, image_id : int) -> schemas.NotificationOut:
    db_notification = get_notifications_by_id(db, notification_id)
    setattr(db_notification, "image", f"http://43.200.121.48:8000/api/images/{image_id}")
    db.commit()
    db.refresh(db_notification)
    return db_notification


def delete_notification(db: Session, id: int):

    db_notification = get_notifications_by_id(db, id)
    if not db_notification:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")

    db.delete(db_notification)
    db.commit()
    return db_notification

