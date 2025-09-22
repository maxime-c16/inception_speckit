# Solutions for Lesson 03 — Docker Compose

Exercise 1 — Identify wiring (answers depend on your `docker-compose.yml` but here are sample commands):

```bash
grep -n "^\s*nginx:\|^\s*wordpress:\|^\s*redis:\|^\s*volumes:\|depends_on" docker-compose.yml
sed -n '1,240p' docker-compose.yml
```

Typical answers from this repository (example):
- Reverse proxy: `nginx` service, exposes host port 443
- WordPress: `wordpress` service using `wordpress:php8.2-fpm-alpine` image, php-fpm on port 9000
- Persistence: named volumes `inception_wp_data`, `inception_db_data` mounted to `/var/www/html` and `/var/lib/mysql`
- Redis: launched with `--requirepass example_redis_pw` in `command:` or via `REDIS_PASSWORD` env
- `depends_on`: `nginx` depends_on `wordpress` and `static` to start earlier, but healthchecks are required for readiness

Exercise 2 — Service discovery (sample commands and expected output):

```bash
docker compose up -d nginx wordpress
docker compose exec nginx ping -c 1 wordpress || echo "ping not available; try getent"
docker compose exec nginx getent hosts wordpress
```

Expected: `getent hosts wordpress` prints an IP address and the name `wordpress` (indicating DNS resolution works).

Exercise 3 — Healthcheck (sample commands):

After adding the healthcheck and running `docker compose up -d`, check:

```bash
docker inspect --format='{{json .State.Health}}' $(docker compose ps -q mariadb) | jq
```

You should see `"Status": "healthy"` once the DB responds to mysqladmin ping.

Exercise 4 — Static test (sample commands):

```bash
docker compose down
docker compose up -d static
curl -I http://localhost:8080
```

Expected: HTTP 200 headers including `Content-Type: text/html`.
