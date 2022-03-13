#!/usr/bin/env python3

from app.db.crud_workout import create_workout
from datetime import datetime, timezone
from app.db.session import get_db
from app.db.crud import create_user
from app.db.schemas import UserCreate, WorkoutCreate
from app.db.session import SessionLocal


def init() -> None:
    db = SessionLocal()

    create_user(
        db,
        UserCreate(
            email="cksdnr1@gmail.com",
            nickname="3대500",
            username="찬욱",
            phone_number="01048439859",
            level=999,
            point=99999,
            height=183.0,
            weight=85.0,
            height_unit="cm",
            weight_unit="kg",
            password="1234",
            is_active=True,
            is_superuser=True,
            created_at=datetime.now(),
            modified_at=datetime.now(),
            image="",
        ),
    )

    create_workout(
        db,
        WorkoutCreate(
            user_email="cksdnr1@gmail.com",
            name="타격감운동",
            exercises=[
                {
                    "name": "벤치프레스",
                    "sets": [
                        {
                            "index": 1,
                            "weight": 105.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 2,
                            "weight": 110.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 3,
                            "weight": 85.3,
                            "reps": 10,
                            "ischecked": False,
                        },
                    ],
                    "onerm": 115.3,
                    "rest": 180,
                },
                {
                    "name": "스쿼트",
                    "sets": [
                        {
                            "index": 1,
                            "weight": 120.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 2,
                            "weight": 130.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 3,
                            "weight": 100.3,
                            "reps": 6,
                            "ischecked": False,
                        },
                        {
                            "index": 4,
                            "weight": 80.3,
                            "reps": 10,
                            "ischecked": False,
                        },
                    ],
                    "onerm": 140.3,
                    "rest": 240,
                },
                {
                    "name": "데드리프트",
                    "sets": [
                        {
                            "index": 1,
                            "weight": 80.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 2,
                            "weight": 100.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 3,
                            "weight": 120.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 4,
                            "weight": 140.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 5,
                            "weight": 160.3,
                            "reps": 1,
                            "ischecked": False,
                        },
                        {
                            "index": 6,
                            "weight": 130.3,
                            "reps": 10,
                            "ischecked": False,
                        },
                    ],
                    "onerm": 180.3,
                    "rest": 240,
                },
            ],
            routine_time=60,
        ),
    )


if __name__ == "__main__":
    print("Creating superuser cksdnr1@gmail.com")
    init()
    print("Superuser created")
