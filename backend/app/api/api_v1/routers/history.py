from app.db.crud_history import create_history, get_histories_by_email
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.schemas import HistoryCreate, HistoryOut


history_router = r = APIRouter()

@r.post("/historycreate", response_model=HistoryCreate, response_model_exclude_none=True)
async def history_create(
    request: Request,
    history: HistoryCreate,
    db=Depends(get_db),
):
    return create_history(db, history)

@r.get(
    "/history/{email}",
    response_model=t.List[HistoryOut],
    response_model_exclude_none=True,
)
async def histories_list(
    response: Response,
    email:str,
    db=Depends(get_db),
):

    histories = get_histories_by_email(db, email)
    # This is necessary for react-admin to work
    return histories

