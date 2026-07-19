# pudding

Service Redis dockerisé, configurable par variables d'environnement.

## Prérequis

- [Docker](https://docs.docker.com/get-docker/) ≥ 24
- [Docker Compose](https://docs.docker.com/compose/) ≥ 2

## Démarrage rapide

```bash
cp .env.example .env   # ajuster si besoin
make up
make redis-ping        # → PONG
```

## Configuration

Copier `.env.example` en `.env` et adapter les valeurs :

| Variable | Défaut | Description |
|---|---|---|
| `COMPOSE_PROJECT_NAME` | `pudding` | Préfixe des containers et volumes |
| `REDIS_VERSION` | `7.2-alpine` | Tag de l'image Redis |
| `REDIS_HOST_PORT` | `6379` | Port hôte exposé |
| `TZ` | `Europe/Paris` | Timezone du container |

Les variables peuvent aussi être passées directement en préfixe de commande :

```bash
REDIS_HOST_PORT=6380 make up
```

## Commandes

```
make              # affiche l'aide complète

make up           # démarre Redis en arrière-plan
make down         # arrête les containers
make restart      # redémarre Redis
make logs         # suit les logs Redis
make ps           # liste les containers actifs

make redis-ping   # vérifie que Redis répond
make redis-cli    # ouvre un shell redis-cli interactif
make redis-info   # affiche les infos Redis (INFO)
make redis-monitor  # stream des commandes en temps réel

make redis-flush  # vide toutes les clés (confirmation requise)
make clean        # arrête et supprime les volumes
make purge        # clean + supprime les images
```

## Persistance

Les données sont stockées dans un volume Docker nommé `<COMPOSE_PROJECT_NAME>-redis-data` (par défaut `pudding-redis-data`). Le volume survit à `make down` ; utilisez `make clean` pour le supprimer.

## Redis

La configuration Redis est dans `redis.conf` (monté en lecture seule) :

- **Persistence** : RDB + AOF activés
- **Mémoire** : 256 MB max, politique `noeviction`
- **Healthcheck** : `redis-cli ping` toutes les 10 s
