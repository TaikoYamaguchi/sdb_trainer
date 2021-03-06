from app.db.crud_history import create_history, delete_auth_history, edit_comment_by_id, edit_exercies_by_id, get_friends_histories, get_histories_by_email, get_histories, manage_like_by_history_id, visible_auth_history
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t


from app.core.auth import get_current_active_user, get_current_user
from app.db.session import get_db
from app.db.schemas import HistoryCommentEdit, HistoryCreate, HistoryExercisesEdit, HistoryOut, ManageLikeHistory, ManageVisibleHistory


history_router = r = APIRouter()

@r.post("/historycreate", response_model=HistoryCreate, response_model_exclude_none=True)
async def history_create(
    request: Request,
    history: HistoryCreate,
    db=Depends(get_db),
):
    return create_history(db, history, request.headers["x-forwarded-for"])

@r.get(
    "/history/{email}",
    response_model=t.List[HistoryOut],
    response_model_exclude_none=True,
)
async def histories_list_email(
    response: Response,
    email:str,
    db=Depends(get_db),
):

    histories = get_histories_by_email(db, email)
    # This is neSSScessaSSry for react-admin to work
    return histories

@r.get(
    "/history",
    response_model=t.List[HistoryOut],
    response_model_exclude_none=True,
)
async def histories_list(
    response: Response,
    db=Depends(get_db),
):

    histories = get_histories(db)
    # This is necessary for react-admin to work
    return histories

@r.get(
    "/historyFriends/{email}",
    response_model=t.List[HistoryOut],
    response_model_exclude_none=True,
)
async def histories_friends_list(
    response: Response,
    email=str,
    db=Depends(get_db),
):

    histories = get_friends_histories(db, email)
    # This is necessary for react-admin to work
    return histories


@r.patch(
    "/history/likes/{history_id}",
    response_model=HistoryOut,
    response_model_exclude_none=True,
)
async def history_likes(
    response: Response,
    likeContent:ManageLikeHistory,
    db=Depends(get_db),
):
    history = manage_like_by_history_id(db, likeContent)
    # This is necessary for react-admin to work
    return history

@r.patch(
    "/history/comment/edit",
    response_model=HistoryOut,
    response_model_exclude_none=True,
)
async def history_comment(
    response: Response,
    history_edit:HistoryCommentEdit,
    db=Depends(get_db),
):
    history = edit_comment_by_id(db, history_edit)
    # This is necessary for react-admin to work
    return history

@r.patch(
    "/history/exercises/edit",
    response_model=HistoryOut,
    response_model_exclude_none=True,
)
async def history_exercises_edit(
    response: Response,
    history_edit:HistoryExercisesEdit,
    db=Depends(get_db),
):
    history = edit_exercies_by_id(db, history_edit)
    # This is necessary for react-admin to work
    return history


@r.patch(
    "/historyVisible", response_model=HistoryOut, response_model_exclude_none=True
)
async def history_visible_edit(
    response: Response,
    history:ManageVisibleHistory,
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    return visible_auth_history(db, history, user)

@r.delete(
    "/historyDelete/{history_id}", response_model=HistoryOut, response_model_exclude_none=True
)
async def history_delete(
    response: Response,
    history_id:int,
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    return delete_auth_history(db, history_id, user)
