from app.db.crud_interview import get_interviews, get_interviews_by_email
from app.db.crud_interview import create_interview, delete_auth_interview, get_interviews_by_page, manage_like_by_interview_id
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t


from app.core.auth import get_current_active_user, get_current_user
from app.db.session import get_db
from app.db.schemas import InterviewCreate, InterviewOut, ManageLikeInterview
interview_router = r = APIRouter()

@r.post("/interviewcreate", response_model=InterviewOut, response_model_exclude_none=True)
async def interview_create(
    request: Request,
    interview: InterviewCreate,
    db=Depends(get_db),
):
    #return create_interview(db, interview, request.headers["x-forwarded-for"])
    return create_interview(db, interview, "noneip")

@r.get(
    "/interview/{email}",
    response_model=t.List[InterviewOut],
    response_model_exclude_none=True,
)
async def interviews_list_email(
    response: Response,
    email:str,
    db=Depends(get_db),
):

    interviews = get_interviews_by_email(db, email)
    # This is neSSScessaSSry for react-admin to work
    return interviews

@r.get(
    "/interview",
    response_model=t.List[InterviewOut],
    response_model_exclude_none=True,
)
async def interviews_list(
    response: Response,
    db=Depends(get_db),
    skip: int = 0, limit: int = 20
):

    interviews = get_interviews(db,skip,limit)
    # This is necessary for react-admin to work
    return interviews


@r.get(
    "/interviews/{interview_id}",
    response_model=t.List[InterviewOut],
    response_model_exclude_none=True,
)
async def interviews_list_by_page(
    response: Response,
    db=Depends(get_db),
    interview_id=int
):
    print(interview_id)

    interviews = get_interviews_by_page(db,20,interview_id)
    # This is necessary for react-admin to work
    return interviews



@r.patch(
    "/interview/likes/{interview_id}",
    response_model=InterviewOut,
    response_model_exclude_none=True,
)
async def interview_likes(
    response: Response,
    likeContent:ManageLikeInterview,
    db=Depends(get_db),
):
    interview = manage_like_by_interview_id(db, likeContent)
    # This is necessary for react-admin to work
    return interview

@r.delete(
    "/interviewDelete/{interview_id}", response_model=InterviewOut, response_model_exclude_none=True
)
async def interview_delete(
    response: Response,
    interview_id:int,
    db=Depends(get_db),
    user=Depends(get_current_user)
):
    return delete_auth_interview(db, interview_id, user)

