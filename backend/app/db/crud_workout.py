import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas


def create_workout(db: Session, workout: schemas.WorkoutCreate):
    db_workout = models.Workout(
        user_email=workout.user_email,
        routinedatas = workout.routinedatas,
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
    )
    print(workout.user_email)
    db.add(db_workout)
    db.commit()
    db.refresh(db_workout)
    return db_workout

def get_workouts_by_email(db: Session, email: str) -> schemas.WorkoutOut:
    workouts = db.query(models.Workout).filter(models.Workout.user_email == email).first()
    return workouts

def delete_all_workouts_by_email(db: Session, email: str) :
    try:
        workouts = db.query(models.Workout).filter(models.Workout.user_email == email).delete()
        db.commit()
    except:
        db.rollback()


def get_workouts_by_email_name(db: Session, email: str, input_name: str) -> schemas.WorkoutOut:
    workouts_email_name = db.query(models.Workout).filter(models.Workout.user_email == email, models.Workout.name == input_name).first()
    print(workouts_email_name)
    return workouts_email_name

def get_workouts_by_id(db: Session, input_id: int) -> schemas.WorkoutOut:
    workouts_id = db.query(models.Workout).get(input_id)
    print(workouts_id)
    return workouts_id

def edit_workout(db: Session, workout: schemas.WorkoutCreate):

    db_workout = get_workouts_by_id(db, workout.id)
    if not db_workout:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    update_workout = workout.dict(exclude_unset=True)

    for key,value in update_workout.items():
        setattr(db_workout, key, value)

    db.add(db_workout)
    db.commit()
    db.refresh(db_workout)
    return db_workout

def delete_workout(db: Session, id: int):

    db_workout = get_workouts_by_id(db, id)
    if not db_workout:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")

    db.delete(db_workout)
    db.commit()
    return db_workout

