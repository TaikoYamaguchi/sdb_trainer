from app.db.crud_famous import create_famous, get_famouss_by_type, edit_famous, delete_famous
from fastapi import APIRouter, Request, Depends, Response, encoders
import typing as t

from app.db.session import get_db
from app.db.schemas import FamousCreate, FamousOut


famous_router = r = APIRouter()

@r.post("/famouscreate", response_model=FamousCreate, response_model_exclude_none=True)
async def famous_create(
    request: Request,
    famous: FamousCreate,
    db=Depends(get_db),
):
    return create_famous(db, famous)

@r.get(
    "/famous/{type}",
    response_model=FamousOut,
    response_model_exclude_none=True,
)
async def famouss_list(
    response: Response,
    email:str,
    db=Depends(get_db),
):

    famouss = get_famouss_by_type(db, type)
    print(famouss)
    # This is necessary for react-admin to work
    return famouss

@r.get(
    "/famous",
    response_model=FamousOut,
    response_model_exclude_none=True,
)
async def famouss_list(
    response: Response,
    email:str,
    db=Depends(get_db),
):

    famouss = get_famouss(db)
    print(famouss)
    # This is necessary for react-admin to work
    return famouss

@r.put("/famous", response_model=FamousCreate, response_model_exclude_none=True)
async def famous_edit(
    request: Request,
    famous: FamousCreate,
    db=Depends(get_db),
):
    return edit_famous(db, famous)

@r.delete("/famous/{id}", response_model=FamousCreate, response_model_exclude_none=True)
async def famous_delete(
    request: Request,
    id: int,
    db=Depends(get_db),
):
    return delete_famous(db, id)

