from datetime import datetime
from pydantic import BaseModel
import typing as t


class UserBase(BaseModel):
    nickname : str
    image: str = ""
    selfIntroduce: str = ""


class UserOut(UserBase):
    pass


class UserCreate(UserBase):
    password: str
    phone_number: str
    email: str

    class Config:
        orm_mode = True


