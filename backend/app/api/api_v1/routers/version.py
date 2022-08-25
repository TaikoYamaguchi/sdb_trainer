from app.db.crud_version import get_version
from app.core.sms import send_sms_find_user, verification_user
from app.db.crud import create_user, get_friends_by_email, get_user_by_email, get_user_by_phone_number, edit_user, get_user_by_nickname, get_user_by_sms_verifiaction, get_users_by_nickname, manage_like_by_liked_email, get_users
from app.db.schemas import FindUser, FindUserCode, User, UserCreate, UserEdit, ManageLikeUser, UserBase, VersionOut
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import APIRouter, Depends, Request, HTTPException, status
from datetime import timedelta

from app.db.session import get_db
from app.core import security
from app.core.auth import authenticate_user, get_current_active_superuser, sign_up_new_user
import typing as t

version_router = r = APIRouter()


@r.get(
    "/version",
    response_model_exclude_none=True,
)
async def get_supero_version(
    request: Request,
    db=Depends(get_db),
):
    """
    Get any user details
    """
    version = get_version(db)
    return version


