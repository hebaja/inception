# User Documentation — Inception

## Start / Stop the Stack

```bash
make        # build (if needed) and start all containers in detached mode
make up     # same as above
make down   # stop and remove containers (volumes and images are kept)
```

After `make up`, wait a few seconds for the database initialization and WordPress setup to complete. Use `make logs` to monitor progress.

## Access the Website

| Resource        | URL                                                   | Notes                          |
|-----------------|-------------------------------------------------------|--------------------------------|
| WordPress site  | `https://hebatist.42.fr`                              | Ensure DNS/hosts resolution    |
| Admin panel     | `https://hebatist.42.fr/wp-admin`                     | Login with admin credentials   |

Since the TLS certificate is self-signed, your browser will display a security warning — accept it to proceed.

### Resolve the Domain

Add this line to your `/etc/hosts` file (requires root):

```
127.0.0.1   hebatist.42.fr
```

## Credentials

Secrets are stored in `secrets/*.txt` files and mounted inside containers at `/run/secrets/`. Change any of these files before running `make rebuild` to apply updated credentials.

| Secret File               | Purpose                   | Default Value | Used By               |
|---------------------------|---------------------------|---------------|-----------------------|
| `secrets/db_password.txt` | WordPress DB user password | `feanor`      | WordPress, MariaDB    |
| `secrets/db_root_password.txt` | MariaDB root password | `123456`      | MariaDB               |
| `secrets/wp_admin_password.txt` | WordPress admin password | `123456`      | WordPress admin       |
| `secrets/wp_user_password.txt` | WordPress subscriber password | `feanor`      | WordPress subscriber  |

**Login credentials for the admin panel:**

| Role       | Username   | Password (default) |
|------------|------------|--------------------|
| Admin      | `root`     | `123456`           |
| Subscriber | `hebatist` | `feanor`           |

## Basic Health Checks

```bash
# Check container status
docker compose -f srcs/docker-compose.yml ps

# View live logs from all services
make logs

# Check if WordPress is responding
curl -k https://hebatist.42.fr

# Verify MariaDB is accepting connections
docker exec mariadb mariadb-admin ping -u wp_user -pfeanor
```

## Useful Commands

```bash
make logs     # tail logs from all containers
make ps       # list running containers
make down     # stop everything
make rebuild  # rebuild images and restart
make clean    # stop and remove volumes (data loss!)
make fclean   # full cleanup — volumes, images, orphans
```
