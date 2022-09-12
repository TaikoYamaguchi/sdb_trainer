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
    favor_exercise:list


class UserOut(UserBase):
    selfIntroduce:str
    history_cnt:int
    comment_cnt:int
    like:list
    dislike:list
    liked:list
    disliked:list
    pass


class UserCreate(UserBase):
    password: str
    phone_number: str
    email: str

    class Config:
        orm_mode = True

class UserEdit(UserBase):
    password: t.Optional[str] = None

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
    like:list
    dislike:list
    liked:list
    disliked:list
    selfIntroduce:str
    history_cnt:int
    comment_cnt:int
  
    class Config:
        orm_mode = True

class HistoryBase(BaseModel):
    user_email : str
    exercises : t.Any
    new_record: int
    workout_time: int
    like:list
    dislike:list
    image:list
    comment:str
    nickname:str
    class Config:
        orm_mode = True

class HistoryDelete(BaseModel):
    user_email : str
    exercises : t.Any
    new_record: int
    workout_time: int
    like:list
    dislike:list
    image:list
    comment:str
    nickname:str
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
    id: int
    routinedatas: t.Any
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
    comment_length:int
    isVisible:bool=True
    class config:
        orm_mode = True

class ExercisesOut(ExercisesBase):
    id: int
    date: datetime
    class config:
        orm_mode = True

class ManageVisibleHistory(BaseModel):
    history_id:int
    status:str

class ManageLikeHistory(BaseModel):
    history_id:int
    email:str
    status:str
    disorlike:str

class ManageLikeUser(BaseModel):
    liked_email:str
    email:str
    status:str
    disorlike:str

class ManageUserFavor(BaseModel):
    liked_email:str
    email:str
    status:str
    disorlike:str

class HistoryCommentEdit(BaseModel):
    id:int
    email:str
    comment:str

class HistoryExercisesEdit(BaseModel):
    id:int
    email:str
    exercises:t.Any


class CommentBase(BaseModel):
    history_id:int
    reply_id:int
    writer_email:str
    writer_nickname:str
    content:str
    
    class Config:
        orm_mode = True

class CommentCreate(CommentBase):
    class Config:
        orm_mode = True

class CommentOut(CommentBase):
    id:int
    likes:list
    dislikes:list
    comment_created_at:datetime
    comment_modified_at:datetime

    class Config:
        orm_mode = True

class CommentDelete(BaseModel):
    id:int
    class Config:
        orm_mode = True

class ManageLikeComment(BaseModel):
    comment_id:int
    email:str
    status:str
    disorlike:str

class TemporaryImageCreate(BaseModel):
    image:str = ""
    views:int = 0
    class Config:
        orm_mode = True

class TemporaryImage(TemporaryImageCreate):
    id :int

class TemporaryVideoCreate(BaseModel):
    video:str = ""
    views:int = 0
    class Config:
        orm_mode = True

class TemporaryVideo(TemporaryVideoCreate):
    id :int

class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    email: str = None
    permissions: str = "user"

class FindUser(BaseModel):
    phone_number : str

class FindUserCode(FindUser):
    verifyCode : str

class VersionOut(BaseModel):
    version_num:str

class FamousBase(BaseModel):
    id: int
    type: int
    user_email: str
    image: str = ""
    routinedata: t.Any
    like:list
    dislike:list
    level: int
    subscribe: int = 0
    category: int = 0
    class Config:
        orm_mode = True

class FamousCreate(FamousBase):
    class config:
        orm_mode = True

class FamousOut(FamousBase):
    id: int
    type: int
    subscribe: int
    category: int
    class config:
        orm_mode = True

class ManageLikeFamous(BaseModel):
    famous_id:int
    email:str
    status:str
    disorlike:str