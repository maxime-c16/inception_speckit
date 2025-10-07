# Security Strategy - 42 Inception Project

## Secret Management

### Overview
This project follows security best practices for managing secrets and sensitive data in a containerized environment.

### Secret Storage

#### Environment Variables
- All sensitive configuration is stored in environment variables
- Variables are defined in `srcs/.env` file (NOT committed to git)
- `.env.example` provides a template with placeholder values
- Production secrets must be changed from default values

#### Secret Files
The `secrets/` directory contains:
- `credentials.txt` - Database credentials
- `db_password.txt` - MariaDB user password  
- `db_root_password.txt` - MariaDB root password

⚠️ **IMPORTANT**: The `secrets/` directory and all `.env` files are excluded from git via `.gitignore`

### Docker Compose Integration

Environment variables are passed to containers through `docker-compose.yml`:
- MariaDB receives: `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`
- WordPress receives: Database credentials, Redis configuration
- Other services receive only necessary credentials

### Security Best Practices

1. **No Hardcoded Secrets**
   - Never put passwords in Dockerfiles
   - Never commit `.env` files with real secrets
   - Use `.env.example` for documentation only

2. **Minimal Permissions**
   - Containers run as non-root users where possible
   - Volumes are mounted read-only when appropriate
   - Services have minimal required network access

3. **TLS/SSL**
   - NGINX uses TLS v1.2/v1.3 only
   - Self-signed certificates for development
   - Certificates stored in `srcs/requirements/nginx/conf/`

4. **Docker Security**
   - Custom bridge network (no host mode)
   - Container restart policies configured
   - Resource limits can be set in docker-compose.yml

5. **Secrets Scanning**
   - Pre-commit hooks configured (see `.pre-commit-config.yaml`)
   - Automated secret scanning in CI/CD
   - Regular security audits recommended

### Changing Secrets

To set up production secrets:

1. Copy the template:
   ```bash
   cp .env.example srcs/.env
   ```

2. Edit `srcs/.env` with secure values:
   ```bash
   # Generate strong passwords
   openssl rand -base64 32
   ```

3. Update secret files in `secrets/` directory if using Docker secrets

4. Verify secrets are NOT committed:
   ```bash
   git status  # Should not show .env or secrets/
   ```

### Docker Secrets (Alternative)

For enhanced security, Docker secrets can be used:
```yaml
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

Then reference in services:
```yaml
services:
  mariadb:
    secrets:
      - db_password
```

## Compliance

This security strategy complies with:
- 42 Inception project requirements (no secrets in repo)
- Docker security best practices
- Industry-standard secret management patterns
