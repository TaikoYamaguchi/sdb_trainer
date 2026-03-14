# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**sdb_trainer** is a weight-lifting trainer mobile app. Users log workouts, view statistics, and interact socially. It consists of a Flutter mobile frontend and a Python FastAPI backend, containerized with Docker.

## Commands

### Backend

```bash
# Start all services (Nginx, Postgres, Redis, Celery, ELK stack)
./scripts/build.sh

# Run backend tests
./scripts/test_backend.sh

# Run specific tests
./scripts/test_backend.sh -v -k <test_name>

# Database migrations
docker-compose run --rm backend alembic upgrade head

# Seed initial data
docker-compose run --rm backend python3 app/initial_data.py
```

### Flutter

```bash
cd flutter

# Install dependencies
flutter pub get

# Lint/analyze
flutter analyze

# Run tests
flutter test

# Run app
flutter run
```

## Architecture

### Data Flow

```
Flutter (Pages → Providers → Repository → HTTP) → Nginx (:8000) → FastAPI (:8888) → PostgreSQL / Redis
```

Async tasks (notifications, etc.) go through Celery workers backed by Redis. Firebase handles auth integration and push notifications.

### Flutter Frontend (`flutter/lib/`)

- **`pages/`** — Feature-organized UI: `exercise/`, `feed/`, `login/`, `mystat/`, `profile/`, `search/`, `statistics/`
- **`providers/`** — 17 `ChangeNotifier` providers for state management (one per domain: `userdata`, `workoutdata`, `historydata`, `exercisesdata`, `themeMode`, `notification`, etc.)
- **`repository/`** — 9 repository classes that wrap HTTP calls to the backend (the only place `http` package is used directly)
- **`src/model/`** — Dart data models
- **`src/blocs/`** — Event handlers
- **`navigators/`** — Navigation logic
- **`src/utils/localhost_aws.dart`** — Backend base URL (`http://43.200.121.48:8000`)

State flows: Pages read from Providers, Providers call Repositories, Repositories call the backend REST API.

### FastAPI Backend (`backend/app/`)

- **`main.py`** — App entry, middleware, router registration
- **`api/api_v1/routers/`** — 11 routers: `auth`, `users`, `workout`, `history`, `exercise`, `comment`, `videos`, `images`, `famous`, `interview`, `notification`, `version`
- **`db/models.py`** — SQLAlchemy models: `User`, `Workout`, `History`, `Exercises`, `Comment`, `TemporaryImage/Video`, `Version`
- **`db/crud*.py`** — CRUD operations per domain
- **`core/`** — JWT/OAuth auth (`auth.py`, `security.py`), Celery app, SMS (Twilio), config
- **`alembic/`** — DB migration scripts
- **`tests/`** — pytest suite (uses transaction rollback for test isolation via `conftest.py`)
- **`tasks.py`** — Celery async tasks

API docs auto-generated at `/api/cksdnr1/docs`.

### Infrastructure

| Service | Port | Purpose |
|---|---|---|
| Nginx | 8000 | Reverse proxy → backend :8888 |
| PostgreSQL 12 | 5432 | Primary database |
| Redis | 6379 | Cache + Celery broker |
| pgAdmin | 8088 | DB admin UI |
| Kibana | 5601 | Log viewer (ELK stack) |

### Authentication

Multi-auth: JWT, OAuth (Authlib), Firebase Admin SDK, Kakao, Google, Apple Sign-In. Firebase service account key lives at `backend/app/core/serviceAccountKey.json`.
