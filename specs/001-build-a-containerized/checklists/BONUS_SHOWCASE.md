# Bonus Services Showcase Guide

This guide demonstrates how to test and showcase each of the 5 bonus services in the Inception project.

---

## 1. Redis - Caching Layer

### What it does
Redis provides object caching for WordPress to improve performance by storing frequently accessed data in memory.

### Testing via CLI (exec into container)

```bash
# Enter Redis container
docker exec -it redis sh

# Test authentication (should fail without password)
redis-cli PING
# Expected: (error) NOAUTH Authentication required.

# Authenticate with password
redis-cli -a $REDIS_PASSWORD PING
# Expected: PONG

# Check if WordPress is using Redis
redis-cli -a $REDIS_PASSWORD DBSIZE
# Expected: (integer) <number of keys>

# View cached WordPress data
redis-cli -a $REDIS_PASSWORD SCAN 0 COUNT 10
# Expected: List of cache keys like "wp:options:*" or "wp:posts:*"

# Get cache statistics
redis-cli -a $REDIS_PASSWORD INFO stats
# Shows hits, misses, and other stats

# Exit container
exit
```

### Testing from Host

```bash
# Test Redis connection
docker exec redis redis-cli -a "$(grep REDIS_PASSWORD srcs/.env | cut -d= -f2)" PING

# Check number of cached items
docker exec redis redis-cli -a "$(grep REDIS_PASSWORD srcs/.env | cut -d= -f2)" DBSIZE

# Monitor Redis commands in real-time
docker exec redis redis-cli -a "$(grep REDIS_PASSWORD srcs/.env | cut -d= -f2)" MONITOR
# Then visit your WordPress site to see cache operations
```

### Visual Showcase

```bash
# Before using Redis cache
echo "Without cache - check WordPress load time"
time curl -k -s https://localhost > /dev/null

# Clear Redis cache
docker exec redis redis-cli -a "$(grep REDIS_PASSWORD srcs/.env | cut -d= -f2)" FLUSHDB

# Visit site to populate cache
curl -k -s https://localhost > /dev/null

# Check cache is populated
docker exec redis redis-cli -a "$(grep REDIS_PASSWORD srcs/.env | cut -d= -f2)" DBSIZE

# After using Redis cache
echo "With cache - check WordPress load time"
time curl -k -s https://localhost > /dev/null
```

---

## 2. FTP Server - File Transfer

### What it does
Provides FTP access to the WordPress files for easy file management and uploads.

### Testing via CLI (exec into container)

```bash
# Enter FTP container
docker exec -it ftp sh

# Check FTP service is running
ps aux | grep vsftpd
# Expected: vsftpd process running

# Check WordPress mount point
ls -la /home/*/wordpress
# Expected: WordPress files visible

# View FTP configuration
cat /etc/vsftpd.conf | grep -E "listen|pasv_enable|port"

# Exit container
exit
```

### Testing with FTP Client

```bash
# Install FTP client if not available
# sudo apt-get install ftp

# Connect via command-line FTP
ftp localhost 21
# Enter credentials from .env file:
# Username: FTP_USER value
# Password: FTP_PASS value

# FTP commands to test:
# ls                  # List WordPress files
# cd wp-content       # Navigate to wp-content
# pwd                 # Show current directory
# get index.php       # Download a file (test)
# bye                 # Exit FTP
```

### Quick Test from Terminal

```bash
# Test FTP connection with curl
curl -v ftp://localhost:21 --user "$(grep FTP_USER srcs/.env | cut -d= -f2):$(grep FTP_PASS srcs/.env | cut -d= -f2)"

# List files via FTP
curl ftp://localhost:21/wordpress/ --user "$(grep FTP_USER srcs/.env | cut -d= -f2):$(grep FTP_PASS srcs/.env | cut -d= -f2)"
```

---

## 3. Adminer - Database Management UI

### What it does
Web-based database management tool for MariaDB (like phpMyAdmin but lighter).

### Access via Web Browser

```bash
# Open in browser
http://localhost:8081

# Or use curl to verify it's running
curl -I http://localhost:8081
# Expected: HTTP/1.1 200 OK
```

### Login Credentials

```
System: MySQL
Server: mariadb
Username: <MYSQL_USER from .env>
Password: <MYSQL_PASSWORD from .env>
Database: <MYSQL_DATABASE from .env>
```

