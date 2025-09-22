# Inception Project — Finalized

This repository contains a multi-container Docker Compose stack that provides a working WordPress site behind NGINX (TLS), MariaDB, Redis, a static site, Adminer, and a small extra container used for auxiliary tasks.

What I implemented and verified
- Full rebuild and `docker-compose` orchestration for all services
- TLS (self-signed) loaded into NGINX and used for `https://macauchy.42.fr`
- WordPress automated install (WP-CLI) completed and `wp_options` shows `siteurl` and `blogname`
- Redis authentication validated (password from `.env.example` used: `example_redis_pw`)
- Static service published to host port `8080` (static content served)
- Persistence verified: `inception_wp_data` and `inception_db_data` volumes persist across stop/start

Quick start
1. Copy `.env.example` to `.env` and adjust secrets (or use the defaults for local testing):

```bash
cp .env.example .env
# edit .env to set secure passwords in production
```

2. Build and start the stack:

```bash
make build
make up -d
# or: docker compose up -d --build
```

3. Access services (local testing):
- WordPress (HTTPS): https://macauchy.42.fr  (add `127.0.0.1 macauchy.42.fr` to `/etc/hosts` if needed)
- Static site: http://localhost:8080
- Adminer (DB UI): http://localhost:8081

Default example credentials (for testing only)
- MariaDB root: from `.env` (example_root_pw)
- MariaDB DB/user: `wordpress` / `wp_user` / `example_pw`
- Redis password: `example_redis_pw`
- WordPress admin (created during automated install): admin / admin_pass_123

Persistence verification (what I ran)
- Computed `md5` of `/var/www/html/wp-config.php` before and after a full `down`/`up` restart — checksum unchanged.
- Inspected `/var/lib/mysql/ibdata1` size and timestamp before/after restart — unchanged.
- Confirmed Docker volumes: `inception_wp_data` and `inception_db_data` are mounted to `/var/www/html` and `/var/lib/mysql` respectively.

Notes & recommended next steps
- Replace example passwords with secure values or configure Docker secrets for production usage.
- Consider adding automated integration tests (I can add a small test script that asserts HTTP 200 for static, HTTP 200/302 expectations for the WordPress root, and DB connectivity).
- If you want Adminer or static on HTTPS, we can configure NGINX to provide TLS for those routes as well.

If you want, I can now:
- add integration tests and run them automatically in CI
- rotate the example credentials into Docker secrets
- harden Redis ACLs with named users instead of the default user
# Inception Project

This project provides a containerized WordPress environment with NGINX (TLS), MariaDB, Redis, FTP, static site, Adminer, and an extra service.

## Setup

1. Copy `.env.example` to `.env` and fill in secrets.
2. Run `make build` then `make up`.
3. Access WordPress at https://login.42.fr (self-signed cert).
4. See each service's README for details.

## Security
- No secrets in repo. Use `.env` and Docker secrets.
- Secret scanning is enforced via pre-commit.

## Reproducibility
- All services are containerized and versioned.
- Volumes persist data for MariaDB and WordPress.

## Compliance
- Follows 42 Inception requirements and best practices.
