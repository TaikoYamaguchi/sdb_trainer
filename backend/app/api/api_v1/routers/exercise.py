from app.db.crud_exercise import create_exercise, get_exercise_by_email, edit_exercise, get_exercise_all, edit_exercise_all
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.schemas import ExercisesCreate, ExercisesOut, ExercisesAll


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

@r.get(
    "/exercise/",
    response_model=t.List[ExercisesOut],
    response_model_exclude_none=True,
)
async def exercises_list(
    response: Response,
    db=Depends(get_db),
):

    exercises = get_exercise_all(db)
    # This is necessary for react-admin to work
    return exercises

@r.put("/exercise", response_model=ExercisesCreate, response_model_exclude_none=True)
async def exercise_edit(
    request: Request,
    exercise: ExercisesCreate,
    db=Depends(get_db),
):
    return edit_exercise(db, exercise)

@r.put(
    "/exercise/all",
    response_model=t.List[ExercisesOut],
    response_model_exclude_none=True
)
async def exercise_edit(
    request: Request,
    exercises: ExercisesAll,
    db=Depends(get_db),
):
    return edit_exercise_all(db, exercises)



