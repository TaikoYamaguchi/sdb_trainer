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
        name = workout.name,
        exercises = workout.exercises,
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
        routine_time=workout.routine_time
    )
    db.add(db_workout)
    db.commit()
    db.refresh(db_workout)
    return db_workout

def get_workouts_by_email(db: Session, email: str) -> t.List[schemas.WorkoutOut]:
    workouts = db.query(models.Workout).filter(models.Workout.user_email == email).all()
    return workouts

def get_workouts_by_email_name(db: Session, email: str, input_name: str) -> schemas.WorkoutOut:
    print(db.query(models.Workout))
    workouts_email_name = db.query(models.Workout).filter(models.Workout.user_email == email, models.Workout.name == input_name).all()
    return workouts_email_name

def edit_workout(db: Session, workout: schemas.WorkoutCreate):

    db_workout = get_workouts_by_email_name(db, workout.user_email, workout.name)
    if not db_workout:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    update_workout = workout.dict(exclude_unset=True)

    for key,value in update_workout.items():
        setattr(db_workout, key, value)

    db.add(db_workout)
    db.commit()
    db.refresh(db_workout)
    return db_workout
