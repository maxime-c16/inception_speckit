# Lesson 03 — Docker Compose: multi-service orchestration (repository-specific)

Objectives
- Learn the main sections of `docker-compose.yml` (services, volumes, networks)
- Understand how services discover each other using the composed network
- Read the repository `docker-compose.yml` and answer focused questions about service wiring

Open the repository compose file

```bash
sed -n '1,240p' docker-compose.yml
```

Quick anatomy refresher
- services: each service maps to an image or build context and runtime options
- build: where Docker finds the Dockerfile for a service (context + dockerfile)
- image: tag to use when building/pushing
- ports: mapping host:container
- volumes: named volumes (persisted by Docker) or bind mounts (host path)
- networks: compose creates a user-defined network so services can refer to each other by name

Repository-specific walkthrough (what to look for)

- Which service is the reverse proxy? (Look for `nginx` service and its `ports` mapping)
- Where is WordPress running? (Look for `wordpress` service using a `wordpress:php...` image or build)
- Which service provides persistent storage for the site? (Look for named volumes like `inception_wp_data`)
- How is Redis configured? (Look for `command:` or `environment:` that sets a password)
- Are there any `depends_on` entries? Remember `depends_on` controls startup order but not readiness — prefer healthchecks.

Hands-on exercises

- Exercise 1 — Identify wiring

  Run these commands and record answers to the above questions.

  ```bash
  grep -n "^\s*nginx:\|^\s*wordpress:\|^\s*redis:\|^\s*volumes:\|depends_on" -n docker-compose.yml
  sed -n '1,240p' docker-compose.yml | sed -n '1,240p'
  ```

- Exercise 2 — Service discovery

  Start the stack and verify `nginx` can resolve `wordpress`:

  ```bash
  # Lesson 03 — Docker Compose: multi-service orchestration (repository-specific)

  Objectives
  - Learn the main sections of `docker-compose.yml` (services, volumes, networks)
  - Understand how services discover each other using the composed network
  - Read the repository `docker-compose.yml` and answer focused questions about service wiring

  Open the repository compose file

  ```bash
  sed -n '1,240p' docker-compose.yml
  ```

  Quick anatomy refresher
  - services: each service maps to an image or build context and runtime options
  - build: where Docker finds the Dockerfile for a service (context + dockerfile)
  - image: tag to use when building/pushing
  - ports: mapping host:container
  - volumes: named volumes (persisted by Docker) or bind mounts (host path)
  - networks: compose creates a user-defined network so services can refer to each other by name

  Repository-specific walkthrough (what to look for)

  - Which service is the reverse proxy? (Look for `nginx` service and its `ports` mapping)
  - Where is WordPress running? (Look for `wordpress` service using a `wordpress:php...` image or build)
  - Which service provides persistent storage for the site? (Look for named volumes like `inception_wp_data`)
  - How is Redis configured? (Look for `command:` or `environment:` that sets a password)
  - Are there any `depends_on` entries? Remember `depends_on` controls startup order but not readiness — prefer healthchecks.

  Hands-on exercises

  - Exercise 1 — Identify wiring

    Run these commands and record answers to the above questions.

    ```bash
    grep -n "^\s*nginx:\|^\s*wordpress:\|^\s*redis:\|^\s*volumes:\|depends_on" -n docker-compose.yml
    sed -n '1,240p' docker-compose.yml | sed -n '1,240p'
    ```

  - Exercise 2 — Service discovery

    Start the stack and verify `nginx` can resolve `wordpress`:

    ```bash
    docker compose up -d nginx wordpress
    docker compose exec nginx ping -c 3 wordpress
    ```

    If ping is not available in the `nginx` image, use `getent hosts wordpress` or run a small debug image on the same network:

    ```bash
    docker run --rm --network $(docker network ls --filter name=inception_inception -q) --entrypoint ping alpine:latest -c 3 wordpress
    ```

  - Exercise 3 — Add a healthcheck

    Edit a copy of the compose file to add a healthcheck for `mariadb` or `wordpress`. Example snippet for MariaDB:

    ```yaml
    services:
      mariadb:
        healthcheck:
          test: ["CMD", "mysqladmin", "ping", "-p${MYSQL_ROOT_PASSWORD}"]
          interval: 10s
          timeout: 5s
          retries: 5
    ```

    Run `docker compose up -d` with the new file and inspect the health status:

    ```bash
    docker compose ps --services --filter "status=running"
    docker inspect --format='{{json .State.Health}}' $(docker compose ps -q mariadb) | jq
    ```

  - Exercise 4 — Narrow restart & test

    Bring down all services then only start `static` and verify it's reachable on `localhost:8080` (or whichever host port is configured):

    ```bash
    docker compose down
    docker compose up -d static
    curl -I http://localhost:8080
    ```

  What you should learn

  - Compose networks create DNS-based service discovery. You rarely need to rely on hostnames or IP addresses; use the service name.
  - `depends_on` only controls container start ordering; use healthchecks for real readiness.
  - Named volumes persist data across `compose down` and `up` cycles.

  ---

  Solutions: see `DOCS/Course/solutions/03-solution.md` for worked answers and example commands.