### What to Showcase

1. **Login Screen**
   - Shows clean, simple interface
   - Server dropdown shows "mariadb" (our container name)

2. **Database Overview**
   - Click on database name (wordpress)
   - Shows all WordPress tables (wp_posts, wp_users, etc.)

3. **Browse Data**
   - Click on `wp_users` table
   - View WordPress users you created
   - Shows structure and data

4. **Run SQL Queries**
   - Click "SQL command" 
   - Test query: `SELECT * FROM wp_users;`
   - Shows query results

5. **Export Database**
   - Click "Export" on left menu
   - Can export entire database

### Testing via CLI

```bash
# Verify Adminer is serving
curl -s http://localhost:8081 | grep -i "adminer\|login"

# Check container logs
docker logs adminer
```

---

## 4. Static Website - Non-PHP Site

### What it does
Serves a simple HTML static website demonstrating ability to run multiple web services.

### Access via Web Browser

```bash
# Open in browser
http://localhost:8080

# Or verify with curl
curl http://localhost:8080
```

### Testing via CLI (exec into container)

```bash
# Enter static site container
docker exec -it static sh

# View the static HTML content
cat /var/www/html/index.html

# Check what web server is running
ls -la /usr/sbin/ | grep -E "lighttpd|nginx"

# Check if lighttpd process is running
pidof lighttpd || echo "Check with: ls /proc/"

# Test locally within container using built-in tools
cat /var/www/html/index.html | head -5

# Exit container
exit
```

### Testing from Host

```bash
# Get the page content
curl -s http://localhost:8080 | grep -i "<title>\|<h1>"

# Check HTTP headers
curl -I http://localhost:8080
# Expected: Server: nginx

# Download the page
curl -o static-page.html http://localhost:8080
cat static-page.html
```

### What to Showcase

- **Simple HTML page** (no PHP processing)
- **Different port** (8080 vs 443 for main site)
- **Separate web server** from main NGINX
- Demonstrates **multiple services** coexisting

---

## 5. Portainer - Container Management UI

### What it does
Web-based container management interface for Docker - allows you to manage all containers, images, volumes, and networks through a GUI.

### Access via Web Browser

```bash
# Open in browser
http://localhost:9000

# Or verify API is responding
curl -s http://localhost:9000/api/status
# Expected: {"Version":"2.11.1","InstanceID":"..."}
```

### First-Time Setup

1. **Initial Access**
   - Navigate to `http://localhost:9000`
   - Create admin user on first visit
   - Username: `admin`
   - Password: (set a strong password)

2. **Connect to Local Docker**
   - Choose "Docker" environment
   - Select "Connect to local Docker"
   - Click "Connect"

### What to Showcase

1. **Dashboard**
   - Shows overview of all containers
   - Running/stopped status
   - Resource usage graphs

2. **Container Management**
   - Click "Containers" in left menu
   - Shows all 8 containers (nginx, wordpress, mariadb, redis, ftp, adminer, static, portainer)
   - Can start/stop/restart containers
   - View logs directly in browser
   - Open container console (exec into container via web UI)

3. **Live Stats**
   - Click on any container
   - View real-time CPU, Memory, Network usage
   - Shows running processes

4. **Container Logs**
   - Click on container → "Logs" tab
   - View real-time logs
   - Can search and filter

5. **Exec/Console**
   - Click on container → "Console"
   - Choose `/bin/sh` or `/bin/bash`
   - "Connect" button
   - Now you're inside the container via web UI!

6. **Images**
   - Click "Images" in left menu
   - Shows all Docker images
   - Including custom built images (srcs-nginx, srcs-wordpress, etc.)

7. **Networks**
   - Click "Networks"
   - Shows "inception" network
   - Can see which containers are connected

8. **Volumes**
   - Click "Volumes"
   - Shows all volumes (db_data, wp_data, portainer_data)
   - Can browse volume contents

### Testing via CLI

```bash
# Check Portainer is running
docker ps | grep portainer

# Test API endpoint
curl -s http://localhost:9000/api/status | python3 -m json.tool

# View logs
docker logs portainer --tail 20

# Check version
curl -s http://localhost:9000/api/status | grep -o '"Version":"[^"]*"'
```

### Advanced Portainer Features to Demo

