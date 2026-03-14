#!/bin/bash

# Usage:
#   dev:  ./scripts/build.sh dev
#   prod: ./scripts/build.sh prod (default)

ENV=${1:-prod}

if [ "$ENV" = "dev" ]; then
  COMPOSE_CMD="docker compose -p supero-dev -f docker-compose.yml -f docker-compose.dev.yml"
else
  COMPOSE_CMD="docker compose -p supero-prod -f docker-compose.yml -f docker-compose.prod.yml"
fi

# Build and run containers
$COMPOSE_CMD up -d --build

# Wait for postgres to be ready
sleep 5

# Run migrations
$COMPOSE_CMD run --rm backend alembic upgrade head

# Create initial data
$COMPOSE_CMD run --rm backend python3 app/initial_data.py
