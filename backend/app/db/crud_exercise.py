import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t
import json

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



def get_exercise_all(db: Session) -> t.List[schemas.ExercisesOut]:
    exercises = db.query(models.Exercises).order_by(models.Exercises.id).all()
    print(exercises[0])
    return exercises

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

def edit_exercise_all(db:Session, exercises: schemas.ExercisesAll):
    db_exercise = get_exercise_all(db)
    if not db_exercise:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="User not found")

    exercises = exercises.dict(exclude_unset=True)['exercisedatas']
    exercises = json.loads(exercises)

    for x in exercises:
        print(x)
        for y in db_exercise:
            if x['id'] == y.id:
                for key,value in x.items():
                    setattr(y, key, value)

    db.add_all(db_exercise)
    db.commit()
    db.expire_all()
    return db_exercise

    

