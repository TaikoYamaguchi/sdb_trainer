from app.db import models
from fastapi import FastAPI, Depends
from starlette.requests import Request
from app.db.session import engine
import uvicorn

from app.api.api_v1.routers.users import users_router
from app.api.api_v1.routers.auth import auth_router
from app.api.api_v1.routers.workout import workout_router
from app.api.api_v1.routers.history import history_router
from app.api.api_v1.routers.exercise import exercise_router
from app.api.api_v1.routers.comment import comment_router
from app.api.api_v1.routers.videos import videos_router
from app.api.api_v1.routers.images import images_router
from app.api.api_v1.routers.version import version_router
from app.api.api_v1.routers.famous import famous_router
from app.core import config
from app.db.session import SessionLocal
from app.core.auth import get_current_active_user
from app.core.celery_app import celery_app
from app import tasks

models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=config.PROJECT_NAME, docs_url="/api/docs", openapi_url="/api"
)


@app.middleware("http")
async def db_session_middleware(request: Request, call_next):
    request.state.db = SessionLocal()
    response = await call_next(request)
    request.state.db.close()
    return response


@app.get("/api/v1")
async def root():
    return {"message": "hello from Backend"}


@app.get("/api/v1/task")
async def example_task():
    celery_app.send_task("app.tasks.example_task", args=["Hello World"])

    return {"message": "success"}


# Routers
app.include_router(
    users_router,
    prefix="/api/v1",
    tags=["users"],
    dependencies=[Depends(get_current_active_user)],
)
app.include_router(auth_router, prefix="/api", tags=["auth"])
app.include_router(workout_router, prefix="/api", tags=["workout"])
app.include_router(history_router, prefix="/api", tags=["history"])
app.include_router(exercise_router, prefix="/api", tags=["exercise"])
app.include_router(comment_router, prefix="/api", tags=["comment"])
app.include_router(videos_router, prefix="/api", tags=["videos"])
app.include_router(images_router, prefix="/api", tags=["images"])
app.include_router(version_router, prefix="/api", tags=["version"])
app.include_router(famous_router, prefix="/api", tags=["famous"])

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", reload=True, port=8888)
