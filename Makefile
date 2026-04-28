# ============================================================
#  Configuration — override via env var or .env file
# ============================================================
COMPOSE_PROJECT_NAME ?= pudding
REDIS_VERSION        ?= 7.2-alpine
REDIS_HOST_PORT      ?= 6379
TZ                   ?= Europe/Paris

COMPOSE := docker compose
REDIS_CLI := docker compose exec redis redis-cli

# Load .env if present (does not override already-set env vars)
-include .env

# ============================================================
.DEFAULT_GOAL := help

.PHONY: help up down restart logs ps redis-cli redis-ping \
        redis-info redis-flush redis-monitor clean purge

help: ## Show this help
	@printf "\n\033[1mUsage:\033[0m make \033[36m<target>\033[0m\n"
	@printf "\n\033[1mAvailable targets:\033[0m\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@printf "\n\033[1mEnvironment variables:\033[0m\n\n"
	@printf "  \033[33m%-25s\033[0m %s\n" "COMPOSE_PROJECT_NAME" "Container/volume prefix         (default: pudding)"
	@printf "  \033[33m%-25s\033[0m %s\n" "REDIS_VERSION"        "Redis Docker image tag          (default: 7.2-alpine)"
	@printf "  \033[33m%-25s\033[0m %s\n" "REDIS_HOST_PORT"      "Host port mapped to Redis 6379  (default: 6379)"
	@printf "  \033[33m%-25s\033[0m %s\n" "TZ"                   "Container timezone              (default: Europe/Paris)"
	@printf "\n"

# ============================================================
#  Lifecycle
# ============================================================
up: ## Start Redis in background
	$(COMPOSE) up -d --remove-orphans

down: ## Stop and remove containers
	$(COMPOSE) down

restart: ## Restart Redis
	$(COMPOSE) restart redis

logs: ## Follow Redis logs (Ctrl-C to stop)
	$(COMPOSE) logs -f redis

ps: ## Show running containers
	$(COMPOSE) ps

# ============================================================
#  Redis helpers
# ============================================================
redis-cli: ## Open an interactive redis-cli session
	$(REDIS_CLI)

redis-ping: ## Ping Redis
	$(REDIS_CLI) ping

redis-info: ## Show Redis INFO
	$(REDIS_CLI) info

redis-monitor: ## Stream Redis commands in real-time (Ctrl-C to stop)
	$(REDIS_CLI) monitor

redis-flush: ## Flush ALL keys — DANGER
	@printf "\033[31mThis will delete all data. Continue? [y/N] \033[0m" && read ans && [ "$${ans:-N}" = y ]
	$(REDIS_CLI) flushall

# ============================================================
#  Cleanup
# ============================================================
clean: down ## Stop containers and remove volumes
	$(COMPOSE) down -v

purge: clean ## Full purge: containers, volumes, images
	$(COMPOSE) down -v --rmi all
