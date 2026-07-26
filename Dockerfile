# syntax=docker/dockerfile:1

FROM dunglas/frankenphp:php8.4 AS base

WORKDIR /app

# Node is needed at build time because the Wayfinder Vite plugin shells out to
# `php artisan` (to read routes/controllers) while `vite build` runs.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg git unzip \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions \
        pdo_pgsql \
        pgsql \
        redis \
        pcntl \
        bcmath \
        intl \
        zip \
        gd \
        opcache

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY docker/php/99-app.ini /usr/local/etc/php/conf.d/99-app.ini

# ---------------------------------------------------------------------------
FROM base AS build

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --no-scripts

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# public/frankenphp-worker.php is gitignored (Octane's own convention), so a
# fresh git clone never has it. Octane would otherwise try to create it at
# container boot, but by then we're the non-root www-data user and public/
# is read-only to it - bake it in now, as root, instead.
RUN cp vendor/laravel/octane/src/Commands/stubs/frankenphp-worker.php public/frankenphp-worker.php

# composer dump-autoload (not the earlier install) is what triggers
# package:discover, since it needs the full app/config to boot artisan.
RUN composer dump-autoload --no-dev --optimize \
    && cp .env.example .env \
    && php artisan key:generate --ansi \
    && npm run build \
    && rm .env

# ---------------------------------------------------------------------------
FROM base AS app

COPY --from=build /app /app

# Baked in at build time, not fixed at runtime: nothing mounts a volume over
# these paths, so the image's own ownership is the only ownership they get.
RUN mkdir -p /data/caddy /config/caddy \
    && chown -R www-data:www-data /app/storage /app/bootstrap/cache /data /config

# Non-privileged port: Dokploy/Traefik (or any reverse proxy) terminates
# TLS and forwards plain HTTP here, so Octane/FrankenPHP never needs to bind
# 80/443 or manage its own certificates.
EXPOSE 8080

USER www-data

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD php -r "exit(@file_get_contents('http://127.0.0.1:8080/up') === false ? 1 : 0);"

# CMD (not ENTRYPOINT) so the queue/scheduler/reverb services in compose.yaml
# can fully replace it with their own `command:` while sharing this image.
# Octane keeps the app booted in memory across requests instead of FrankenPHP
# rebooting it per-request - --max-requests recycles a worker as a leak guard.
CMD ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=8080", "--admin-port=2019", "--max-requests=500"]