```bash
# 1. Container Stats via API
curl -s http://localhost:9000/api/status

# 2. Quick Actions
# From Portainer UI:
# - Restart nginx container
# - View nginx logs
# - Exec into wordpress container
# - Check resource usage

# 3. Network Visualization
# Shows how containers are connected via inception network
```

---

## Complete Bonus Services Test Script

Here's a comprehensive script to test all bonus services at once:

```bash
#!/bin/bash

echo "=========================================="
echo "BONUS SERVICES SHOWCASE"
echo "=========================================="
echo ""

# 1. Redis
echo "1. Testing Redis Cache..."
REDIS_KEYS=$(docker exec redis redis-cli -a "$(grep REDIS_PASSWORD srcs/.env | cut -d= -f2)" DBSIZE 2>/dev/null | grep -v Warning)
echo "   ✓ Redis: $REDIS_KEYS keys cached"
echo ""

# 2. FTP
echo "2. Testing FTP Server..."
FTP_STATUS=$(docker exec ftp ps aux | grep vsftpd | grep -v grep | wc -l)
if [ "$FTP_STATUS" -gt 0 ]; then
    echo "   ✓ FTP: Service running on port 21"
else
    echo "   ✗ FTP: Not running"
fi
echo ""

# 3. Adminer
echo "3. Testing Adminer..."
ADMINER_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081)
if [ "$ADMINER_STATUS" = "200" ]; then
    echo "   ✓ Adminer: Available at http://localhost:8081"
else
    echo "   ✗ Adminer: Not responding"
fi
echo ""

# 4. Static Site
echo "4. Testing Static Website..."
STATIC_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$STATIC_STATUS" = "200" ]; then
    echo "   ✓ Static Site: Available at http://localhost:8080"
else
    echo "   ✗ Static Site: Not responding"
fi
echo ""

# 5. Portainer
echo "5. Testing Portainer..."
PORTAINER_VERSION=$(curl -s http://localhost:9000/api/status 2>/dev/null | grep -o '"Version":"[^"]*"' | cut -d'"' -f4)
if [ -n "$PORTAINER_VERSION" ]; then
    echo "   ✓ Portainer: v$PORTAINER_VERSION at http://localhost:9000"
else
    echo "   ✗ Portainer: Not responding"
fi
echo ""

echo "=========================================="
echo "BONUS SERVICES SUMMARY"
echo "=========================================="
echo ""
echo "Access Points:"
echo "  - Redis:       docker exec -it redis redis-cli"
echo "  - FTP:         ftp://localhost:21"
echo "  - Adminer:     http://localhost:8081"
echo "  - Static Site: http://localhost:8080"
echo "  - Portainer:   http://localhost:9000"
echo ""
```

Save this as `test_bonus.sh` and run:

```bash
chmod +x test_bonus.sh
./test_bonus.sh
```

---

## Visual Presentation Order for Evaluation

### Recommended showcase sequence:

1. **Start with Portainer** (most impressive)
   - Show dashboard with all 8 containers
   - Navigate through different sections
   - Exec into a container via web UI
   
2. **Adminer** (database management)
   - Login and show WordPress database
   - Browse tables
   - Run a simple query
   
3. **Redis** (performance enhancement)
   - Show cached keys via CLI
   - Explain WordPress performance improvement
   
4. **Static Site** (simplest to demonstrate)
   - Open in browser
   - Show it's separate from WordPress
   
5. **FTP** (file management)
   - Connect with FTP client
   - Show WordPress files
   - Navigate directories

---

## Quick Reference Commands

```bash
# All bonus containers status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "redis|ftp|adminer|static|portainer"

# Test all web UIs at once
echo "Adminer:   $(curl -s -o /dev/null -w '%{http_code}' http://localhost:8081)"
echo "Static:    $(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080)"
echo "Portainer: $(curl -s -o /dev/null -w '%{http_code}' http://localhost:9000)"

# Get all bonus service logs
for service in redis ftp adminer static portainer; do
    echo "=== $service logs ===" && docker logs $service --tail 5 && echo ""
done
```

---

## Troubleshooting

If any service isn't working:

```bash
# Check container status
docker ps -a | grep <service_name>

# View logs
docker logs <service_name>

# Restart specific service
docker restart <service_name>

# Rebuild specific service
docker-compose -f srcs/docker-compose.yml build <service_name> --no-cache
make down && make up
```
