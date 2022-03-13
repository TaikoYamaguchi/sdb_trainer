from app.db.crud import create_user, get_user_by_email, get_user_by_phone_number
from app.db.schemas import User, UserCreate
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import APIRouter, Depends, Request, HTTPException, status
from datetime import timedelta

from app.db.session import get_db
from app.core import security
from app.core.auth import authenticate_user, get_current_active_superuser, sign_up_new_user
import typing as t

auth_router = r = APIRouter()


@r.post("/token")
async def login(
    db=Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()
):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(
        minutes=security.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    if user.is_superuser:
        permissions = "admin"
    else:
        permissions = "user"
    access_token = security.create_access_token(
        data={"sub": user.email, "permissions": permissions},
        expires_delta=access_token_expires,
    )

    return {"access_token": access_token, "token_type": "bearer"}




@r.post("/signup")
async def signup(
    db=Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()
):
    user = sign_up_new_user(db, form_data.username, form_data.password, form_data.nickname, form_data.phone_number)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Account already exists",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(
        minutes=security.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    if user.is_superuser:
        permissions = "admin"
    else:
        permissions = "user"
    access_token = security.create_access_token(
        data={"sub": user.email, "permissions": permissions},
        expires_delta=access_token_expires,
    )

    return {"access_token": access_token, "token_type": "bearer"}

@r.post("/usercreate", response_model=User, response_model_exclude_none=True)
async def user_create(
    request: Request,
    user: UserCreate,
    db=Depends(get_db),
):
    return create_user(db, user)


@r.get(
    "/create/{phone_number}",
    response_model=User,
    response_model_exclude_none=True,
)
async def user_phone_number(
    request: Request,
    phone_number: str,
    db=Depends(get_db),
):
    """
    Get any user details
    """
    user = get_user_by_phone_number(db, phone_number)
    return user


@r.get(
    "/getuser/{email}",
    response_model=User,
    response_model_exclude_none=True,
)
async def user_email(
    request: Request,
    email: str,
    db=Depends(get_db),
):
    user = get_user_by_email(db, email)
    return user
