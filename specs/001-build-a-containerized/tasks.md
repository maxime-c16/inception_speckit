# Tasks: Build a containerized infrastructure using Docker and Docker Compose

**Input**: Design documents from `/specs/001-build-a-containerized/`  
**Prerequisites**: plan.md (required), spec.md  
**Feature**: 42 Inception - Docker infrastructure with NGINX, WordPress, MariaDB, and bonus services

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Extract: Docker, Docker Compose, Alpine/Debian base images
2. Load spec.md for functional requirements:
   → Each service → Dockerfile task
   → Each integration → test task  
   → Security requirements → validation tasks
3. Generate tasks by category:
   → Setup: directory structure, Makefile, environment files
   → Container Build: Dockerfiles for each service (no pre-built images allowed except Alpine/Debian)
   → Configuration: docker-compose.yml, TLS certificates, secrets management
   → Tests: healthchecks, integration tests, security scans
   → Integration: service connections, volumes, networks
   → Validation: reproducibility, compliance, performance
4. Apply task rules:
   → Different services = mark [P] for parallel
   → Same files = sequential (no [P])
   → Setup before build, build before integration
5. Number tasks sequentially (T001, T002...)
6. Validate completeness:
   → All services containerized?
   → No forbidden Docker images used?
   → All secrets excluded from repo?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions
- Follow 42 Inception directory structure: `srcs/requirements/<service>/`

## Critical Requirements from 42 Inception
⚠️ **FORBIDDEN**: Pulling ready-made Docker images (except Alpine/Debian base images)
⚠️ **MANDATORY**: Build all Docker images yourself
⚠️ **MANDATORY**: TLS v1.2 or v1.3 only for NGINX
⚠️ **MANDATORY**: Each service in its own container
⚠️ **MANDATORY**: Containers must restart on crash
⚠️ **MANDATORY**: No passwords in Dockerfiles
⚠️ **MANDATORY**: Use Docker networks (not host network or --link)
⚠️ **MANDATORY**: Domain name must be `login.42.fr` pointing to local IP

## Expected Directory Structure
```
.
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        └── bonus/
            ├── redis/
            ├── ftp/
            ├── adminer/
            ├── static-site/
            └── [your-service]/
```

## Phase 3.1: Project Structure & Setup
- [X] T001 Create root directory structure: `Makefile`, `secrets/`, `srcs/`
- [X] T002 Create `srcs/docker-compose.yml` and `srcs/.env` template files
- [X] T003 Create `srcs/requirements/` directory for mandatory services
- [X] T004 Create `srcs/requirements/bonus/` directory for bonus services
- [X] T005 [P] Create service directories: `mariadb/`, `nginx/`, `wordpress/` in `srcs/requirements/`
- [X] T006 [P] Create bonus directories: `redis/`, `ftp/`, `adminer/`, `static-site/`, `[extra]/` in `srcs/requirements/bonus/`
- [X] T007 [P] Create subdirectories for each service: `conf/`, `tools/` where needed
- [X] T008 Create `.env.example` with all required environment variables (no actual secrets)
- [X] T009 Add `secrets/` and `.env` to `.gitignore` to prevent credential leaks
- [X] T010 Create Makefile with targets: `all`, `build`, `up`, `down`, `clean`, `fclean`, `re`

## Phase 3.2: Secret Management & Security Setup
- [X] T011 Create secret files structure in `secrets/` directory
- [X] T012 Configure environment variable substitution in docker-compose.yml from .env file
- [X] T013 [P] Create `.dockerignore` in each service directory to exclude unnecessary files
- [X] T014 Document secret management strategy in `docs/security.md`

## Phase 3.3: NGINX Container (Mandatory Service #1)
- [X] T015 Create `srcs/requirements/nginx/Dockerfile` using Alpine or Debian
- [X] T016 Install NGINX and configure TLS v1.2/v1.3 only in Dockerfile
- [X] T017 Create `srcs/requirements/nginx/conf/nginx.conf` with TLS configuration
- [X] T018 Generate self-signed TLS certificate for `login.42.fr` in `srcs/requirements/nginx/conf/`
- [X] T019 Configure NGINX to proxy port 443 to WordPress php-fpm
- [X] T020 Set NGINX container to restart on crash in docker-compose.yml
- [X] T021 Add NGINX service to `srcs/docker-compose.yml` with volume mounts

