from datetime import datetime
from pydantic import BaseModel
import typing as t


class UserBase(BaseModel):
    username:str
    nickname : str
    image: str = ""
    height:float
    weight:float
    height_unit:str
    weight_unit:str


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
