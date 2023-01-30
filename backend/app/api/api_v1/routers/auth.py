from app.core.sms import send_sms_find_user, verification_user
from app.db.crud import create_user, get_friends_by_email, get_user_by_email, get_user_by_phone_number, edit_user, get_user_by_nickname, get_user_by_sms_verifiaction, get_users_by_nickname, manage_like_by_liked_email, get_users, delete_user
from app.db.schemas import FindUser, FindUserCode, User, UserCore, UserCreate, UserEdit, ManageLikeUser, UserBase
from fastapi.security import OAuth2PasswordRequestForm
from fastapi import APIRouter, Depends, Request, HTTPException, status
from datetime import timedelta

from app.db.session import get_db
from app.core import security
from app.core.auth import authenticate_user, get_current_active_superuser, sign_up_new_user,get_current_user
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

@r.post("/tokenkakao/{email}")
async def loginkakao(
    request:Request,
 email:str,
    db=Depends(get_db),
):
    user = get_user_by_email(db, email ) 
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
    "/user/{email}",
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

@r.get(
    "/friends/{email}",
    response_model=t.List[User],
    response_model_exclude_none=True,
)
async def friend_email(
    request: Request,
    email: str,
    db=Depends(get_db),
):
    user = get_friends_by_email(db, email)
    return user

@r.get(
    "/users",
    response_model=t.List[User],
    response_model_exclude_none=True,
)
async def user_all(
    request: Request,
    db=Depends(get_db),
):
    user = get_users(db)
    return user

@r.get(
    "/userNickname/{nickname}",
    response_model=User,
    response_model_exclude_none=True,
)
async def user_nickname(
    request: Request,
    nickname: str,
    db=Depends(get_db),
):
    user = get_user_by_nickname(db, nickname)
    return user

@r.get(
    "/usersNickname/{nickname}",
    response_model=t.List[User],
    response_model_exclude_none=True,
)
async def users_nickname(
    request: Request,
    nickname: str,
    db=Depends(get_db),
):
    user = get_users_by_nickname(db, nickname)
    return user

@r.patch(
    "/userFind",
)
async def send_sms(
    phone_number : FindUser,
    db=Depends(get_db),
):
    user = get_user_by_phone_number(db, phone_number.phone_number)
    print(user)
    if user != None :
        send_sms_find_user(phone_number.phone_number)
    else :
        raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="휴대폰이 없습니다",
            )




@r.patch(
    "/userFindVerify",
    response_model=User, response_model_exclude_none=True
)
async def verify_sms(
    sms : FindUserCode,
    db=Depends(get_db),
):
    user = get_user_by_sms_verifiaction(db, sms)
    return user



@r.put(
    "/user/{email}", response_model=User, response_model_exclude_none=True
)
async def user_edit(
    request: Request,
    email: str,
    user: UserCore,
    db=Depends(get_db),
):
    """
    Update existing user
    """
    return edit_user(db, email, user)

@r.patch(
    "/user/likes/{user_email}",
    response_model=User,
    response_model_exclude_none=True,
)
async def user_likes(
    request:Request,
    likeContent:ManageLikeUser,
    db=Depends(get_db),
):
    user = manage_like_by_liked_email(db, likeContent)
    # This is necessary for react-admin to work
    return user

@r.delete(
    "/userDelete", response_model=User, response_model_exclude_none=True
)
async def user_delete(
    request: Request,
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    return delete_user(db, user)


