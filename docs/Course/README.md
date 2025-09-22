# Docker & Containerization Course — Inception Case Study

Course overview
----------------
This beginner-friendly course teaches Docker and containerization concepts from basics to advanced topics using the Inception project as a running case study. Each lesson combines theory, hands-on steps, and references to files in this repository so learners can follow along and compare their work to a real project.

Audience & prerequisites
------------------------
- Beginner to intermediate developers curious about containers and Docker.
- Basic command-line familiarity (bash/zsh) and Git.
- Installed tools: Docker Engine & Docker Compose, `make` (optional), and a code editor.

Learning outcomes
-----------------
By the end of the course, learners will be able to:
- Understand container concepts and Docker primitives (images, containers, registries).
- Write and optimize Dockerfiles following best practices.
- Orchestrate multi-service applications with Docker Compose.
- Manage persistent storage with volumes and bind mounts.
- Secure containerized apps (secrets, TLS, minimal privileges).
- Debug, test, and build CI-friendly container workflows.

Course structure
----------------
Lessons (each lesson is a markdown file with examples and exercises):

- `01-intro.md` — Why containers, images vs VMs, when to use Docker
- `02-dockerfile.md` — Anatomy of a Dockerfile; best practices; multi-stage builds
- `03-images-and-registries.md` — Image lifecycle, tags, reproducible builds, registries
- `04-docker-compose.md` — Compose file structure, services, networks, volumes
- `05-networking.md` — Container networks, service discovery, DNS, publish vs expose
- `06-volumes-storage.md` — Volumes, bind mounts, persistence, backup strategies
- `07-security.md` — Secrets, least privilege, TLS, cert management, image scanning
- `08-debugging.md` — Logs, shelling into containers, healthchecks, common issues
- `09-ci-cd.md` — Building images in CI, caching, test harnesses
- `10-case-study.md` — Deep dive through the Inception project: Dockerfiles, compose, and tests
- `exercises.md` — Practical exercises
- `solutions.md` — Solutions and hints

How to use this course in the repo
----------------------------------
Open the `DOCS/Course` directory and read each lesson. Each lesson contains hands-on commands that use the real files in this repository (for example, `srcs/nginx/Dockerfile`, `docker-compose.yml`).

Start here:

```bash
less DOCS/Course/01-intro.md
```

Next I will create the first three lesson files (intro, dockerfile, compose) and include hands-on references to `srcs/` and `docker-compose.yml`.
