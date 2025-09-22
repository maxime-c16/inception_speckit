# Build & Deploy Guide — Inception Project

This document describes how to create, build, and run the Inception multi-container project from scratch. It is intended for evaluators, maintainers, and contributors who need a step-by-step reproduction of the environment.

Contents
- Prerequisites
- Repository layout and important files
- Create a fresh project workspace (from scratch)
- Build and run (development and CI-ready steps)
- Validation and health checks (service-by-service)
- Best practices and security guidance
- Troubleshooting
- References

Prerequisites
- Operating system: macOS / Linux (commands shown assume macOS zsh but are POSIX-compliant where possible)
- Docker (Engine) >= 24.x and Docker Compose (v2 integrated) — verify with:
  - `docker --version`
  - `docker compose version`
- GNU Make (optional: `make` targets are provided for convenience)
- A POSIX shell (`bash`/`zsh`) and common tools: `curl`, `openssl`, `jq` (recommended for JSON output parsing)

Repository layout (top-level highlights)
- `docker-compose.yml` — defines all services, networks, volumes, and build context
- `srcs/` — Dockerfiles and service content (nginx, wordpress, mariadb, redis, static, adminer, extra)
- `specs/001-build-a-containerized/` — feature spec, plan, and tasks (useful for reviewers)
- `.specify/` — templates and scripts used to generate specs and agent artifacts
- `DOCS/BUILD_AND_DEPLOY.md` — this guide

Environment variables and `.env`
- Copy the example env: `cp .env.example .env` and edit sensitive values.
- Important variables (from `.env.example`):
  - `MYSQL_ROOT_PASSWORD` — MariaDB root password
  - `MYSQL_DATABASE` — default DB: `wordpress`
  - `MYSQL_USER` / `MYSQL_PASSWORD` — WordPress DB user
  - `WORDPRESS_DB_HOST` / `WORDPRESS_DB_USER` / `WORDPRESS_DB_PASSWORD` — WordPress DB connection
  - `REDIS_PASSWORD` — Redis authentication password
- Security note: Do not commit `.env` to source control. Use Docker secrets for production.

Create a fresh project workspace (from scratch)
1. Clone the repository:

```bash
git clone <your-repo-url> inception
cd inception
```

2. Prepare environment variables:

```bash
cp .env.example .env
# Edit `.env` and set strong passwords for production. Example:
# MYSQL_ROOT_PASSWORD=supersecret_root_pw
# MYSQL_PASSWORD=strong_wp_password
# REDIS_PASSWORD=another_strong_password
```

3. (Optional) Inspect the `specs/001-build-a-containerized` feature plan and tasks for evaluation criteria:

```bash
sed -n '1,200p' specs/001-build-a-containerized/spec.md
sed -n '1,200p' specs/001-build-a-containerized/plan.md
```

Build and run (local development)
1. Build all images (uses local Dockerfiles in `srcs/`):

```bash
make build
# or directly:
docker compose build --parallel
```

2. Run the stack in detached mode:

```bash
make up
# or:
docker compose up -d
```

3. Ensure the network and containers are running:

```bash
docker compose ps --all
```

Service ports (defaults in this project)
- NGINX (HTTPS): `443` (mapped on host) — site configured for `macauchy.42.fr` using a bundled self-signed cert. Add `/etc/hosts` entry for local testing:

```bash
echo '127.0.0.1 macauchy.42.fr' | sudo tee -a /etc/hosts
```

- Static site: `http://localhost:8080`
- Adminer: `http://localhost:8081`

Validation and health checks (service-by-service)
Run these checks after `docker compose up -d`.

NGINX (TLS + proxy)
- Check container status: `docker compose ps nginx`
- Check logs: `docker compose logs --tail=200 nginx`
- Test TLS and HTTP behavior:

```bash
curl -vk https://macauchy.42.fr --resolve macauchy.42.fr:443:127.0.0.1
# expect TLS handshake and redirect to WordPress install or site root
```

Static site
- Confirm `index.html` content inside the static container:

```bash
docker compose exec static cat /usr/share/nginx/html/index.html
curl -sS -o /dev/null -w "%{http_code}\n" http://localhost:8080
# expect 200
```

WordPress (php-fpm)
- Confirm php-fpm is running and listening on 9000 inside the `wordpress` container:

```bash
docker compose exec wordpress ps aux | grep php-fpm
docker compose exec wordpress netstat -ltnp || true
```
- Confirm WordPress files are present in the `wp_data` volume:

```bash
docker compose exec wordpress ls -la /var/www/html
```

MariaDB
- Check logs and readiness:

```bash
docker compose logs --tail=200 mariadb
docker compose exec mariadb mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"
```

Redis
- Verify Redis is ready and authenticates with the password from `.env`:

```bash
docker compose exec redis redis-cli -a "$REDIS_PASSWORD" ping
# expect PONG
```

Adminer
- Open `http://localhost:8081` and connect to MariaDB with the credentials from `.env`.

Persistence tests (volumes)
- Verify volumes persist across stop/start (example):

```bash
# record checksum of a WordPress config file
docker compose exec wordpress md5sum /var/www/html/wp-config.php
docker compose exec mariadb stat -c '%n %s %Y' /var/lib/mysql/ibdata1

docker compose down
docker compose up -d

docker compose exec wordpress md5sum /var/www/html/wp-config.php  # should match
docker compose exec mariadb stat -c '%n %s %Y' /var/lib/mysql/ibdata1 # should match
```

Best practices and security guidance
- Use a `.env` for development only. Do not commit it. For production, use Docker secrets or a secrets manager.
- Use strong, unique passwords for `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, and `REDIS_PASSWORD`.
- Limit surface area: only expose ports that must be reachable from the host.
- Do not run debug or dev tools in production images. Use transient containers (as shown for WP-CLI) to perform one-time admin tasks.
- TLS: Replace the self-signed cert with a CA-signed certificate for production; keep private keys with strict permissions (600).
- Backups: Add scheduled backups for `inception_db_data` and `inception_wp_data` volumes (cron job or external backup system).

Troubleshooting tips (common problems)
- nginx not starting: check `docker compose logs nginx`. Common causes: missing certificate (PEM parse error), permission issues on `/run` or `/var/cache/nginx`.
- WordPress shows 502/504: verify php-fpm is running in the `wordpress` container and the NGINX config has the correct `fastcgi_pass` target.
- Redis AUTH errors: ensure `REDIS_PASSWORD` matches between `.env` and the redis command in `docker-compose.yml`.
- DNS / NXDOMAIN for `macauchy.42.fr`: add `127.0.0.1 macauchy.42.fr` to `/etc/hosts` when testing locally and flush DNS cache.

References and further reading
- Docker documentation: https://docs.docker.com
- Docker Compose: https://docs.docker.com/compose/
- WordPress in Docker: https://hub.docker.com/_/wordpress
- MariaDB official image: https://hub.docker.com/_/mariadb
- Redis docs: https://redis.io/documentation

Appendix: Spec and plan references
- See `specs/001-build-a-containerized/spec.md` and `specs/001-build-a-containerized/plan.md` for the project evaluation criteria and tasks used while building this environment.

---
Generated by the project maintainer workflow. If you want, I can add a CI job that runs these validation steps automatically and pushes test results to the repository.
