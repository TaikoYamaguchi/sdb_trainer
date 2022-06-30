
from app.db.crud import edit_image_by_user_email
from app.core.auth import get_current_user
import os
import shutil
from app.db.crud_image import create_temporay_image, get_image_by_id
from fastapi import APIRouter, Response, File, UploadFile, Depends
import typing as t
import uuid
from fastapi.responses import FileResponse
from app.core.image_resize import image_resize
from app.db.session import get_db
from app.db.schemas import TemporaryImage 
images_router = r = APIRouter()



@r.post("/temp/images", response_model=TemporaryImage, response_model_exclude_none=True)
async def create_image( db=Depends(get_db),

    user=Depends(get_current_user),
    file : UploadFile = File(...)):
    print("sssssssssssssssssssssssssssssssss")
    print(file)
    print(file.filename)

    format = file.content_type.replace("image/","")
    if (format == "jpeg"):
        format = "jpg"

    BASE_DIR=os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
    file_uuid=str(uuid.uuid4())

    file_path=os.path.join(BASE_DIR, "images",file_uuid+".png")
    print(file)
    print(file_path)
    if not os.path.exists(BASE_DIR):
        os.mkdir(BASE_DIR)
    if not os.path.exists(BASE_DIR+"/images"):
        os.mkdir(BASE_DIR+"/images")

    with open(file_path,"wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    image_resize(file_path)
    db_image = create_temporay_image(db, file_path)
    edit_image_by_user_email(db, user,db_image.id)

    return db_image

@r.get(
    "/images/{image_id}"
, response_class=FileResponse)
async def get_image( 
    response: Response,
    image_id:int,
    db=Depends(get_db),
):
    image = get_image_by_id(db, image_id)
    return FileResponse(image)
