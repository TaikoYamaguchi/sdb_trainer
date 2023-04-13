

from app.core.auth import get_current_active_user, get_current_user
from app.db.crud_comment import create_comment, delete_auth_comment, get_comments_all, get_comments_by_history_id, manage_like_by_comment_id
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.schemas import CommentDelete, ManageLikeComment, CommentOut, CommentCreate

comment_router = r = APIRouter()

@r.post("/comments", response_model=CommentOut, response_model_exclude_none=True)
async def comment_create(
    request: Request,
    comment: CommentCreate,
    db=Depends(get_db),
):
    print(comment.history_id)
    return create_comment(db, comment, request.headers["x-forwarded-for"])

@r.get("/comments", response_model=t.List[CommentOut], response_model_exclude_none=True)
async def comments_all(
    request: Request,
    db=Depends(get_db),
):
    return get_comments_all(db)

@r.get(
    "/comments/{post_id}",
    response_model=t.List[CommentOut],
    response_model_exclude_none=True,
)
async def comments_list(
    response: Response,
    post_id:int,
    db=Depends(get_db),
):
    comments = get_comments_by_history_id(db, post_id)
    return comments
    # This is necessary for react-admin to work

@r.patch(
    "/comments/likes/{comment_id}",
    response_model=CommentOut,
    response_model_exclude_none=True,
)
async def comment_likes(
    response: Response,
    likeContent:ManageLikeComment,
    db=Depends(get_db),
):
    comments = manage_like_by_comment_id(db, likeContent)
    # This is necessary for react-admin to work
    return comments

@r.delete(
    "/comment/{comment_id}", response_model=CommentOut, response_model_exclude_none=True
)
async def comment_auth_delete(
    request: Request,
    comment:CommentDelete,
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    return delete_auth_comment(db, comment.id, user)
