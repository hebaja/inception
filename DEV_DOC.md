# Developer Documentation — Inception

## Prerequisites

- **Docker** (with Compose V2 plugin, included by default in recent Docker Desktop and Docker Engine releases)
- **Make**
- **Alpine Linux** awareness — all base images are `alpine:3.23.5` (no pre-built application images from Docker Hub are allowed per 42 subject constraints)

## Setup

Clone the repository and ensure the following directory structure exists:

```
data/mariadb/       # bind-mount target for MariaDB data
data/wordpress/     # bind-mount target for WordPress files
secrets/            # password files (gitignored)
```

Default secrets are provided in `secrets/`. The `.env` file in `srcs/` contains the configurable environment variables.

## Configuration Reference

### `srcs/.env`

| Variable          | Value                        | Description                       |
|-------------------|------------------------------|-----------------------------------|
| `DOMAIN_NAME`     | `hebatist.42.fr`             | Domain for WordPress and TLS CN   |
| `DB_NAME`         | `wordpress`                  | MariaDB database name             |
| `DB_USER`         | `wp_user`                    | MariaDB application user          |
| `WP_TITLE`        | `inception`                  | WordPress site title              |
| `WP_ADMIN_USER`   | `root`                       | WordPress admin username          |
| `WP_USER`         | `hebatist`                   | WordPress subscriber username     |
| `WP_USER_EMAIL`   | `hebatist@student.42.rio`    | Subscriber email                  |
| `WP_ADMIN_EMAIL`  | `hebaja@yahoo.com.br`        | Admin email                       |

### Secrets (`secrets/*.txt`)

| File                     | Mount Path (container)       | Used In                |
|--------------------------|------------------------------|------------------------|
| `db_password.txt`        | `/run/secrets/db_password`   | mariadb, wordpress     |
| `db_root_password.txt`   | `/run/secrets/db_root_password` | mariadb             |
| `wp_admin_password.txt`  | `/run/secrets/wp_admin_password` | wordpress          |
| `wp_user_password.txt`   | `/run/secrets/wp_user_password` | wordpress          |

## Makefile Targets

| Target     | Effect                                                     |
|------------|------------------------------------------------------------|
| `all`      | Alias for `up`                                             |
| `up`       | `docker compose up -d` — build and start in detached mode  |
| `down`     | `docker compose down` — stop and remove containers         |
| `build`    | `docker compose build` — rebuild images without starting   |
| `rebuild`  | `docker compose up -d --build` — rebuild and restart       |
| `logs`     | `docker compose logs -f` — follow logs                     |
| `ps`       | `docker compose ps` — list container status                |
| `clean`    | `docker compose down -v` — stop and remove volumes         |
| `fclean`   | `docker compose down -v --rmi all --remove-orphans`        |

## Docker Compose Commands (without Make)

All Makefile targets wrap `docker compose -f srcs/docker-compose.yml`. You can use Compose directly:

```bash
docker compose -f srcs/docker-compose.yml up -d
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml build
```

## Architecture Overview

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   nginx      │────>│  wordpress   │────>│   mariadb    │
│  :443/TLS    │     │  :9000/FPM   │     │  :3306/MySQL │
│  TLSv1.2/1.3 │     │  WP-CLI      │     │  Alpine 3.23 │
│  Alpine 3.23 │     │  Alpine 3.23 │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
       │                     │                     │
       └──────────┬──────────┘─────────────────────┘
                  │
          ┌───────┴────────┐
          │  bridge network │
          │  "inception"    │
          └────────────────┘
```

All three containers share the `inception` bridge network. The `wordpress_data` volume is mounted read-write in WordPress and read-only in Nginx for static file serving. The `db_data` volume persists MariaDB data across restarts.

## Data Persistence

| Volume Name       | Host Path                          | Container Path         | Content                     |
|-------------------|------------------------------------|------------------------|-----------------------------|
| `wordpress_data`  | `/home/<USER>/data/wordpress/`     | `/var/www/html`        | WordPress core + uploads    |
| `db_data`         | `/home/<USER>/data/mariadb/`       | `/var/lib/mysql`       | MariaDB data files          |

The `<USER>` variable is resolved at runtime by Docker Compose. These are bind mounts — data survives container removal and is directly accessible on the host filesystem.

## Container Initialization Flow

1. **mariadb**: On first run, `init.sh` runs `mariadb-install-db`, starts the daemon temporarily, runs SQL to create the database and user (reading passwords from `/run/secrets/`), then shuts down. Subsequent runs skip initialization.
2. **wordpress**: `init.sh` polls MariaDB until it responds, then uses WP-CLI to download WordPress, create `wp-config.php`, install the site, and create the subscriber user. Idempotent — checks `wp core is-installed` first.
3. **nginx**: `init.sh` validates the config with `nginx -t` then starts Nginx in the foreground.

## Building Individual Images

```bash
docker compose -f srcs/docker-compose.yml build mariadb  # rebuild only MariaDB
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml build nginx
```

## Database Access

```bash
# Interactive shell as root (password: 123456)
docker exec -it mariadb mariadb -u root -p

# One-liner to list tables
docker exec mariadb mariadb -u root -p123456 wordpress -e "SHOW TABLES;"

# One-liner to query users
docker exec mariadb mariadb -u root -p123456 wordpress -e "SELECT user_login, user_email FROM wp_users;"
```

## Adding or Modifying Services

- **Add a new service**: Add a block under `services:` in `docker-compose.yml`, create a directory under `srcs/requirements/` with a `Dockerfile`, `conf/`, and `tools/`.
- **Change TLS domain**: Update `DOMAIN_NAME` in `srcs/.env` and rebuild the nginx image (the CN is baked into the self-signed certificate at build time in the Dockerfile).
- **Change WordPress admin user**: Update `WP_ADMIN_USER` in `srcs/.env` and run `make rebuild`. On first initialization the new values take effect; for existing installs, change credentials through the WordPress admin panel or via WP-CLI.