## Phase 3.4: MariaDB Container (Mandatory Service #2)
- [X] T022 Create `srcs/requirements/mariadb/Dockerfile` using Alpine or Debian
- [X] T023 Install MariaDB in Dockerfile (no pulling mariadb image)
- [X] T024 Create `srcs/requirements/mariadb/tools/init-db.sh` initialization script
- [X] T025 Configure MariaDB to read credentials from environment variables (not hardcoded)
- [X] T026 Create volume mount for MariaDB data persistence in docker-compose.yml
- [X] T027 Set MariaDB container to restart on crash in docker-compose.yml
- [X] T028 Add MariaDB service to `srcs/docker-compose.yml` with proper network

## Phase 3.5: WordPress Container (Mandatory Service #3)
- [X] T029 Create `srcs/requirements/wordpress/Dockerfile` using Alpine or Debian
- [X] T030 Install php-fpm and WordPress dependencies in Dockerfile (no pulling wordpress image)
- [X] T031 Create `srcs/requirements/wordpress/tools/setup-wordpress.sh` for WordPress installation
- [X] T032 Configure WordPress to connect to MariaDB using environment variables
- [X] T033 Create volume mount for WordPress files persistence in docker-compose.yml
- [X] T034 Configure php-fpm to listen on port 9000 for NGINX FastCGI
- [X] T035 Set WordPress container to restart on crash in docker-compose.yml
- [X] T036 Add WordPress service to `srcs/docker-compose.yml` with depends_on MariaDB

## Phase 3.6: Docker Network Configuration
- [X] T037 Create custom Docker network in `srcs/docker-compose.yml` (no host/bridge/--link)
- [X] T038 Connect NGINX, WordPress, and MariaDB to the custom network
- [X] T039 Configure service discovery using Docker DNS (service names as hostnames)
- [X] T040 Verify no containers use `network_mode: host` (forbidden by Inception)

## Phase 3.7: Bonus - Redis Cache
- [X] T041 [P] Create `srcs/requirements/bonus/redis/Dockerfile` using Alpine or Debian
- [X] T042 [P] Install and configure Redis server in Dockerfile
- [X] T043 [P] Configure WordPress to use Redis for object caching
- [X] T044 [P] Add Redis service to `srcs/docker-compose.yml` with restart policy

## Phase 3.8: Bonus - FTP Server
- [X] T045 [P] Create `srcs/requirements/bonus/ftp/Dockerfile` using Alpine or Debian
- [X] T046 [P] Install and configure FTP server (vsftpd or proftpd) in Dockerfile
- [X] T047 [P] Mount WordPress volume to FTP container for file access
- [X] T048 [P] Configure FTP credentials from environment variables
- [X] T049 [P] Add FTP service to `srcs/docker-compose.yml` with proper ports

## Phase 3.9: Bonus - Static Website
- [X] T050 [P] Create `srcs/requirements/bonus/static-site/Dockerfile` using Alpine or Debian
- [X] T051 [P] Install simple web server (not PHP) like lighttpd or Python http.server
- [X] T052 [P] Create static HTML/CSS website content in `srcs/requirements/bonus/static-site/site/`
- [X] T053 [P] Add static site service to `srcs/docker-compose.yml`
- [X] T054 [P] Configure NGINX to proxy static site on a different route or port

## Phase 3.10: Bonus - Adminer
- [X] T055 [P] Create `srcs/requirements/bonus/adminer/Dockerfile` using Alpine or Debian
- [X] T056 [P] Install PHP and Adminer for database management
- [X] T057 [P] Configure Adminer to connect to MariaDB
- [X] T058 [P] Add Adminer service to `srcs/docker-compose.yml`

## Phase 3.11: Bonus - Extra Service (Your Choice)
- [X] T059 [P] Choose and justify extra service in documentation
- [X] T060 [P] Create `srcs/requirements/bonus/[service-name]/Dockerfile` using Alpine or Debian
- [X] T061 [P] Implement extra service with proper configuration
- [X] T062 [P] Add extra service to `srcs/docker-compose.yml`
- [X] T063 [P] Document the utility and justification of extra service

## Phase 3.12: Documentation & Final Polish
- [X] T064 [P] Create comprehensive README.md with setup instructions
- [X] T065 [P] Document Makefile commands and usage
- [X] T066 [P] Create architecture diagram showing container relationships
- [X] T067 [P] Document security considerations and best practices
- [X] T068 [P] Create troubleshooting guide for common issues
- [X] T069 [P] Add comments to docker-compose.yml explaining each service
- [X] T070 [P] Verify all documentation is complete and accurate
- [X] T071 [P] Create compliance checklist in `docs/compliance.md` for 42 Inception
- [X] T072 Document volume mount points and persistence strategy in `docs/architecture.md`

