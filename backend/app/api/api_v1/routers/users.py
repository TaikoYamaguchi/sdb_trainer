from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.crud import (
    get_user_by_email,
    get_users,
    manage_like_by_liked_email,
)
from app.db.schemas import UserCreate, User, ManageLikeUser
from app.core.auth import get_current_active_user, get_current_active_superuser


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

@r.patch(
    "/user/likes/{user_email}",
    response_model=User,
    response_model_exclude_none=True,
)
async def user_likes(
    response: Response,
    likeContent:ManageLikeUser,
    db=Depends(get_db),
):
    user = manage_like_by_liked_email(db, likeContent)
    # This is necessary for react-admin to work
    return user

