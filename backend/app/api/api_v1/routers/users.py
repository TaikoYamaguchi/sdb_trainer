from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.crud import (
    edit_fcm_token,
    edit_user_body_stat,
    get_user_by_email,
    get_users,
    manage_like_by_liked_email,
)
from app.db.schemas import UserBodyStatIn, UserCreate, User, ManageLikeUser, UserFCMTokenIn
from app.core.auth import get_current_active_user, get_current_active_superuser, get_current_user


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

@r.patch(
    "/user/fcm_token",
    response_model=User,
    response_model_exclude_none=True,
)
async def user_fcm_token(
    response: Response,
    fcm_token:UserFCMTokenIn,
    db=Depends(get_db),
    current_user=Depends(get_current_user)
):
    user = edit_fcm_token(db, fcm_token, current_user)
    return user

@r.patch(
    "/user/bodystat",
    response_model=User,
    response_model_exclude_none=True,
)
async def user_patch_bodystat(
    response: Response,
    body_stats:UserBodyStatIn,
    db=Depends(get_db),
    current_user=Depends(get_current_user)
):
    user = edit_user_body_stat(db, body_stats, current_user)
    return user

'''
@r.patch(
    "/user/favor",
    response_model=User,
    response_model_exclude_none=True,
)

async def user_favor_ex(
    response: Response,
    likeContent: ManageUserFavor,
    db=Depends(get_db),
):
    user = manage_like_by_liked_email(db, likeContent)
    # This is necessary for react-admin to work
    return user
'''
