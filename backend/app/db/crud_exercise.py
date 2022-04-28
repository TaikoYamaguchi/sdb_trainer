import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from sqlalchemy.sql import func

from . import models, schemas

def create_exercise(db: Session, exercise: schemas.ExercisesCreate):
    db_exercise = models.Exercises(
        user_email=exercise.user_email,
        exercises = exercise.exercises,
        date = datetime.datetime.utcnow()+datetime.timedelta(hours=9),
        modified_number=exercise.modified_number
    )
    db.add(db_exercise)
    db.commit()
    db.refresh(db_exercise)
    return db_exercise

def get_exercise_by_email(db: Session, email: str) -> schemas.ExercisesOut:
    exercise = db.query(models.Exercises).filter(models.Exercises.user_email == email).first()
    return exercise

def edit_exercise(db:Session, exercise:schemas.ExercisesCreate):
    db_exercise = get_exercise_by_email(db, exercise.user_email)
    if not db_exercise:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")
    update_exercise = exercise.dict(exclude_unset=True)

    for key,value in update_exercise.items():
        setattr(db_exercise, key, value)

    db.add(db_exercise)
    db.commit()
    db.refresh(db_exercise)
    return db_exercise

    

