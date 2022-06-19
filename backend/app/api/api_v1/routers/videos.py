
from app.db.crud_video import create_temporay_video, get_video_by_name
import os
import shutil
from fastapi import APIRouter, Response, File, UploadFile, Depends
import typing as t
import uuid
from fastapi.responses import FileResponse
from app.db.session import get_db
from app.db.schemas import TemporaryVideo 
videos_router = r = APIRouter()



@r.post("/temp/videos", response_model=TemporaryVideo, response_model_exclude_none=True)
async def create_video( db=Depends(get_db),
    file : UploadFile = File(...)):

    format = file.content_type.replace("video/","")

    BASE_DIR=os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    file_uuid=str(uuid.uuid4())

    file_path=os.path.join(BASE_DIR, "videos",file_uuid+"."+format)
    print(file_path)
    if not os.path.exists(BASE_DIR):
        os.mkdir(BASE_DIR)

    with open(file_path,"wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return create_temporay_video(db, file_path)

@r.get(
    "/videos/{video}"
, response_class=FileResponse)
async def get_video( 
    response: Response,
    video:str,
    db=Depends(get_db),
):
    video = get_video_by_name(db, video)
    return FileResponse(video)
