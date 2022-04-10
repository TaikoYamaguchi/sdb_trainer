from datetime import datetime
from pydantic import BaseModel
import typing as t

from pydantic.types import Json


class UserBase(BaseModel):
    username:str
    nickname : str
    image: str = ""
    height:float
    weight:float
    height_unit:str
    weight_unit:str
    isMan:bool=True


class UserOut(UserBase):
    pass


class UserCreate(UserBase):
    password: str
    phone_number: str
    email: str

    class Config:
        orm_mode = True

class User(UserBase):
    id: int
    email: str
    is_active: bool = True
    is_superuser: bool = False
    level: int = 1
    point: int = 0
    created_at: datetime
  
    class Config:
        orm_mode = True

class HistoryBase(BaseModel):
    user_email : str
    exercises : t.Any
    new_record: int
    workout_time:float
    class Config:
        orm_mode = True

class ExercisesBase(BaseModel):
    user_email : str
    exercises : t.Any
    modified_number: int
    class Config:
        orm_mode = True

class WorkoutBase(BaseModel):
    user_email: str
    name: str
    exercises: t.Any
    routine_time: float
    class Config:
        orm_mode = True

class WorkoutCreate(WorkoutBase):
    class config:
        orm_mode = True

class HistoryCreate(HistoryBase):
    class config:
        orm_mode = True

class ExercisesCreate(ExercisesBase):
    class config:
        orm_mode = True

class WorkoutOut(WorkoutBase):
    id: int
    date: datetime
    class config:
        orm_mode = True

class HistoryOut(HistoryBase):
    id: int
    date: datetime
    class config:
        orm_mode = True

class ExercisesOut(ExercisesBase):
    id: int
    date: datetime
    class config:
        orm_mode = True

