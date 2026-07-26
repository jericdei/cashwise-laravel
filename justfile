# List available commands
default:
    @just --list

# Dokploy creates this network on the server; locally we create it once ourselves,
# since compose.yaml references it as external (see compose.yaml for why)
_ensure-network:
    @docker network inspect dokploy-network >/dev/null 2>&1 || docker network create dokploy-network

# Start the local infrastructure services (Postgres, Redis, SeaweedFS)
up: _ensure-network
    docker compose up -d postgres redis seaweedfs seaweedfs-init

# Stop all running services
down:
    docker compose down

# Stop all services and delete their data volumes
destroy:
    docker compose down -v

# Restart the local infrastructure services
restart: down up

# Tail logs for the local infrastructure services
logs:
    docker compose logs -f postgres redis seaweedfs

# Start the infrastructure, then run the app locally with hot-reloading (serve/queue/vite/reverb)
dev: up
    composer run dev

# Drop all tables and re-run migrations against the dockerized database
fresh:
    php artisan migrate:fresh

# Open a psql shell into the dockerized Postgres
db:
    docker compose exec postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"'

# Open a redis-cli shell into the dockerized Redis
redis-cli:
    docker compose exec redis redis-cli

# Rebuild the app image (Dockerfile changes, new dependencies, etc.)
build:
    docker compose build app

# Build and run the full containerized stack (app, queue, scheduler, reverb), prod-like
full: _ensure-network
    docker compose up -d --build
