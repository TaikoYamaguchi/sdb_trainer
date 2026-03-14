# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run all backend tests
./scripts/test_backend.sh          # from repo root

# Run specific test
./scripts/test_backend.sh -v -k <test_name>

# Apply DB migrations
docker-compose run --rm backend alembic upgrade head

# Create new migration
docker-compose run --rm backend alembic revision --autogenerate -m "description"

# Seed initial data
docker-compose run --rm backend python3 app/initial_data.py

# Start all services
docker-compose up --build
```

## Architecture

### Request Lifecycle

```
HTTP Request
  → Nginx (:8000)
  → FastAPI (:8888)  [db_session_middleware attaches SessionLocal to request.state.db]
  → Router           [Depends(get_db) injects session; Depends(get_current_active_user) validates JWT]
  → CRUD function    [operates on db session]
  → Response
```

### Directory Layout

```
app/
├── main.py              # App factory, middleware, router registration
├── tasks.py             # Celery async task definitions
├── initial_data.py      # DB seeding
├── api/api_v1/routers/  # One file per domain (see below)
├── core/
│   ├── config.py        # Settings (reads DATABASE_URL env var)
│   ├── auth.py          # get_current_user, get_current_active_user, authenticate_user
│   ├── security.py      # JWT create/verify, bcrypt password hashing
│   ├── celery_app.py    # Celery + Redis broker config
│   └── sms.py           # Twilio SMS
├── db/
│   ├── models.py        # All SQLAlchemy models
│   ├── schemas.py       # All Pydantic request/response schemas
│   ├── session.py       # Engine, SessionLocal, get_db()
│   └── crud_*.py        # One CRUD module per domain
└── alembic/             # Migration scripts (24 versions)
```

### Routers

| File | URL Prefix | Auth Required |
|------|-----------|---------------|
| `auth.py` | `/api` | No (login/signup) |
| `users.py` | `/api/v1/users` | Yes (JWT) |
| `workout.py` | `/api` | No |
| `history.py` | `/api` | Mixed |
| `exercise.py` | `/api` | No |
| `comment.py` | `/api` | Mixed |
| `famous.py` | `/api` | No |
| `interview.py` | `/api` | No |
| `images.py` | `/api` | No |
| `videos.py` | `/api` | No |
| `notification.py` | `/api/v1` | Yes |
| `version.py` | `/api` | No |

### Database Models

**User** — Core entity. Has ARRAY columns for social graph (`like`, `liked`, `dislike`, `disliked`) and `favor_exercise`. `body_stats` is JSON. FCM token stored in `fcm_token`.

**Workout** — One row per user (`user_email` unique). `routinedatas` is JSON holding the full routine structure.

**History** — Workout log entries, visible in the feed. `exercises` is JSON. Has `isVisible` for privacy. `like`/`dislike` are ARRAY of email strings.

**Exercises** — Per-user exercise catalog. `exercises` is JSON.

**Comment** — Linked to `history_id`. Supports replies via `reply_id`. Includes `likes`/`dislikes` ARRAY. Anonymous comments use `password` field.

**Famous** / **Interview** — Content tables for curated workout programs and Q&A posts.

**TemporaryImage / TemporaryVideo** — Staging tables for media uploads before association.

**Version** — App version metadata keyed by `version_num`.

### CRUD Pattern

All `crud_*.py` files follow the same pattern:

```python
def create_X(db: Session, data: schemas.XCreate) -> models.X:
    db_obj = models.X(**data.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

def edit_X(db: Session, data: schemas.XUpdate) -> models.X:
    db_obj = get_X_by_id(db, data.id)
    for key, value in data.dict(exclude_unset=True).items():
        setattr(db_obj, key, value)
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj
```

Deletes use try/except with `db.rollback()` on failure.

### Authentication

- **JWT** via `PyJWT` (HS256). Token payload: `{sub: email, permissions: "user"|"admin"}`.
- **OAuth** via `Authlib` — Kakao OAuth flow through `/api/tokenkakao/{email}`.
- **Firebase Admin SDK** — Token verification for Firebase-authenticated users.
- Guards: `Depends(get_current_active_user)` for user routes, `Depends(get_current_active_superuser)` for admin routes.

### Async / Background Tasks

Heavy operations (FCM push notifications to followers) use `asyncio.create_task()` directly inside route handlers — not Celery. Celery (`app.tasks.*` on the `main-queue`) is set up but used minimally. Redis broker: `redis://redis:6379/0`.

### Testing

`conftest.py` sets up:
- A `_test`-suffixed PostgreSQL database created/dropped once per session.
- Per-test transaction rollback for isolation.
- Fixtures: `test_db`, `client`, `test_user`, `test_superuser`, `user_token_headers`, `superuser_token_headers`.

Monkeypatching is used to bypass bcrypt in token header fixtures.

### Key Configuration Notes

- `DATABASE_URL` must be set as an environment variable (no default).
- CORS is restricted to `http://localhost:3000` only.
- `client_max_body_size` for file uploads is controlled by Nginx (50MB), not FastAPI.
- Datetime fields use UTC+9 (KST) via `datetime.utcnow() + timedelta(hours=9)`.
- API docs available at `/api/cksdnr1/docs` (non-standard path for mild obscurity).