## Phase 3.13: Final Build & Deployment
- [X] T073 Build all Docker images: `make build`
- [X] T074 Start all services: `make up`
- [X] T075 Verify all containers are running: `docker-compose ps`
- [X] T076 Verify domain `macauchy.42.fr` resolves correctly in `/etc/hosts`
- [X] T077 Verify NGINX TLS is accessible at https://macauchy.42.fr
- [X] T078 Verify WordPress is accessible through NGINX
- [X] T079 Verify all bonus services are running
- [X] T080 Final review: ensure no secrets committed, all containers restart properly

## Dependencies & Execution Order

### Sequential Dependencies (Must Complete in Order)
1. **Setup Phase** (T001-T014): Must complete before any container work
2. **Mandatory Services** (T015-T040): NGINX → MariaDB → WordPress → Network
3. **Bonus Services** (T041-T063): Can start after mandatory services complete
4. **Documentation** (T064-T072): After all services are implemented
5. **Final Build** (T073-T080): Final phase after everything else

### Parallel Execution Groups

**Group 1 - Initial Setup (after T004):**
```bash
# Can run in parallel:
T005 T006 T007  # Create all service directories simultaneously
```

**Group 2 - Security Setup (after T010):**
```bash
# Can run in parallel:
T013 T014  # Dockerignore and documentation
```

**Group 3 - Bonus Services (after T040):**
```bash
# Can run in parallel - all independent services:
T041-T044  # Redis
T045-T049  # FTP
T050-T054  # Static site
T055-T058  # Adminer
T059-T063  # Extra service
```

**Group 4 - Documentation (after T063):**
```bash
# Can run in parallel:
T064 T065 T066 T067 T068 T069 T070 T071 T072
```

## Validation Checklist
*GATE: Must verify before marking feature complete*

### Mandatory Requirements
- [ ] All Docker images built from Alpine or Debian (no pre-built images except base)
- [ ] NGINX configured with TLS v1.2/v1.3 only
- [ ] WordPress with php-fpm running in separate container
- [ ] MariaDB in separate container with persistent volume
- [ ] Each service in its own dedicated container
- [ ] All containers restart automatically on crash
- [ ] Custom Docker network used (no host mode, no --link)
- [ ] Domain `login.42.fr` configured and accessible
- [ ] No passwords in Dockerfiles or docker-compose.yml
- [ ] All secrets in environment variables or secret files
- [ ] No secrets committed to repository
- [ ] `make` command builds all images
- [ ] `make up` starts all services
- [ ] `make down` stops all services gracefully

### Bonus Requirements (5 services minimum)
- [ ] Redis cache integrated with WordPress
- [ ] FTP server provides access to WordPress files
- [ ] Static website (non-PHP) running in container
- [ ] Adminer provides web interface for MariaDB
- [ ] Extra service implemented and justified

### Documentation
- [ ] README explains setup and usage
- [ ] Architecture documented with diagrams
- [ ] Security practices documented
- [ ] Compliance checklist complete
- [ ] Extra service justified in documentation

## Notes
- **[P] tasks** = Can run in parallel (different files, independent work)
- **No [P] tasks** = Sequential (must wait for previous task)
- All paths are relative to repository root
- Follow 42 Inception subject requirements strictly
- When in doubt, consult `inception.pdf` in repository root

## Task Execution Examples

### Example 1: Setup Phase
```bash
# Run initial structure tasks sequentially:
# T001 → Create root directories
# T002 → Create docker-compose and .env templates  
# T003 → Create requirements directory
# T004 → Create bonus directory

# Then run parallel tasks:
# T005, T006, T007 in parallel (different directories)
```

### Example 2: Bonus Services (All Parallel)
```bash
# After mandatory services complete (T040), run all bonus in parallel:
# - T041-T044 (Redis)
# - T045-T049 (FTP)  
# - T050-T054 (Static)
# - T055-T058 (Adminer)
# - T059-T063 (Extra)
```

### Example 3: Final Deployment
```bash
# After all services and documentation complete:
# T073 → Build all images
# T074 → Start all services
# T075-T080 → Verify deployment
```

---

**Ready for execution following 42 Inception requirements - Build focused, no test scaffolding.**
