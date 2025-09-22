# QA Report — Build & Smoke Checks

Date: 2025-09-22
Repository root: `/Users/baki/max_perso/inception`

Summary
- Goal: Run a full build and smoke-test the Compose stack (nginx, wordpress/php-fpm, mariadb, redis, static, adminer) and report PASS/FAIL per gate.
- Performed steps: `make build`, `make up -d`, then service checks (HTTP/TLS, DB, Redis, php-fpm, Adminer).

Results (PASS / FAIL)
- Build images: PASS
  - Command: `make build` (calls `docker-compose build`)
  - Notes: All images built successfully (see build logs).

- Start stack (detached): PASS
  - Command: `make up -d` (calls `docker-compose up -d`)
  - Notes: All containers started; network and named volumes created.

- Static site (HTTP): PASS
  - Command: `curl -I http://localhost:8080`
  - Result: HTTP/1.1 200 OK

- NGINX TLS endpoint: PASS (self-signed)
  - Command: `curl -vk https://127.0.0.1 --resolve 'macauchy.42.fr:443:127.0.0.1'`
  - Result: TLS handshake succeeded; server responded with HTTP 302 redirect to `/wp-admin/install.php`.
  - Note: certificate is self-signed (verify error expected for local dev).

- MariaDB availability & DB presence: PASS
  - Command: `docker compose exec mariadb mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"`
  - Result: `wordpress` database is present.

- WordPress php-fpm running: PASS
  - Command: `docker compose logs wordpress` and `docker compose exec wordpress php -v`
  - Result: php-fpm reports "fpm is running, pid 1" and PHP 8.2.29 is available.

- Redis auth: PASS
  - Command: `docker compose exec redis redis-cli -a "$REDIS_PASSWORD" ping`
  - Result: `PONG`

- Adminer UI reachable: PASS
  - Command: `curl -I http://localhost:8081`
  - Result: HTTP/1.1 200 OK

- WordPress options (siteurl/blogname): FAIL
  - Command: `docker compose exec mariadb mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT option_name, option_value FROM wordpress.wp_options WHERE option_name IN ('siteurl','blogname');"`
  - Result: ERROR 1146 (42S02): Table 'wordpress.wp_options' doesn't exist
  - Interpretation: The `wordpress` database exists but tables have not been created — WordPress installation (core install) hasn't been completed in this run.

Key command excerpts (captured during run)

- `docker compose ps --all` (trimmed):

  NAME                    SERVICE     STATUS
  inception-nginx-1       nginx       Up
  inception-wordpress-1   wordpress   Up
  inception-mariadb-1     mariadb     Up
  inception-redis-1       redis       Up
  inception-static-1      static      Up
  inception-adminer-1     adminer     Up

- `curl -I http://localhost:8080`:

  HTTP/1.1 200 OK
  Content-Type: text/html

- `curl -vk https://127.0.0.1 --resolve 'macauchy.42.fr:443:127.0.0.1'` (trimmed):

  * Server certificate:
    subject: C=FR; ST=France; L=Paris; O=Inception; OU=Dev; CN=macauchy.42.fr
    SSL certificate verify result: self signed certificate (18), continuing anyway.
  < HTTP/1.1 302 Found
  < Location: https://127.0.0.1/wp-admin/install.php

- `docker compose exec mariadb mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"`:

  +--------------------+
  | Database           |
  +--------------------+
  | information_schema |
  | mysql              |
  | performance_schema |
  | sys                |
  | wordpress          |
  +--------------------+

- `docker compose exec redis redis-cli -a "$REDIS_PASSWORD" ping`:

  PONG

- `docker compose logs --tail=200 wordpress` (trimmed):

  WordPress not found in /var/www/html - copying now...
  Complete! WordPress has been successfully copied to /var/www/html
  No 'wp-config.php' found in /var/www/html, but 'WORDPRESS_...' variables supplied; copying 'wp-config-docker.php' ...
  [..] fpm is running, pid 1

- WP options query error:

  ERROR 1146 (42S02): Table 'wordpress.wp_options' doesn't exist

Analysis and recommended next steps

1. WordPress files are present and php-fpm is running, but the database tables are missing — the WordPress setup (core install / wp-admin install) needs to be completed. For automated QA we should run a headless WP-CLI `wp core install` (or the equivalent SQL import) to create the tables before running content checks.

2. Add a transient WP-CLI step in the CI/integration test to perform `wp core install` (use environment variables for DB credentials). Alternatively, pre-populate the DB with a SQL dump containing the necessary tables for tests.

3. Re-run the WP-specific checks after installation: verify `wp_options.siteurl` and `wp_options.blogname`, and a simple HTTP response from `/wp-admin/` returns 200.

4. Optionally add healthchecks to the `docker-compose.yml` (mariadb/wordpress) and add wait/retry logic to the test harness so services are truly ready.

Files added/modified by QA run
- None (tests were run against running stack; no repository files mutated).

Conclusion

The build and most smoke checks pass (images build, network and containers start, nginx TLS and static content serve correctly, MariaDB + Redis + Adminer reachable). The only failing check is WordPress database tables (installation not completed). After performing a headless WP install or populating the DB, the remaining checks should pass.
