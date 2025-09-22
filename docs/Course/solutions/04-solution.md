# Solutions for Lesson 04 — Logs and debugging

Exercise 1 — Find the cause of a 502 (example workflow)

1. Inspect nginx logs:

```bash
docker compose logs --tail=200 nginx
```

Look for lines like `connect() to 172.18.x.y:9000 failed` or `upstream timed out`.

2. Test nginx config:

```bash
docker compose exec nginx nginx -t
```

If config is OK, test connectivity to php-fpm:

```bash
docker compose exec nginx sh -c "nc -zv wordpress 9000"
```

If the connection fails, start a temporary debug shell on the same network and try connecting from there:

```bash
docker run --rm --network $(docker network ls --filter name=inception_inception -q) -it alpine sh
apk add --no-cache netcat-openbsd
nc -zv wordpress 9000
```

Common fixes:
- Start php-fpm / wordpress container, check `docker compose logs wordpress` for php-fpm errors
- Fix upstream name or port in `srcs/nginx/conf/default.conf` (use `fastcgi_pass wordpress:9000;`)

Exercise 2 — PEM parsing error

1. Examine cert/key files inside container and on host:

```bash
docker compose exec nginx ls -l /etc/nginx/conf.d/cert.pem /etc/nginx/conf.d/key.pem
docker compose exec nginx head -n 5 /etc/nginx/conf.d/cert.pem
```

2. If wrong permissions or invalid contents, regenerate cert/key locally (see `DOCS/BUILD_AND_DEPLOY.md`) and set:

```bash
chmod 644 srcs/nginx/conf/cert.pem
chmod 600 srcs/nginx/conf/key.pem
docker compose build nginx && docker compose up -d nginx
```

Expected: NGINX starts without PEM errors and serves TLS.
