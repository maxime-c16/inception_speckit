# Tasks: Build a containerized infrastructure using Docker and Docker Compose

**Input**: Design documents from `/specs/001-build-a-containerized/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting, containerization, secret scanning
   → Tests: contract tests, integration tests, infrastructure tests
   → Core: models, services, CLI commands
   → Integration: DB connections, middleware, logging
   → Polish: unit tests, performance, docs, reproducibility
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness
9. Return: SUCCESS (tasks ready for execution)
```

## Phase 3.1: Setup
- [X] T001 Create directory structure: `srcs/`, `secrets/`, `Makefile`, `.env.example`
- [X] T002 [P] Create Dockerfiles for each service in `srcs/` (nginx, wordpress, mariadb, redis, ftp, static, adminer, extra)
- [X] T003 [P] Create `docker-compose.yml` at repo root with all services and networks
- [X] T004 [P] Create `.dockerignore` and add best-practice exclusions
- [X] T005 [P] Create Makefile for build, up, down, clean, and test commands
- [X] T006 [P] Configure secret scanning in CI and pre-commit hooks

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [X] T007 [P] Write Compose healthcheck tests for all containers in `tests/integration/test_healthchecks.sh`
- [X] T008 [P] Write security scan test for images in `tests/integration/test_security.sh`
- [X] T009 [P] Write integration test for NGINX TLS and proxy in `tests/integration/test_nginx_tls.sh`
- [X] T010 [P] Write integration test for WordPress + MariaDB in `tests/integration/test_wordpress_db.sh`
- [X] T011 [P] Write integration test for Redis cache in `tests/integration/test_redis.sh`
- [X] T012 [P] Write integration test for FTP access in `tests/integration/test_ftp.sh`
- [X] T013 [P] Write integration test for static site in `tests/integration/test_static.sh`
- [X] T014 [P] Write integration test for Adminer in `tests/integration/test_adminer.sh`
- [X] T015 [P] Write integration test for extra service in `tests/integration/test_extra.sh`

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [X] T016 [P] Implement NGINX container in `srcs/nginx/`
- [X] T017 [P] Implement WordPress + php-fpm container in `srcs/wordpress/`
- [X] T018 [P] Implement MariaDB container in `srcs/mariadb/`
- [X] T019 [P] Implement Redis container in `srcs/redis/` (bonus)
- [X] T020 [P] Implement FTP server container in `srcs/ftp/` (bonus)
- [X] T021 [P] Implement static site container in `srcs/static/` (bonus)
- [X] T022 [P] Implement Adminer container in `srcs/adminer/` (bonus)
- [X] T023 [P] Implement extra service container in `srcs/extra/` (bonus)
- [X] T024 Configure Docker Compose volumes and networks for all services
- [X] T025 Configure Docker secrets and .env file usage for credentials

## Phase 3.4: Integration
- [X] T026 [P] Integrate NGINX with WordPress and static site (proxy rules)
- [X] T027 [P] Integrate WordPress with MariaDB and Redis
- [X] T028 [P] Integrate FTP server with WordPress volume
- [X] T029 [P] Integrate Adminer with MariaDB
- [X] T030 [P] Integrate extra service as justified in documentation

## Phase 3.5: Polish & Validation
- [X] T031 [P] Add unit tests for custom scripts in `srcs/` and `Makefile`
- [X] T032 [P] Add performance test for WordPress with/without Redis in `tests/performance/test_wordpress_perf.sh`
- [X] T033 [P] Add documentation for setup, usage, and security in `README.md`
- [X] T034 [P] Add reproducibility test: teardown and redeploy all services, verify data persistence
- [X] T035 [P] Add compliance checklist for 42 Inception requirements in `docs/compliance.md`

## Parallel Execution Examples
- T002, T003, T004, T005, T006 can be run in parallel after T001
- T007–T015 can be run in parallel after setup
- T016–T023 can be run in parallel after tests
- T026–T030 can be run in parallel after core implementation
- T031–T035 can be run in parallel after integration

**Example agent commands:**
```sh
# Run all setup tasks in parallel
copilot tasks run T002 T003 T004 T005 T006
# Run all integration tests in parallel
copilot tasks run T007 T008 T009 T010 T011 T012 T013 T014 T015
# Run all core implementation tasks in parallel
copilot tasks run T016 T017 T018 T019 T020 T021 T022 T023
```
