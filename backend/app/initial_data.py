#!/usr/bin/env python3

from datetime import datetime, timezone
from app.db.session import get_db
from app.db.crud import create_user
from app.db.schemas import PostCreate, UserCreate
from app.db.session import SessionLocal
from app.db.crud_post import create_post



def init() -> None:
    db = SessionLocal()

    create_user(
        db,
        UserCreate(
            email="cksdnr1@gmail.com",
            nickname="찬욱",
            phone_number="01048439859",
            level=999,
            point=99999,
            password="1234",
            is_active=True,
            is_superuser=True,
            created_at =datetime.now(),
            modified_at =datetime.now(),
            image="",
            selfIntroduce="yeahhhh"
        ),
    )



if __name__ == "__main__":
    print("Creating superuser cksdnr1@gmail.com")
    init()
    print("Superuser created")
