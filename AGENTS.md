# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A standalone Docker service exposing a Redis instance. Entry point is the `Makefile` — `make` (no args) prints the full help.

## Common commands

```bash
make up           # start Redis in background
make down         # stop containers
make restart      # restart Redis
make logs         # follow Redis logs
make redis-ping   # verify Redis is up (→ PONG)
make redis-cli    # interactive redis-cli shell
make redis-info   # Redis INFO output
make redis-flush  # flush all keys (prompts for confirmation)
make clean        # stop + remove volumes
make purge        # stop + remove volumes + remove images
```

## Environment variables

All variables have defaults and can be overridden via `.env` (copy from `.env.example`) or as shell prefixes:

| Variable | Default | Purpose |
|---|---|---|
| `COMPOSE_PROJECT_NAME` | `pudding` | Prefix for container and volume names |
| `REDIS_VERSION` | `7.2-alpine` | Redis Docker image tag |
| `REDIS_HOST_PORT` | `6379` | Host port mapped to Redis |
| `TZ` | `Europe/Paris` | Timezone inside the container |

`.env` is gitignored. Never commit it.

## Architecture

- `docker-compose.yml` — single `redis` service; image tag, port, and project name driven by env vars
- `redis.conf` — mounted read-only into the container; controls persistence (RDB + AOF), memory cap (256 MB, `noeviction`), and logging
- `Makefile` — all operational tasks; variables default-set at the top, `.env` loaded with `-include` so it never overrides shell env

Data is persisted in a named Docker volume `<COMPOSE_PROJECT_NAME>-redis-data`.
