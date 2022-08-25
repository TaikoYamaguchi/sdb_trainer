
import datetime
from pytz import timezone
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import typing as t

from . import models, schemas

def get_version(db: Session) -> schemas.VersionOut:
    db_version = db.query(models.Version).first()
    return db_version.version_num
