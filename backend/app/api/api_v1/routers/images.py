
from app.db.crud_history import edit_image_by_history_id, edit_image_by_history_id_list, remove_image_by_history_id
from app.db.crud_famous import edit_image_by_famous_id
from app.db.crud import edit_image_by_user_email
from app.core.auth import get_current_user
import os
import shutil
from app.db.crud_image import create_temporary_image, get_image_by_id
from fastapi import APIRouter, Response, File, UploadFile, Depends
import typing as t
import uuid
from fastapi.responses import FileResponse
from app.core.image_resize import image_resize
from app.db.session import get_db
from app.db.schemas import HistoryImage, TemporaryImage, HistoryOut, User, FamousOut
images_router = r = APIRouter()
from typing import List



@r.post("/temp/images", response_model=User, response_model_exclude_none=True)
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
    db_image = create_temporary_image(db, file_path)
    print("ueeeeeeeeeeeeeeeeeeeeeees")
    print(db_image)
    db_user = edit_image_by_user_email(db, user,db_image.id)
    print(db_user)

    return db_user

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

@r.put(
    "/remove/historyimages/{history_id}"
, response_model=HistoryOut)
async def remove_history_image( 
    response: Response,
    history_id:int,
    db=Depends(get_db),
):
    user=Depends(get_current_user)
    db_history = remove_image_by_history_id(db, user, history_id)
    return db_history

@r.put(
    "/temp/historyimages/{history_id}"
, response_model=HistoryOut)
async def edit_history_image( 
    response: Response,
    history_id:int,
    images:HistoryImage,
    user=Depends(get_current_user),
    db=Depends(get_db),
):
    user=Depends(get_current_user)
    db_history = edit_image_by_history_id_list(db,history_id,images.image)
    return db_history

@r.post("/temp/historyimages/{history_id}", response_model=HistoryOut, response_model_exclude_none=True)
async def create_history_image(history_id:int, db=Depends(get_db),

    user=Depends(get_current_user),
    files : List[UploadFile] = File(...)):
    print(files);
    for file in files:

        format = file.content_type.replace("image/","")
        if (format == "jpeg"):
            format = "jpg"

        BASE_DIR=os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
        file_uuid=str(uuid.uuid4())

        file_path=os.path.join(BASE_DIR, "images",file_uuid+".png")
        if not os.path.exists(BASE_DIR):
            os.mkdir(BASE_DIR)
        if not os.path.exists(BASE_DIR+"/images"):
            os.mkdir(BASE_DIR+"/images")

        with open(file_path,"wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        image_resize(file_path)
        db_image = create_temporary_image(db, file_path)
        db_history = edit_image_by_history_id(db, user,history_id,db_image.id)

    return db_history

@r.post("/temp/famousimages/{famous_id}", response_model=FamousOut, response_model_exclude_none=True)
async def create_famous_image(famous_id:int, db=Depends(get_db),

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
    db_image = create_temporary_image(db, file_path)
    print("ueeeeeeeeeeeeeeeeeeeeeees")
    print(db_image)
    db_famous = edit_image_by_famous_id(db, user,famous_id,db_image.id)
    print(db_famous)

    return db_famous
