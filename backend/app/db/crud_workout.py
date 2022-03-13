import datetime
import json
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas
from app.core.security import get_password_hash


def create_workout(db: Session, workout: schemas.WorkoutCreate):
    print(workout)
    print(workout.dict())
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
    print(type(workouts[0].exercises))
    print(workouts[0])
    return workouts


