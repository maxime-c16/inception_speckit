# Inception - Docker Infrastructure Project

A multi-container Docker infrastructure implementing a complete WordPress environment with NGINX, MariaDB, and multiple bonus services. Built as part of the 42 School Inception project.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Security](#security)
- [Project Structure](#project-structure)
- [Compliance](#compliance)

## 🎯 Overview

This project demonstrates system administration skills through Docker containerization. It includes:

- **3 Mandatory Services**: NGINX, WordPress, MariaDB
- **5 Bonus Services**: Redis, FTP, Static Website, Adminer, Portainer
- **TLS Encryption**: NGINX configured with TLS v1.2/v1.3 (automatic certificate generation)
- **Data Persistence**: Docker volumes for database and files
- **Secure Configuration**: Environment-based secrets, no hardcoded passwords
- **Complete Automation**: Everything auto-configures on first run

## 🏗️ Architecture

All services run in isolated Docker containers connected through a custom bridge network:

```
┌─────────────────────────────────────────────────────┐
│                   NGINX (TLS)                       │
│              https://login.42.fr:443                │
└────────────────────┬────────────────────────────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
    ┌─────▼────────┐      ┌────▼─────────┐
    │  WordPress   │      │ Static Site  │
    │   (php-fpm)  │      │  (lighttpd)  │
    └─────┬────────┘      └──────────────┘
          │
    ┌─────▼────────┐
    │   MariaDB    │
    └──────────────┘
          │
    ┌─────▼────────┐
    │    Redis     │
    │   (Cache)    │
    └──────────────┘
```

**Bonus Services:**
- FTP Server (Port 21) - File access to WordPress
- Adminer (Port 8081) - Database management UI
- Portainer (Port 9000) - Container management UI

## 🚀 Services

### Mandatory Services

| Service | Description | Port | Base Image |
|---------|-------------|------|------------|
| NGINX | Reverse proxy with TLS | 443 | Debian |
| WordPress | CMS with php-fpm | 9000 | Debian |
| MariaDB | Database server | 3306 | Debian |

### Bonus Services

| Service | Description | Port | Justification |
|---------|-------------|------|---------------|
| Redis | Object caching | 6379 | Improves WordPress performance |
| FTP | File transfer | 21 | Easy file management |
| Static Site | HTML website | 8080 | Demonstrates non-PHP serving |
| Adminer | DB admin UI | 8081 | Visual database management |
| Portainer | Container UI | 9000 | Infrastructure monitoring |

## 📦 Prerequisites

- Docker Engine (20.10+)
- Docker Compose (1.29+)
- Make
- Git
- Minimum 2GB RAM
- 10GB free disk space

## ⚙️ Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd inception_speckit
   ```

2. **Configure environment variables:**
   ```bash
   cp .env.example srcs/.env
   # Edit srcs/.env with your secure passwords
   nano srcs/.env
   ```

   - Rotate every secret value (database, Redis, FTP, WordPress) with strong, unique strings.
   - Update `WORDPRESS_SITE_URL`, `WORDPRESS_TITLE`, and both WordPress user credential sets. The administrator username **must not** contain `admin`/`Admin`/`administrator`; the startup script exits if it does so you catch the issue early.
   - Optionally keep a working copy at the repository root (`cp srcs/.env .env`) when running raw `docker-compose` commands outside the Makefile.

3. **Add domain to /etc/hosts:**
   ```bash
   echo "127.0.0.1 macauchy.42.fr" | sudo tee -a /etc/hosts
   ```

4. **Build and start services:**
   ```bash
   make        # Build all images
   make up     # Start all services
   ```

   **Note:** TLS certificates are automatically generated on first run - no manual certificate creation needed!

## 🎮 Usage

### Makefile Commands

```bash
make all      # Build all images
make build    # Build all Docker images
make up       # Start all services
make down     # Stop all services
make clean    # Remove containers and volumes
make fclean   # Full clean (images, volumes, networks)
make re       # Rebuild everything (fclean + build)
make logs     # View service logs
make ps       # List running containers
```

**Rehearsal checklist (run before the defense):**

1. `sudo make up` and wait until all containers report `running`.
2. Visit every endpoint: `https://macauchy.42.fr`, `http://localhost:8080`, `http://localhost:8081`, and `http://localhost:9000`.
3. Log into WordPress with the administrator user, create or edit a post, leave a comment, and confirm Redis cache status with `docker exec wordpress wp redis status --allow-root`.
4. Test FTP access (`lftp -u $FTP_USER,$FTP_PASS localhost 21`) and upload a dummy file into `/wordpress`.
5. Check MariaDB connectivity as both root and the application user (`docker exec mariadb mysql -uroot -p...`, etc.).
6. `sudo make down`, then `sudo make up` (or reboot the VM) to confirm persistence of the changes.

Keep a copy of `docker-compose --env-file srcs/.env -f srcs/docker-compose.yml logs` output handy in case evaluators request evidence of service readiness.

### Accessing Services

- **WordPress**: https://macauchy.42.fr
- **Static Site**: http://localhost:8080
- **Adminer**: http://localhost:8081
- **Portainer**: http://localhost:9000

**WordPress Users** (auto-created on first run):
- Admin: `${WORDPRESS_ADMIN_USER}` / `${WORDPRESS_ADMIN_PASSWORD}` (set in `srcs/.env`)
- Editor: `${WORDPRESS_SECONDARY_USER}` / `${WORDPRESS_SECONDARY_USER_PASSWORD}` (set in `srcs/.env`)

> ℹ️ The administrator username must **not** contain `admin`, `Admin`, or `administrator`. The startup scripts enforce this subject rule and will fail fast if the condition is violated.

**Note:** Accept the self-signed TLS certificate in your browser.

## 🔒 Security

### Secret Management

- All secrets stored in environment variables (`srcs/.env`)
- `.env` and `secrets/` excluded from git
- No hardcoded passwords in Dockerfiles
- Template provided in `.env.example`

### TLS Configuration

- **Automatic Certificate Generation**: Self-signed certificates created on container startup
- **TLS v1.2 and v1.3 only** (v1.0/v1.1 disabled)
- **Strong cipher suites** configured
- **Domain**: Configured via `DOMAIN_NAME` in `.env`
- **No manual certificate creation needed** - everything is automated!

The NGINX container includes an entrypoint script that:
1. Checks if certificates exist in `/etc/nginx/ssl/`
2. Generates self-signed certificate if missing (using `openssl`)
3. Uses domain from `DOMAIN_NAME` environment variable
4. Sets proper permissions (644 for cert, 600 for key)
5. Starts NGINX

### Container Security

- Non-root users where possible
- Minimal base images (Debian)
- Read-only volume mounts where appropriate
- Isolated custom network
- Automatic restart policies

## 📁 Project Structure

```
.
├── Makefile                              # Build and deployment commands
├── .env.example                          # Environment variables template
├── srcs/
│   ├── docker-compose.yml                # Service orchestration
│   ├── .env                              # Environment variables (not in git)
│   └── requirements/
│       ├── nginx/                        # NGINX with TLS
│       │   ├── Dockerfile
│       │   └── conf/
│       ├── mariadb/                      # MariaDB database
│       │   ├── Dockerfile
│       │   └── tools/
│       ├── wordpress/                    # WordPress with php-fpm
│       │   ├── Dockerfile
│       │   └── tools/
│       └── bonus/
│           ├── redis/                    # Redis caching
│           ├── ftp/                      # FTP server
│           ├── adminer/                  # DB admin UI
│           ├── static-site/              # Static website
│           └── portainer/                # Container management
├── secrets/                              # Secret files (not in git)
└── docs/                                 # Requirement checklist and notes
```

## ✅ Compliance

### 42 Inception Requirements

- ✅ All Docker images built from source (Debian/Alpine only)
- ✅ Each service in its own container
- ✅ NGINX with TLS v1.2/v1.3
- ✅ WordPress with php-fpm (no pre-built image)
- ✅ MariaDB (no pre-built image)
- ✅ Custom Docker network (no host/--link)
- ✅ Persistent volumes for data
- ✅ Automatic container restart on crash
- ✅ No secrets in repository
- ✅ Domain name `macauchy.42.fr` (user-specific)
- ✅ Makefile with all required targets
- ✅ Automatic TLS certificate generation

### Bonus Features (5/5)

- ✅ Redis cache for WordPress
- ✅ FTP server for file access
- ✅ Static website (non-PHP)
- ✅ Adminer for database management
- ✅ Portainer for container management

## 🐛 Troubleshooting

### Common Issues

**Containers not starting:**
```bash
make logs  # Check container logs
docker ps -a  # Check container status
```

**Permission errors:**
```bash
sudo chown -R $USER:$USER .
```

**Port already in use:**
```bash
# Check what's using the port
sudo lsof -i :443
sudo lsof -i :8080
```

**Database connection errors:**
- Ensure MariaDB container is healthy: `docker ps`
- Check environment variables in `srcs/.env`
- Verify network connectivity: `docker network inspect inception`

**TLS certificate errors:**
- **No need to manually regenerate!** Certificates are auto-generated on container startup
- If you need to force regeneration:
  ```bash
  make down
  docker volume rm nginx_ssl 2>/dev/null || true
  make up  # Will regenerate certificates automatically
  ```
- Verify certificate: `docker exec nginx openssl x509 -in /etc/nginx/ssl/cert.pem -text -noout`

## 📚 Documentation

- [Requirement Checklist](docs/requirements.md) - Quick compliance overview and user policy reminder

## 🤝 Contributing

This is an educational project for 42 School. For improvements or issues, please open an issue or pull request.

## 📝 License

This project is part of the 42 School curriculum. Educational use only.

---

**Built with ❤️ for 42 School Inception Project**
