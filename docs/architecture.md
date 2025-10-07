# Architecture Documentation - Inception Project

## System Overview

The Inception project implements a modern, containerized web infrastructure following microservices architecture principles. Each service runs in an isolated Docker container, communicating through a custom bridge network.

## Container Architecture

### Network Topology

```
Internet/Client
       ↓
   [Port 443]
       ↓
┌──────────────────┐
│  NGINX (TLS)     │  ← Entry point, TLS termination
│  Reverse Proxy   │
└────────┬─────────┘
         │ inception network (Docker bridge)
         ├─────────→ WordPress (php-fpm:9000)
         ├─────────→ Static Site (lighttpd:80)
         └─────────→ Adminer (php:8080)
                            
WordPress
    ↓
MariaDB (:3306)
    ↓
Redis (:6379) ← Cache layer

FTP (:21) → WordPress Volume

Portainer (:9000) → Docker Socket
```

### Service Communication

1. **Client → NGINX**
   - HTTPS traffic on port 443
   - TLS v1.2/v1.3 encryption
   - Self-signed certificate for `login.42.fr`

2. **NGINX → WordPress**
   - FastCGI proxy to php-fpm on port 9000
   - Shared volume for WordPress files (read-only on NGINX)

3. **WordPress → MariaDB**
   - MySQL protocol on port 3306
   - Credentials from environment variables
   - Database: `wordpress`, User: `wp_user`

4. **WordPress → Redis**
   - Redis protocol on port 6379
   - Password authentication
   - Object caching for performance

5. **FTP → WordPress**
   - Shared volume mount
   - Access to `/var/www/html`
   - Passive mode ports: 21000-21010

## Volume Management

### Data Persistence

| Volume | Mount Point | Service | Purpose |
|--------|-------------|---------|---------|
| `db_data` | `/var/lib/mysql` | MariaDB | Database files |
| `wp_data` | `/var/www/html` | WordPress, NGINX, FTP | WordPress installation |
| `portainer_data` | `/data` | Portainer | Portainer configuration |

### Volume Lifecycle

1. **Creation**: Volumes are automatically created on first `docker-compose up`
2. **Persistence**: Data survives container restarts and recreations
3. **Backup**: Volumes can be backed up using Docker volume commands
4. **Cleanup**: Removed with `make clean` or `make fclean`

### Volume Permissions

- **db_data**: Owned by `mysql:mysql` (UID/GID varies by system)
- **wp_data**: Owned by `www-data:www-data` (typically 33:33)
- Read-only mounts used where modification isn't needed (NGINX)

## Network Configuration

### Inception Network

- **Type**: Bridge network
- **Name**: `inception`
- **Driver**: `bridge`
- **Isolation**: All services isolated from host and other networks
- **DNS**: Docker's embedded DNS server (service name resolution)

### Service Discovery

Services communicate using service names as hostnames:
- `wordpress` → WordPress container
- `mariadb` → MariaDB container
- `redis` → Redis container
- `nginx` → NGINX container

Example: WordPress connects to `mariadb:3306` for database access

### Security Boundaries

- No `--link` usage (deprecated)
- No `network_mode: host` (forbidden by Inception)
- Each service only exposes necessary ports
- Internal communication uses custom network
- External access only through NGINX or specific service ports

## Data Flow

### WordPress Page Request

```
1. Client HTTPS request → login.42.fr:443
2. NGINX receives request, validates TLS
3. NGINX proxies to wordpress:9000 (FastCGI)
4. WordPress checks Redis cache (redis:6379)
   - Cache hit: Return cached data
   - Cache miss: Continue to step 5
5. WordPress queries MariaDB (mariadb:3306)
6. MariaDB returns data
7. WordPress processes PHP, generates HTML
8. Response sent back through NGINX to client
9. WordPress updates Redis cache
```

### File Upload Flow

```
1. Client uploads file via WordPress
2. File saved to /var/www/html/wp-content/uploads
3. Volume wp_data persists the file
4. File accessible via:
   - WordPress (read/write)
   - NGINX (read-only, serves static files)
   - FTP (read/write, for file management)
```

### Database Initialization Flow

```
1. MariaDB container starts
2. init-db.sh script executes
3. Check if database exists:
   - Yes: Skip initialization
   - No: Create database and user
4. Set root password from MYSQL_ROOT_PASSWORD
5. Create wordpress database
6. Create wp_user with MYSQL_PASSWORD
7. Grant privileges on wordpress database
8. MariaDB ready for connections
```

## Security Architecture

### Defense in Depth

1. **Network Layer**
   - Isolated custom network
   - No unnecessary port exposure
   - Service-to-service authentication

2. **Application Layer**
   - TLS encryption for external traffic
   - Environment-based secrets
   - No hardcoded credentials

3. **Container Layer**
   - Non-root users where possible
   - Minimal base images
   - Read-only filesystems where applicable

