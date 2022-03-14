from app.db.crud_exercise import create_exercise, get_exercise_by_email
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.schemas import ExercisesCreate, ExercisesOut


exercise_router = r = APIRouter()

@r.post("/exercisecreate", response_model=ExercisesCreate, response_model_exclude_none=True)
async def exercise_create(
    request: Request,
    exercise: ExercisesCreate,
    db=Depends(get_db),
):
    return create_exercise(db, exercise)

@r.get(
    "/exercise/{email}",
    response_model=ExercisesOut,
    response_model_exclude_none=True,
)
async def exercises_list(
    response: Response,
    email:str,
    db=Depends(get_db),
):

    exercise = get_exercise_by_email(db, email)
    # This is necessary for react-admin to work
    return exercise


