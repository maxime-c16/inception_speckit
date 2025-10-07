# 42 Inception - Setup Guide

## Prerequisites

- Docker and Docker Compose installed
- GNU Make installed
- At least 4GB of free disk space
- Sudo access (for /etc/hosts modification)

## Quick Start

### 1. Add Domain to /etc/hosts

```bash
echo "127.0.0.1 macauchy.42.fr" | sudo tee -a /etc/hosts
```

### 2. Configure Environment Variables

Copy the example environment file:

```bash
cp .env.example srcs/.env
```

Edit `srcs/.env` and set secure passwords:

```bash
# Generate strong random passwords
openssl rand -base64 32

# Then update srcs/.env with your secure values
```

**Important:** The `.env` file contains sensitive information and is git-ignored.

### 3. Build the Infrastructure

```bash
make
# or
make build
```

This will:
- Build all Docker images from source
- **Automatically generate TLS certificates** for the configured domain
- Set up all required services

### 4. Start Services

```bash
make up
```

All services will start automatically. The system includes:

**Mandatory Services:**
- NGINX (TLS termination, port 443 only)
- WordPress (with php-fpm)
- MariaDB (database)

**Bonus Services:**
- Redis (caching)
- FTP server (file access)
- Static website
- Adminer (database UI)
- Portainer (container management)

### 5. Access the Services

- **WordPress**: https://macauchy.42.fr
- **Adminer**: http://localhost:8081
- **Static Site**: http://localhost:8080  
- **Portainer**: http://localhost:9000

**Note:** Your browser will warn about the self-signed certificate. This is expected - accept the security exception to proceed.

## WordPress Credentials

Default users (change these in production):

**Administrator:**
- Username: `wpuser`
- Password: Set in WordPress setup script
- Email: wpuser@macauchy.42.fr

**Editor:**
- Username: `editor`
- Password: Set in WordPress setup script
- Email: editor@macauchy.42.fr

## Managing the Infrastructure

### Stop Services
```bash
make down
```

### Clean Everything (removes containers and volumes)
```bash
make clean
```

### Full Clean (removes images too)
```bash
make fclean
```

### Rebuild Everything
```bash
make re
```

### View Logs
```bash
make logs
```

### Check Status
```bash
make ps
```

## Automatic Certificate Generation

The TLS certificates are **automatically generated** when the NGINX container starts:

1. The NGINX Dockerfile includes an entrypoint script
2. On first run, the script checks if certificates exist
3. If not, it generates a self-signed certificate for the configured domain
4. The certificate is stored in the container's `/etc/nginx/ssl/` directory
5. The domain name is read from the `DOMAIN_NAME` environment variable

**This means:** When you rebuild the project in a new VM, everything sets itself up automatically!

## Data Persistence

Volumes are mounted to the host at:
- MariaDB data: `/home/macauchy/data/mariadb`
- WordPress files: `/home/macauchy/data/wordpress`

These directories are automatically created on first run.

## Troubleshooting

### Issue: Cannot access https://macauchy.42.fr

**Solution:** Ensure the domain is in `/etc/hosts`:
```bash
cat /etc/hosts | grep macauchy.42.fr
# If not found, add it:
echo "127.0.0.1 macauchy.42.fr" | sudo tee -a /etc/hosts
```

### Issue: Permission denied errors

**Solution:** Ensure data directories exist and have correct permissions:
```bash
mkdir -p /home/macauchy/data/{mariadb,wordpress}
sudo chown -R $USER:$USER /home/macauchy/data
```

### Issue: Port already in use

**Solution:** Check if another service is using the required ports:
```bash
sudo lsof -i :443  # NGINX
sudo lsof -i :3306 # MariaDB (internal only)
sudo lsof -i :8080 # Static site
sudo lsof -i :8081 # Adminer
sudo lsof -i :9000 # Portainer
```

### Issue: Containers keep restarting

**Solution:** Check container logs:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
# or use:
make logs
```

## Security Notes

1. **Change all default passwords** in `srcs/.env`
2. **Never commit** `.env` or `secrets/` to git
3. The `.gitignore` is configured to prevent this
4. For production, use Docker secrets instead of environment variables
5. The TLS certificate is self-signed - for production, use Let's Encrypt

## Compliance

This implementation follows all 42 Inception requirements:

✅ Custom Docker images (no DockerHub pulls except Alpine/Debian)  
✅ TLS v1.2/v1.3 only  
✅ NGINX sole entry point (port 443)  
✅ Each service in dedicated container  
✅ Custom Docker network  
✅ Automatic restart on crash  
✅ No passwords in Dockerfiles  
✅ Environment variables for configuration  
✅ Volumes in /home/login/data  
✅ No forbidden patterns (tail -f, sleep infinity, etc.)  
✅ Two WordPress users (admin without 'admin' in name)  
✅ All 5 bonus services implemented  

See `docs/COMPLIANCE_REPORT.md` for detailed verification.