4. **Data Layer**
   - Persistent volumes for stateful data
   - Backup-friendly volume architecture
   - Secrets excluded from images

### Secret Flow

```
Host .env file
    ↓
Docker Compose reads environment variables
    ↓
Variables injected into containers at runtime
    ↓
Applications use environment variables (never hardcoded)
```

## Scalability Considerations

### Current Limitations

- Single instance of each service
- No load balancing
- No horizontal scaling
- Shared volumes (not suitable for multi-host)

### Potential Improvements

1. **Database Replication**
   - Add MariaDB replica containers
   - Read/write splitting
   - Failover capabilities

2. **WordPress Scaling**
   - Multiple WordPress containers
   - NGINX load balancing
   - Shared/distributed file storage (NFS, S3)

3. **Caching Optimization**
   - Redis cluster mode
   - Separate cache for sessions/objects
   - CDN integration for static assets

4. **High Availability**
   - Multiple NGINX instances
   - Health checks and automatic failover
   - Database clustering

## Monitoring and Observability

### Current Implementation

- **Portainer**: Visual container management
- **Docker logs**: Centralized logging via `docker-compose logs`
- **Adminer**: Database monitoring and management

### Recommended Additions

1. **Logging Stack**
   - ELK (Elasticsearch, Logstash, Kibana)
   - Centralized log aggregation
   - Log retention policies

2. **Metrics**
   - Prometheus for metrics collection
   - Grafana for visualization
   - Container resource monitoring

3. **Alerting**
   - Alert on container crashes
   - Disk usage warnings
   - Performance degradation alerts

## Deployment Workflow

### Build Process

```
1. make build
   ↓
2. Docker reads each Dockerfile
   ↓
3. Images built in dependency order:
   - MariaDB (no dependencies)
   - Redis (no dependencies)
   - WordPress (needs MariaDB ready)
   - NGINX (needs WordPress ready)
   - Bonus services (parallel)
   ↓
4. Images tagged and stored locally
```

### Startup Sequence

```
1. make up
   ↓
2. Docker Compose creates network
   ↓
3. Docker Compose creates volumes
   ↓
4. Containers start (respecting depends_on):
   - MariaDB starts first
   - WordPress waits for MariaDB
   - NGINX waits for WordPress
   - Bonus services start in parallel
   ↓
5. Health checks verify services
   ↓
6. System ready
```

### Update Strategy

1. **Rolling Updates**
   ```bash
   docker-compose up -d --no-deps --build <service>
   ```

2. **Blue-Green Deployment** (future)
   - Deploy new version alongside old
   - Switch traffic once verified
   - Rollback if issues detected

3. **Database Migrations**
   - Backup before updates
   - Test migrations in staging
   - Run WordPress updates via WP-CLI

## Backup and Recovery

### Backup Strategy

1. **Volume Backup**
   ```bash
   docker run --rm -v db_data:/data -v $(pwd):/backup \
     debian tar czf /backup/db_backup.tar.gz /data
   ```

2. **Database Dump**
   ```bash
   docker exec mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} \
     wordpress > backup.sql
   ```

3. **Full System Backup**
   ```bash
   docker-compose down
   tar czf inception_backup.tar.gz srcs/ secrets/
   ```

### Recovery Process

1. Stop all services
2. Restore volumes or database dumps
3. Verify .env configuration
4. Start services
5. Verify functionality

## Performance Optimization

### Current Optimizations

1. **Redis Caching**
   - Object cache for WordPress
   - Reduces database queries
   - Improves page load times

2. **NGINX Optimization**
   - Static file caching
   - Gzip compression
   - FastCGI caching (can be added)

3. **Docker Optimization**
   - Multi-stage builds (where applicable)
   - Minimal base images
   - Layer caching

### Future Enhancements

1. **CDN Integration**: Offload static assets
2. **Database Optimization**: Query caching, indexing
3. **PHP-FPM Tuning**: Process management, OPcache
4. **Resource Limits**: CPU/memory constraints per container

## Compliance with 42 Inception

### Architectural Requirements Met

- ✅ Each service in its own container
- ✅ Custom bridge network (no host/--link)
- ✅ Persistent volumes for data
- ✅ No pre-built images (built from Debian/Alpine)
- ✅ Automatic restart on crash
- ✅ Environment-based configuration
- ✅ TLS v1.2/v1.3 for NGINX
- ✅ Domain name configuration (login.42.fr)

### Design Decisions

1. **Debian over Alpine**: Broader package availability, easier debugging
2. **Custom network**: Service isolation and security
3. **Shared volumes**: Data persistence and multi-container access
4. **Environment variables**: Flexible, secure configuration management

---

*This architecture is designed for educational purposes as part of the 42 School Inception project. For production use, additional hardening and scaling would be recommended.*
