from app.db.crud_workout import create_workout, get_workouts_by_email, edit_workout, delete_workout
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.schemas import WorkoutCreate, WorkoutOut


workout_router = r = APIRouter()

@r.post("/workoutcreate", response_model=WorkoutCreate, response_model_exclude_none=True)
async def workout_create(
    request: Request,
    workout: WorkoutCreate,
    db=Depends(get_db),
):
    return create_workout(db, workout)

@r.get(
    "/workout/{email}",
    response_model=WorkoutOut,
    response_model_exclude_none=True,
)
async def workouts_list(
    response: Response,
    email:str,
    db=Depends(get_db),
):

    workouts = get_workouts_by_email(db, email)
    print(workouts)
    # This is necessary for react-admin to work
    return workouts

@r.put("/workout", response_model=WorkoutCreate, response_model_exclude_none=True)
async def workout_edit(
    request: Request,
    workout: WorkoutCreate,
    db=Depends(get_db),
):
    return edit_workout(db, workout)

@r.delete("/workout/{id}", response_model=WorkoutCreate, response_model_exclude_none=True)
async def workout_delete(
    request: Request,
    id: int,
    db=Depends(get_db),
):
    return delete_workout(db, id)


