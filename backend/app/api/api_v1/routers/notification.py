from app.db.crud_notification import create_notification, get_notifications, edit_notification, delete_notification
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.schemas import NotificationCreate, NotificationOut


notification_router = r = APIRouter()

@r.post("/notificationcreate", response_model=NotificationOut, response_model_exclude_none=True)
async def notification_create(
    request: Request,
    notification: NotificationCreate,
    db=Depends(get_db),
):
    return create_notification(db, notification)

@r.get(
    "/notification",
    response_model=t.List[NotificationOut],
    response_model_exclude_none=True,
)
async def notifications_list(
    response: Response,
    db=Depends(get_db),
):
    print("problem?")
    notifications = get_notifications(db)
    print(notifications)
    # This is necessary for react-admin to work
    return notifications

@r.put("/notification", response_model=NotificationCreate, response_model_exclude_none=True)
async def notification_edit(
    request: Request,
    notification: NotificationCreate,
    db=Depends(get_db),
):
    return edit_notification(db, notification)

@r.delete("/notification/{id}", response_model=NotificationCreate, response_model_exclude_none=True)
async def notification_delete(
    request: Request,
    id: int,
    db=Depends(get_db),
):
    return delete_notification(db, id)


