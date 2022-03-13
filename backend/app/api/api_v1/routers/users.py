from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.crud import (
    get_user_by_email,
    get_user_by_phone_number,
    get_users,
    create_user,
    delete_user,
    edit_user,
    create_lesson
)
from app.db.schemas import UserCreate, UserEdit, Mail, NewMails, User, UserOut, LessonBase, Lesson
from app.core.auth import get_current_active_user, get_current_active_superuser
from app.db.crud_mail import get_mails_by_email, read_mail, get_newmails_by_email

from fastapi_pagination import Page, add_pagination, paginate

users_router = r = APIRouter()


@r.get(
    "/users",
    response_model=t.List[User],
    response_model_exclude_none=True,
)
async def users_list(
    response: Response,
    db=Depends(get_db),
    current_user=Depends(get_current_active_superuser),
):
    """
    Get all users
    """
    users = get_users(db)
    # This is necessary for react-admin to work
    response.headers["Content-Range"] = f"0-9/{len(users)}"
    return users


@r.get("/users/me", response_model=User, response_model_exclude_none=True)
async def user_me(current_user=Depends(get_current_active_user)):
    """
    Get own user
    """
    return current_user

@r.post("/userlesson", response_model=Lesson, response_model_exclude_none=True)
async def lesson_create(
    request: Request,
    lesson: LessonBase,
    db=Depends(get_db),
):
    return create_lesson(db, lesson, request.headers["x-forwarded-for"])

@r.put("/mail/{id}", response_model=Mail, response_model_exclude_none=True)
async def mail_read(
    request: Request,
    id:int,
    db=Depends(get_db),
):
    return read_mail(db, id)

@r.get(
    "/getmails/{email}",
    response_model=Page[Mail],
    response_model_exclude_none=True,
)
async def user_new_mail(
    request: Request,
    email: str,
    db=Depends(get_db),
):
    mails = get_mails_by_email(db, email)
    return paginate(mails)

@r.get(
    "/getnewmails/{email}",
    response_model_exclude_none=True,
)
async def user_mail(
    request: Request,
    email: str,
    db=Depends(get_db),
):
    mails = get_newmails_by_email(db, email)
    return mails



@r.post("/users", response_model=User, response_model_exclude_none=True)
async def user_create(
    request: Request,
    user: UserCreate,
    db=Depends(get_db),
    current_user=Depends(get_current_active_superuser),
):
    """
    Create a new user
    """
    return create_user(db, user)


@r.delete(
    "/users/{user_id}", response_model=User, response_model_exclude_none=True
)
async def user_delete(
    request: Request,
    user_id: int,
    db=Depends(get_db),
    current_user=Depends(get_current_active_superuser),
):
    return delete_user(db, user_id)

@r.get(
    "/users/{email}",
    response_model=User,
    response_model_exclude_none=True,
)
async def user_email(
    request: Request,
    email: str,
    db=Depends(get_db),
    current_user=Depends(get_current_active_user),
):
    user = get_user_by_email(db, email)
    return user

add_pagination(r)
