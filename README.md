*This project has been created as part of the 42 curriculum by hebatist.*

## Description

**Inception** is a system administration project that involves setting up a small infrastructure using **Docker Compose**. The goal is to deploy a WordPress site powered by MariaDB, served through Nginx, with all services running in their own Docker containers built from **Alpine Linux** base images — without using pre-built Docker Hub images (except the base OS).

The infrastructure consists of three services:

- **nginx** — TLS-terminating reverse proxy listening on port 443 (TLSv1.2/TLSv1.3 only), proxying PHP requests to WordPress via FastCGI.
- **wordpress** — PHP-FPM running WordPress with WP-CLI for automated setup and configuration.
- **mariadb** — MariaDB database server, initialized with the WordPress database and application user on first run.

All containers run on a dedicated bridge network (`inception`), with data persisted through bind-mounted volumes and secrets managed via Docker's built-in secrets mechanism.

## Instructions

### Prerequisites

- Docker and Docker Compose (with Compose V2 support)

### Build and Run

```bash
make          # or make up — builds and starts all services
make build    # build images without starting
make rebuild  # rebuild and restart all services
make down     # stop containers
make logs     # view logs
make clean    # stop and remove volumes
make fclean   # full cleanup — remove volumes, images, orphans
```

Once running, WordPress is accessible at **https://hebatist.42.fr:443** (ensure the domain resolves to `127.0.0.1` in your `/etc/hosts` or DNS).

### Project Structure

```
├── Makefile
├── data/                   # bind-mount data (mariadb/, wordpress/)
├── secrets/                # Docker secrets (passwords)
└── srcs/
    ├── .env                # environment variables
    ├── docker-compose.yml  # service orchestration
    └── requirements/
        ├── mariadb/        # Dockerfile, conf/my.cnf, tools/init.sh
        ├── nginx/          # Dockerfile, conf/nginx.conf, tools/init.sh
        └── wordpress/      # Dockerfile, conf/www.conf, tools/init.sh
```

## Resources

- [Docker Documentation](https://docs.docker.com/) — containerization, Dockerfile syntax, Compose file reference.
- [42 Subject PDF](https://cdn.intra.42.fr/pdf/pdf/107303/en.wikipedia.org) — official project requirements and constraints.
- [WordPress Docker Handbook](https://github.com/docker/awesome-compose/tree/master/official-documentation-snippets) — community examples of LEMP stacks in Docker.
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php) — configuration directives for the `www.conf` pool.
- **AI assistance**: GitHub Copilot and Claude (Anthropic) were used during development for:
  - Drafting and debugging Dockerfile instructions (Alpine package names, multi-stage considerations).
  - Generating shell script logic for MariaDB initialization and WordPress setup with WP-CLI.
  - Troubleshooting Nginx FastCGI configuration and PHP-FPM pool settings.
  - Reviewing and refactoring Compose file syntax and volume/secret declarations.
