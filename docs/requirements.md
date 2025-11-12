# Inception Requirement Checklist

This repository targets the official Inception subject. The table below tracks the mandatory compliance points so they can be validated quickly before evaluation.

## Mandatory Items

- ✅ **Custom images**: Every service is built from a bespoke Dockerfile based on Debian Bullseye.
- ✅ **Dedicated containers**: nginx, wordpress (php-fpm), and mariadb each run in isolated containers on the `inception` bridge network.
- ✅ **TLS-only entrypoint**: nginx listens on `443` with TLSv1.2/TLSv1.3, renders its configuration from the `DOMAIN_NAME` environment variable, and self-generates certificates when missing.
- ✅ **Volumes**: Bind mounts at `/home/macauchy/data/mariadb` and `/home/macauchy/data/wordpress` satisfy persistence requirements.
- ✅ **Environment configuration**: Secrets live in `.env` (ignored by git) with `.env.example` as the template.
- ✅ **Restart policy**: All containers declare `restart: always`.
- ✅ **No hacky loops**: Entrypoints start the intended daemons without `tail -f`, `sleep infinity`, or similar anti-patterns.
- ✅ **Database hardening**: MariaDB initialization enforces credentials, prunes the test DB, and binds to all interfaces for container access.
- ✅ **Redis cache**: The WordPress setup script installs and enables the Redis Object Cache plugin when the cache service is available.

## WordPress User Requirement

> In your WordPress database, there must be two users, one of them being the administrator. The administrator’s username must not contain “admin”, “Admin”, “administrator”, or “Administrator” (e.g., admin, administrator, Administrator, admin-123, etc.).

Automation enforces this policy:

- `WORDPRESS_ADMIN_USER` is validated at container start-up; the stack aborts if the value contains the forbidden substring.
- The setup script guarantees the administrator account (default `wpowner`) and a secondary editor account (default `wpeditor`) exist on every run with the credentials supplied via environment variables.

## Operational Notes

- Run `make up` to build the images, prepare host data directories under `/home/macauchy/data`, and start the full stack.
- Copy `.env.example` to `srcs/.env` and adjust the secrets before first use. Because `srcs/.env` is git-ignored, it stays local-only.
- If Portainer reports missing Compose support, rebuild the `portainer` image; the Docker Compose v2 plugin is installed under both standard CLI plugin directories inside the container.
