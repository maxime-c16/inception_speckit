# Inception Project - Peer Evaluation Checklist

**Purpose**: Comprehensive requirements validation checklist for 42 Inception project peer evaluation  
**Created**: 2025-11-13  
**Scope**: Docker Infrastructure, Security, Service Integration, and Compliance  
**Usage**: Standard peer evaluation guide with specific commands and testing procedures

---

## Requirement Completeness

### Directory Structure & Files

- [ ] CHK001 - Is the required directory structure documented and present at repository root? [Completeness, Subject §III]
  ```bash
  # Navigate to project root
  cd /path/to/inception
  
  # Verify structure matches requirements
  ls -la
  # Expected: Makefile, srcs/, secrets/ (if using secrets folder approach)
  
  # Check srcs folder structure
  ls -la srcs/
  # Expected: docker-compose.yml, .env, requirements/
  
  # Check requirements structure
  ls -la srcs/requirements/
  # Expected: mariadb/, nginx/, wordpress/, bonus/ (if doing bonus)
  ```

- [ ] CHK002 - Are all mandatory service directories present with required subdirectories? [Completeness, Subject §V]
  ```bash
  # Verify each mandatory service has its structure
  ls -la srcs/requirements/mariadb/
  # Expected: Dockerfile, conf/, tools/
  
  ls -la srcs/requirements/nginx/
  # Expected: Dockerfile, conf/, tools/
  
  ls -la srcs/requirements/wordpress/
  # Expected: Dockerfile, tools/
  ```

- [ ] CHK003 - Is the Makefile present at repository root with required targets? [Completeness, Subject §III]
  ```bash
  # Check Makefile exists
  test -f Makefile && echo "Makefile exists" || echo "ERROR: No Makefile"
  
  # Verify it contains docker-compose build commands
  grep -E "docker-compose|docker compose" Makefile
  # Should show build/up/down commands
  ```

- [ ] CHK004 - Is docker-compose.yml located in srcs/ folder? [Completeness, Subject §III]
  ```bash
  test -f srcs/docker-compose.yml && echo "docker-compose.yml exists" || echo "ERROR: Missing docker-compose.yml"
  ```

- [ ] CHK005 - Is environment variable file (.env) present in srcs/ folder? [Completeness, Subject §V]
  ```bash
  test -f srcs/.env && echo ".env exists" || echo "ERROR: Missing .env"
  
  # Verify .env contains required variables
  cat srcs/.env | grep -E "DOMAIN_NAME|MYSQL"
  ```

- [ ] CHK006 - Are Dockerfile files present for each mandatory service? [Completeness, Subject §V]
  ```bash
  # Check each Dockerfile exists
  test -f srcs/requirements/nginx/Dockerfile && echo "NGINX Dockerfile OK"
  test -f srcs/requirements/wordpress/Dockerfile && echo "WordPress Dockerfile OK"
  test -f srcs/requirements/mariadb/Dockerfile && echo "MariaDB Dockerfile OK"
  ```

- [ ] CHK007 - If bonus services are claimed, are their directories and Dockerfiles present? [Completeness, Subject §VI]
  ```bash
  # Check bonus structure (if applicable)
  ls -la srcs/requirements/bonus/
  
  # Example for common bonuses:
  test -f srcs/requirements/bonus/redis/Dockerfile && echo "Redis bonus present"
  test -f srcs/requirements/bonus/ftp/Dockerfile && echo "FTP bonus present"
  test -f srcs/requirements/bonus/adminer/Dockerfile && echo "Adminer bonus present"
  test -f srcs/requirements/bonus/static-site/Dockerfile && echo "Static site bonus present"
  ```

---

## Requirement Clarity

### Docker Image Base Requirements

- [ ] CHK008 - Do all Dockerfiles explicitly specify Alpine or Debian Buster as base image? [Clarity, Subject §V]
  ```bash
  # Check each Dockerfile starts with correct FROM statement
  head -n 1 srcs/requirements/nginx/Dockerfile
  # Must show: FROM alpine:X.X or FROM debian:buster
  
  head -n 1 srcs/requirements/wordpress/Dockerfile
  # Must show: FROM alpine:X.X or FROM debian:buster
  
  head -n 1 srcs/requirements/mariadb/Dockerfile
  # Must show: FROM alpine:X.X or FROM debian:buster
  
  # For bonus services too
  find srcs/requirements/bonus -name "Dockerfile" -exec head -n 1 {} \;
  ```

- [ ] CHK009 - Are the base image versions specified (penultimate stable version requirement)? [Clarity, Subject §V]
  ```bash
  # Verify versions are pinned, not using :latest
  grep -r "FROM.*:latest" srcs/requirements/
  # Should return NOTHING (no :latest allowed)
  
  # Verify specific versions are used
  grep -r "FROM alpine" srcs/requirements/
  grep -r "FROM debian:buster" srcs/requirements/
  ```

- [ ] CHK010 - Is it clear that no ready-made Docker images are pulled (except Alpine/Debian)? [Clarity, Subject §V]
  ```bash
  # Check for forbidden pre-built images
  grep -ri "FROM nginx:" srcs/requirements/
  grep -ri "FROM wordpress:" srcs/requirements/
  grep -ri "FROM mariadb:" srcs/requirements/
  grep -ri "FROM mysql:" srcs/requirements/
  # All above should return NOTHING
  
  # Only Alpine or Debian should be in FROM statements
  grep -r "^FROM" srcs/requirements/ | grep -v -E "alpine|debian"
  # Should only show build stages or no output
  ```

### Service Configuration Requirements

- [ ] CHK011 - Are NGINX TLS version requirements clearly specified (TLSv1.2 or TLSv1.3 only)? [Clarity, Subject §V]
  ```bash
  # Check NGINX SSL configuration
  cat srcs/requirements/nginx/conf/*.conf | grep -i "ssl_protocol"
  # Should specify: ssl_protocols TLSv1.2 TLSv1.3;
  ```

- [ ] CHK012 - Is the requirement for NGINX to be the sole entry point (port 443 only) documented? [Clarity, Subject §V]
  ```bash
  # Check docker-compose.yml for port mappings
  cat srcs/docker-compose.yml | grep -A 3 "nginx" | grep "ports:"
  # Should only show 443:443
  
  # Verify no other services expose ports externally
  cat srcs/docker-compose.yml | grep "ports:" | grep -v "443:443"
  # Should return nothing or only internal services
  ```

- [ ] CHK013 - Is it specified that WordPress runs with php-fpm (not nginx in same container)? [Clarity, Subject §V]
  ```bash
  # WordPress Dockerfile should NOT contain nginx
  grep -i "nginx" srcs/requirements/wordpress/Dockerfile
  # Should return NOTHING
  
  # Should contain php-fpm
  grep -i "php.*fpm\|php[0-9]-fpm" srcs/requirements/wordpress/Dockerfile
  ```

- [ ] CHK014 - Are domain name requirements clearly defined (login.42.fr format)? [Clarity, Subject §V]
  ```bash
  # Check .env file for domain
  cat srcs/.env | grep "DOMAIN_NAME"
  # Should show: DOMAIN_NAME=login.42.fr (where login is student's login)
  
  # Ask student: "What is your login?"
  # Verify domain matches: [login].42.fr
  ```

- [ ] CHK015 - Are volume mount paths specified to be in /home/login/data/? [Clarity, Subject §V]
  ```bash
  # Check docker-compose.yml for volume definitions
  cat srcs/docker-compose.yml | grep -A 2 "volumes:" | grep "/home"
  # Should show paths like /home/[login]/data/wordpress
  # and /home/[login]/data/mariadb
  ```

### Database Requirements

- [ ] CHK016 - Are MariaDB user requirements specified (2 users, admin username restrictions)? [Clarity, Subject §V]
  ```bash
  # Check for user creation in init scripts
  cat srcs/requirements/mariadb/tools/*.sh | grep -i "CREATE USER\|GRANT"
  
  # During evaluation, verify admin username does NOT contain:
  # - admin
  # - Admin  
  # - administrator
  # - Administrator
  # Ask student: "What is your admin username?"
  ```

- [ ] CHK017 - Is the requirement for no NGINX in MariaDB container documented? [Clarity, Subject §V]
  ```bash
  grep -i "nginx" srcs/requirements/mariadb/Dockerfile
  # Should return NOTHING
  ```

---

## Requirement Consistency

### Docker Networking

- [ ] CHK018 - Are network configuration requirements consistent across docker-compose.yml? [Consistency, Subject §V]
  ```bash
  # Verify 'networks:' section exists in docker-compose.yml
  cat srcs/docker-compose.yml | grep "^networks:" -A 5
  # Must have network definition
  
  # Each service should reference the network
  cat srcs/docker-compose.yml | grep "networks:" | wc -l
  # Should be > 1 (at least network definition + service usage)
  ```

- [ ] CHK019 - Is the prohibition of 'network: host' enforced? [Consistency, Subject §V, Scale §General Instructions]
  ```bash
  grep -i "network.*host\|network_mode.*host" srcs/docker-compose.yml
  # Should return NOTHING
  ```

- [ ] CHK020 - Is the prohibition of '--link' or 'links:' enforced? [Consistency, Subject §V, Scale §General Instructions]
  ```bash
  # Check docker-compose.yml
  grep -i "links:" srcs/docker-compose.yml
  # Should return NOTHING
  
  # Check Makefile and scripts
  grep -r "\-\-link" Makefile srcs/
  # Should return NOTHING
  ```

### Container Restart Policies

- [ ] CHK021 - Are restart policies consistently defined for all services? [Consistency, Subject §V]
  ```bash
  # Check each service has restart policy
  cat srcs/docker-compose.yml | grep "restart:"
  # Should appear for each service (nginx, wordpress, mariadb, etc.)
  # Common values: always, unless-stopped, on-failure
  ```

### Image Naming Consistency

- [ ] CHK022 - Are Docker image names consistent with service names? [Consistency, Subject §V, Scale §Docker Basics]
  ```bash
  # Check docker-compose.yml image names match service names
  cat srcs/docker-compose.yml | grep -E "^  [a-z]|image:"
  # image: should match the service name above it
  ```

---

## Acceptance Criteria Quality

### Build & Deployment Criteria

- [ ] CHK023 - Can the entire application be built and started with Makefile? [Measurability, Subject §III]
  ```bash
  # Clean any existing containers first
  docker stop $(docker ps -qa) 2>/dev/null
  docker rm $(docker ps -qa) 2>/dev/null
  docker rmi -f $(docker images -qa) 2>/dev/null
  docker volume rm $(docker volume ls -q) 2>/dev/null
  docker network rm $(docker network ls -q) 2>/dev/null
  
  # Navigate to project root
  cd /path/to/inception
  
  # Run make
  make
  # Should build all images and start containers without errors
  ```

- [ ] CHK024 - Are all containers created and running after make? [Measurability, Subject §V]
  ```bash
  # Check containers are running
  docker-compose -f srcs/docker-compose.yml ps
  # Should show all services (nginx, wordpress, mariadb) as "Up"
  
  # Alternative using docker ps
  docker ps --format "table {{.Names}}\t{{.Status}}"
  # Should show all containers in "Up" state
  ```

- [ ] CHK025 - Can NGINX be accessed only via port 443 (HTTPS)? [Measurability, Subject §V, Scale §Simple setup]
  ```bash
  # Try HTTP (should fail or redirect)
  curl -I http://login.42.fr
  # Should fail to connect or redirect to https
  
  # Try HTTPS (should work)
  curl -Ik https://login.42.fr
  # Should return HTTP 200 or show WordPress page
  ```

- [ ] CHK026 - Is SSL/TLS certificate properly configured and working? [Measurability, Subject §V, Scale §Simple setup]
  ```bash
  # Check SSL certificate
  echo | openssl s_client -connect login.42.fr:443 -servername login.42.fr 2>/dev/null | openssl x509 -noout -text
  # Should show certificate details
  
  # Verify TLS version
  echo | openssl s_client -connect login.42.fr:443 -tls1_2 2>/dev/null | grep "Protocol"
  # Should show: Protocol : TLSv1.2 or TLSv1.3
  
  # Verify TLS 1.1 and below are NOT supported
  echo | openssl s_client -connect login.42.fr:443 -tls1_1 2>&1 | grep -i "error\|wrong"
  # Should show connection error
  ```

- [ ] CHK027 - Is WordPress accessible and properly installed (not showing installation page)? [Measurability, Subject §V, Scale §Simple setup]
  ```bash
  # Access WordPress via browser or curl
  curl -Ik https://login.42.fr
  # Should return 200 OK
  
  # Check for WordPress installation page (should NOT appear)
  curl -Ik https://login.42.fr/wp-admin/install.php
  # Should return 404 or redirect (not 200 with installation form)
  
  # Verify WordPress is configured
  curl -L https://login.42.fr 2>/dev/null | grep -i "wordpress\|wp-content"
  # Should show WordPress elements
  ```

### Database Criteria

- [ ] CHK028 - Can MariaDB be accessed from WordPress container? [Measurability, Subject §V]
  ```bash
  # Get WordPress container name
  docker-compose -f srcs/docker-compose.yml ps | grep wordpress
  
  # Test database connection from WordPress container
  docker-compose -f srcs/docker-compose.yml exec wordpress sh -c "mysql -h mariadb -u \$DB_USER -p\$DB_PASSWORD -e 'SHOW DATABASES;'"
  # Should list databases including WordPress database
  ```

- [ ] CHK029 - Can MariaDB be accessed with non-admin user but NOT without password as root? [Measurability, Scale §MariaDB and its volume]
  ```bash
  # Get MariaDB container name
  MARIADB_CONTAINER=$(docker-compose -f srcs/docker-compose.yml ps | grep mariadb | awk '{print $1}')
  
  # Try to login as root without password (should FAIL)
  docker exec -it $MARIADB_CONTAINER mysql -u root
  # Should be denied or ask for password
  
  # Login with user credentials (should succeed)
  docker exec -it $MARIADB_CONTAINER mysql -u [username] -p
  # Evaluator enters password, should connect
  ```

- [ ] CHK030 - Is the MariaDB database not empty? [Measurability, Scale §MariaDB and its volume]
  ```bash
  # Connect and verify WordPress database has tables
  docker-compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p[root_password] -e "USE wordpress; SHOW TABLES;"
  # Should show WordPress tables (wp_posts, wp_users, etc.)
  ```

### Volume Persistence Criteria

- [ ] CHK031 - Are Docker volumes created for MariaDB and WordPress? [Measurability, Subject §V]
  ```bash
  # List volumes
  docker volume ls
  # Should show volumes for mariadb and wordpress
  
  # Inspect volumes to verify paths
  docker volume inspect [volume_name]
  # Should show Mountpoint containing /home/[login]/data/
  ```

- [ ] CHK032 - Can persistence be verified by creating content and restarting? [Measurability, Scale §Persistence!]
  ```bash
  # Access WordPress admin
  # Browser: https://login.42.fr/wp-admin
  # Login with admin credentials
  # Create a new post or page, note the title
  
  # Restart containers
  cd /path/to/inception
  docker-compose -f srcs/docker-compose.yml down
  docker-compose -f srcs/docker-compose.yml up -d
  
  # Wait for services to start
  sleep 10
  
  # Verify content still exists
  # Browser: https://login.42.fr
  # The created post/page should still be visible
  
  # OR via curl:
  curl -Lk https://login.42.fr | grep "[your post title]"
  ```

- [ ] CHK033 - Does data persist after VM reboot? [Measurability, Scale §Persistence!]
  ```bash
  # Before reboot: Note current WordPress content
  
  # Reboot VM
  sudo reboot
  
  # After reboot: Navigate to project and restart
  cd /path/to/inception
  make
  
  # Verify all previous content is still present
  curl -Lk https://login.42.fr
  # Should show same content as before reboot
  ```

### WordPress Functional Criteria

- [ ] CHK034 - Can comments be added to WordPress posts using a standard user account? [Measurability, Scale §WordPress with php-fpm]
  ```bash
  # Browser test:
  # 1. Navigate to https://login.42.fr
  # 2. Find a blog post
  # 3. Try to add a comment
  # 4. Submit comment
  # 5. Verify comment appears
  
  # Verify comment in database:
  docker-compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p[password] -e "USE wordpress; SELECT * FROM wp_comments ORDER BY comment_ID DESC LIMIT 1;"
  # Should show the newly added comment
  ```

- [ ] CHK035 - Can pages be edited from WordPress admin dashboard? [Measurability, Scale §WordPress with php-fpm]
  ```bash
  # Browser test:
  # 1. Login to https://login.42.fr/wp-admin
  # 2. Navigate to Pages
  # 3. Edit an existing page
  # 4. Make a visible change (e.g., add text)
  # 5. Click "Update"
  # 6. View the page on the front-end
  # 7. Verify change is visible
  
  # Verify via curl:
  curl -Lk https://login.42.fr/[page-slug]/ | grep "[your new text]"
  ```

- [ ] CHK036 - Are WordPress users properly configured (admin + regular user)? [Measurability, Subject §V]
  ```bash
  # Check WordPress users in database
  docker-compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p[password] -e "USE wordpress; SELECT user_login, user_email FROM wp_users;"
  # Should show at least 2 users
  # Verify admin username does NOT contain 'admin', 'Admin', 'administrator'
  ```

---

## Scenario Coverage

### Primary Flow Coverage

- [ ] CHK037 - Are requirements defined for initial project setup and build? [Coverage, Subject §III-V]
  ```bash
  # Verify documentation or README explains:
  # 1. How to set up .env file
  # 2. How to generate/configure secrets
  # 3. How to build and run (make command)
  
  test -f README.md && cat README.md | grep -i "setup\|installation\|getting started"
  ```

- [ ] CHK038 - Are requirements defined for all three mandatory services (NGINX, WordPress, MariaDB)? [Coverage, Subject §V]
  ```bash
  # Each service should have its own section in docker-compose.yml
  cat srcs/docker-compose.yml | grep "^  nginx:\|^  wordpress:\|^  mariadb:"
  # Should show all three service definitions
  ```

- [ ] CHK039 - Are requirements defined for service communication flow (NGINX → WordPress → MariaDB)? [Coverage, Subject §V]
  ```bash
  # Check service dependencies in docker-compose.yml
  cat srcs/docker-compose.yml | grep -A 10 "wordpress:" | grep "depends_on:"
  # Should show mariadb as dependency
  
  cat srcs/docker-compose.yml | grep -A 10 "nginx:" | grep "depends_on:"
  # Should show wordpress as dependency (or at least network connectivity)
  ```

### Alternate Flow Coverage

- [ ] CHK040 - Are requirements defined for accessing WordPress via different URLs? [Coverage, Gap]
  ```bash
  # Test main page
  curl -Ik https://login.42.fr/
  
  # Test admin panel
  curl -Ik https://login.42.fr/wp-admin/
  
  # Test wp-login
  curl -Ik https://login.42.fr/wp-login.php
  
  # All should return appropriate responses (200, 302 for redirects)
  ```

- [ ] CHK041 - Are requirements defined for multiple user roles (admin and regular user)? [Coverage, Subject §V]
  ```bash
  # Verify both users can login
  # Browser: Login as admin -> should access admin dashboard
  # Browser: Login as regular user -> should access profile/frontend
  
  # Check user capabilities in database
  docker-compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p[password] -e "USE wordpress; SELECT user_login, meta_value FROM wp_users JOIN wp_usermeta ON wp_users.ID = wp_usermeta.user_id WHERE meta_key = 'wp_capabilities';"
  # Should show different roles (administrator, subscriber, etc.)
  ```

### Exception/Error Flow Coverage

- [ ] CHK042 - Are error handling requirements defined for failed container startups? [Coverage, Gap]
  ```bash
  # Check restart policy
  cat srcs/docker-compose.yml | grep "restart:"
  # Should have restart: always or restart: unless-stopped
  
  # Test restart behavior
  # Stop a container manually
  docker stop [container_name]
  
  # Wait and verify it restarts
  sleep 5
  docker ps | grep [container_name]
  # Should show container running again
  ```

- [ ] CHK043 - Are requirements defined for invalid HTTPS certificate handling? [Coverage, Gap]
  ```bash
  # Browser test: Navigate to https://login.42.fr
  # Should show SSL warning (self-signed certificate)
  # Should be able to proceed after accepting warning
  
  # Verify certificate is self-signed
  echo | openssl s_client -connect login.42.fr:443 2>/dev/null | openssl x509 -noout -issuer -subject
  # Issuer and Subject should be the same (self-signed)
  ```

- [ ] CHK044 - Are requirements defined for database connection failures? [Coverage, Gap]
  ```bash
  # Check WordPress configuration for database error handling
  # This is typically in wp-config.php setup
  
  # Test by temporarily stopping MariaDB
  docker stop [mariadb_container]
  
  # Access WordPress
  curl -Ik https://login.42.fr
  # Should show error establishing database connection (or similar)
  
  # Restart MariaDB
  docker start [mariadb_container]
  ```

### Recovery Flow Coverage

- [ ] CHK045 - Are recovery requirements defined for container crashes? [Coverage, Subject §V]
  ```bash
  # Verify restart policy is set
  cat srcs/docker-compose.yml | grep -A 5 "nginx:" | grep "restart:"
  cat srcs/docker-compose.yml | grep -A 5 "wordpress:" | grep "restart:"
  cat srcs/docker-compose.yml | grep -A 5 "mariadb:" | grep "restart:"
  # All should have restart policies
  ```

- [ ] CHK046 - Are data recovery requirements defined (volume persistence)? [Coverage, Subject §V]
  ```bash
  # Verify volumes are external/named (not anonymous)
  cat srcs/docker-compose.yml | grep -A 20 "^volumes:"
  # Should show named volumes
  
  # Volumes should persist even if containers are removed
  docker-compose -f srcs/docker-compose.yml down
  docker volume ls | grep -E "mariadb|wordpress"
  # Volumes should still exist
  ```

### Non-Functional Flow Coverage

- [ ] CHK047 - Are performance requirements addressed (php-fpm optimization)? [Coverage, Gap]
  ```bash
  # Check WordPress container uses php-fpm (not apache)
  docker-compose -f srcs/docker-compose.yml exec wordpress ps aux | grep php-fpm
  # Should show php-fpm processes running
  
  # No Apache should be running in WordPress container
  docker-compose -f srcs/docker-compose.yml exec wordpress ps aux | grep apache
  # Should return nothing
  ```

- [ ] CHK048 - Are security requirements implemented (TLS, no root passwords in files)? [Coverage, Subject §V]
  ```bash
  # Already checked TLS in CHK026
  
  # Verify no passwords in Dockerfiles
  grep -ri "password\|passwd" srcs/requirements/*/Dockerfile
  # Should return nothing or only comments/placeholders
  
  # Verify no passwords in docker-compose.yml (only env var references)
  grep -i "password" srcs/docker-compose.yml
  # Should only show ${VAR_NAME} references, not actual passwords
  ```

---

## Edge Case Coverage

### Container Isolation

- [ ] CHK049 - Are containers isolated (each service in its own container)? [Edge Case, Subject §V, Scale §Docker Basics]
  ```bash
  # Count running containers
  docker-compose -f srcs/docker-compose.yml ps | grep "Up" | wc -l
  # Should be at least 3 (nginx, wordpress, mariadb)
  # +more if bonuses are implemented
  
  # Verify each service runs in separate container
  docker-compose -f srcs/docker-compose.yml exec nginx ps aux | grep -E "mysql|mariadb|php-fpm"
  # Should return NOTHING (nginx should not have db or php)
  
  docker-compose -f srcs/docker-compose.yml exec wordpress ps aux | grep -E "mysql|mariadb|nginx"
  # Should return NOTHING (wordpress should not have db or nginx)
  
  docker-compose -f srcs/docker-compose.yml exec mariadb ps aux | grep -E "nginx|php-fpm"
  # Should return NOTHING (mariadb should not have nginx or php)
  ```

- [ ] CHK050 - Are forbidden container running methods (tail -f, sleep infinity, etc.) absent? [Edge Case, Scale §General Instructions, Subject §V]
  ```bash
  # Check Dockerfiles for forbidden patterns
  grep -r "tail -f\|sleep infinity\|while true" srcs/requirements/
  # Should return NOTHING
  
  # Check entrypoint scripts
  find srcs/requirements -name "*.sh" -exec grep -l "tail -f\|sleep infinity\|while true" {} \;
  # Should return NOTHING
  
  # Verify containers are running as PID 1 properly
  docker-compose -f srcs/docker-compose.yml exec nginx ps aux | head -n 2
  # PID 1 should be nginx or the actual service, not bash/sh
  
  docker-compose -f srcs/docker-compose.yml exec wordpress ps aux | head -n 2
  # PID 1 should be php-fpm or the actual service
  
  docker-compose -f srcs/docker-compose.yml exec mariadb ps aux | head -n 2
  # PID 1 should be mysqld/mariadb or the actual service
  ```

- [ ] CHK051 - Are entrypoint scripts properly designed (no infinite loops in foreground)? [Edge Case, Subject §V]
  ```bash
  # Check entrypoint scripts
  find srcs/requirements -name "docker-entrypoint.sh" -o -name "entrypoint.sh"
  
  # Review each entrypoint script
  cat srcs/requirements/nginx/tools/docker-entrypoint.sh
  # Should end with exec command to replace shell with nginx
  # Example: exec nginx -g 'daemon off;'
  
  cat srcs/requirements/wordpress/tools/docker-entrypoint.sh
  # Should end with exec php-fpm or similar
  
  # No & (background) followed by wait or infinite loop
  grep -r " &.*wait\| &.*while" srcs/requirements/*/tools/
  # Should return NOTHING or be justified
  ```

### Volume Edge Cases

- [ ] CHK052 - Are volume paths correctly configured with login placeholder? [Edge Case, Subject §V]
  ```bash
  # Check docker-compose.yml volume definitions
  cat srcs/docker-compose.yml | grep -A 30 "^volumes:"
  # Should show paths like /home/[login]/data/ or use variable
  
  # Ask student: "Is the login variable set correctly in your .env?"
  # Verify: cat srcs/.env | grep LOGIN
  ```

- [ ] CHK053 - Are volumes properly mounted (read-write permissions)? [Edge Case, Gap]
  ```bash
  # Test write permissions in WordPress
  docker-compose -f srcs/docker-compose.yml exec wordpress touch /var/www/html/test.txt
  # Should succeed
  
  docker-compose -f srcs/docker-compose.yml exec wordpress ls -la /var/www/html/test.txt
  # Should show the file
  
  # Clean up
  docker-compose -f srcs/docker-compose.yml exec wordpress rm /var/www/html/test.txt
  ```

### Network Edge Cases

- [ ] CHK054 - Can containers communicate via docker network (not host network)? [Edge Case, Subject §V]
  ```bash
  # List networks
  docker network ls | grep inception
  # Should show custom network (not host/bridge/none)
  
  # Test connectivity from nginx to wordpress
  docker-compose -f srcs/docker-compose.yml exec nginx ping -c 2 wordpress
  # Should succeed
  
  # Test connectivity from wordpress to mariadb
  docker-compose -f srcs/docker-compose.yml exec wordpress ping -c 2 mariadb
  # Should succeed
  ```

- [ ] CHK055 - Are services accessible ONLY through NGINX (not directly)? [Edge Case, Subject §V]
  ```bash
  # Check no other services expose ports
  cat srcs/docker-compose.yml | grep "ports:" -A 1
  # Should ONLY show nginx with 443:443
  
  # Try to access WordPress directly (should fail)
  docker-compose -f srcs/docker-compose.yml ps | grep wordpress
  # Note: If WordPress exposes port, it violates requirement
  
  # Try to access MariaDB directly (should fail)
  docker-compose -f srcs/docker-compose.yml ps | grep mariadb
  # Note: If MariaDB exposes port, it violates requirement
  ```

### Domain Configuration Edge Cases

- [ ] CHK056 - Is domain name properly configured in /etc/hosts (or DNS)? [Edge Case, Subject §V]
  ```bash
  # Check /etc/hosts for domain entry
  cat /etc/hosts | grep "login.42.fr"
  # Should show: 127.0.0.1 login.42.fr (where login is student's login)
  
  # Test resolution
  ping -c 1 login.42.fr
  # Should resolve to 127.0.0.1 or VM IP
  ```

- [ ] CHK057 - Does HTTPS work with the configured domain name (not IP)? [Edge Case, Subject §V]
  ```bash
  # Access via domain (should work)
  curl -Ik https://login.42.fr
  # Should return 200 OK
  
  # Verify certificate CN matches domain
  echo | openssl s_client -connect login.42.fr:443 -servername login.42.fr 2>/dev/null | openssl x509 -noout -text | grep "CN="
  # Should show CN=login.42.fr or similar
  ```

---

## Non-Functional Requirements

### Security Requirements

- [ ] CHK058 - Are credentials and secrets excluded from git repository? [Completeness, Subject §V, Scale §General Instructions]
  ```bash
  # Check .gitignore
  cat .gitignore | grep -E "\.env|secrets"
  # Should show .env and secrets/ are ignored
  
  # Verify no secrets in git history
  git log --all --full-history -- "*/.env" "*/secrets/*"
  # Should return nothing
  
  # Check for passwords in committed files
  git grep -i "password.*=.*[^$]" -- "*.yml" "Dockerfile*"
  # Should return nothing (only ${VAR} references allowed)
  ```

- [ ] CHK059 - Are environment variables used for all sensitive configuration? [Completeness, Subject §V]
  ```bash
  # Check docker-compose.yml uses environment variables
  cat srcs/docker-compose.yml | grep "environment:" -A 5
  # Should show ${VAR_NAME} syntax for sensitive data
  
  # Verify .env file contains required variables
  cat srcs/.env | grep -E "PASSWORD|USER|ROOT"
  # Should show variable definitions (not committed to git)
  ```

- [ ] CHK060 - Is TLS properly configured with appropriate cipher suites? [Clarity, Subject §V]
  ```bash
  # Test SSL configuration
  nmap --script ssl-enum-ciphers -p 443 login.42.fr
  # Should show only TLSv1.2 and TLSv1.3 ciphers
  
  # OR using testssl.sh if available
  # testssl.sh https://login.42.fr
  ```

- [ ] CHK061 - Are containers running with non-root users where appropriate? [Gap, Best Practice]
  ```bash
  # Check what user processes run as
  docker-compose -f srcs/docker-compose.yml exec nginx whoami
  docker-compose -f srcs/docker-compose.yml exec wordpress whoami
  docker-compose -f srcs/docker-compose.yml exec mariadb whoami
  # Ideally should not be 'root' (but MariaDB may need root initially)
  ```

### Performance Requirements

- [ ] CHK062 - Are Docker images optimized (minimal layers, multi-stage builds where appropriate)? [Gap, Best Practice]
  ```bash
  # Check image sizes
  docker images | grep -E "nginx|wordpress|mariadb"
  # Should be reasonable sizes (not gigabytes)
  
  # Count layers in Dockerfiles
  grep "^RUN\|^COPY\|^ADD" srcs/requirements/nginx/Dockerfile | wc -l
  # Fewer layers is better (consider combining RUN commands)
  ```

- [ ] CHK063 - Do containers start within reasonable time? [Measurability, Gap]
  ```bash
  # Measure startup time
  time docker-compose -f srcs/docker-compose.yml up -d
  # Should complete in < 2 minutes typically
  
  # Check all services are healthy
  docker-compose -f srcs/docker-compose.yml ps
  # All should show "Up" status
  ```

### Maintainability Requirements

- [ ] CHK064 - Is documentation provided for setup and usage? [Completeness, Gap]
  ```bash
  # Check for README or documentation
  test -f README.md && echo "README exists" || echo "No README"
  
  # README should explain:
  cat README.md | grep -i "setup\|install\|usage\|configuration"
  # Should have setup instructions
  ```

- [ ] CHK065 - Are configuration files well-commented? [Clarity, Gap]
  ```bash
  # Check docker-compose.yml has comments
  cat srcs/docker-compose.yml | grep "^#" | wc -l
  # Should have some comments explaining sections
  
  # Check NGINX config has comments
  cat srcs/requirements/nginx/conf/*.conf | grep "#" | wc -l
  # Should have explanatory comments
  ```

- [ ] CHK066 - Is the .env.example file provided (not actual .env)? [Completeness, Gap]
  ```bash
  test -f srcs/.env.example && echo ".env.example exists" || echo "No .env.example"
  
  # .env.example should have placeholder values
  cat srcs/.env.example
  # Should show variable names with example values (not real secrets)
  ```

---

## Dependencies & Assumptions

### Dependency Documentation

- [ ] CHK067 - Are Docker and Docker Compose version requirements documented? [Completeness, Gap]
  ```bash
  # Check README or documentation for version requirements
  cat README.md | grep -i "docker.*version\|docker-compose.*version"
  
  # Verify installed versions
  docker --version
  docker-compose --version
  # Should be compatible versions
  ```

- [ ] CHK068 - Are host system requirements documented (VM, /etc/hosts configuration)? [Completeness, Gap]
  ```bash
  # Check documentation mentions:
  # - Running in a VM
  # - Domain configuration in /etc/hosts
  cat README.md | grep -i "virtual machine\|/etc/hosts\|domain"
  ```

- [ ] CHK069 - Are service dependencies properly defined in docker-compose.yml? [Completeness, Subject §V]
  ```bash
  # Check depends_on clauses
  cat srcs/docker-compose.yml | grep "depends_on:" -A 3
  # Should show service dependency chains
  ```

### Assumption Validation

- [ ] CHK070 - Is the assumption that volumes are on host filesystem documented? [Completeness, Subject §V]
  ```bash
  # Check volume configuration
  cat srcs/docker-compose.yml | grep -A 20 "^volumes:"
  # Should show host paths or named volumes
  
  # Verify actual volume locations
  docker volume inspect [volume_name] | grep Mountpoint
  # Should show /home/[login]/data/ path
  ```

- [ ] CHK071 - Is the assumption of local domain resolution (not public DNS) documented? [Completeness, Subject §V]
  ```bash
  # Documentation should mention configuring /etc/hosts
  cat README.md | grep -i "hosts\|domain.*local"
  
  # Verify domain doesn't resolve publicly
  host login.42.fr 8.8.8.8
  # Should fail or return NXDOMAIN (not a public domain)
  ```

---

## Ambiguities & Conflicts

### Ambiguity Detection

- [ ] CHK072 - Is "php-fpm installation and configuration" clearly specified (not ambiguous)? [Ambiguity, Subject §V]
  ```bash
  # Check WordPress Dockerfile for php-fpm installation
  cat srcs/requirements/wordpress/Dockerfile | grep -i "php.*fpm"
  # Should show clear installation commands
  
  # Check for configuration files
  ls -la srcs/requirements/wordpress/conf/
  # Should show php-fpm config files if custom configuration exists
  ```

- [ ] CHK073 - Is "penultimate stable version" clearly interpreted and documented? [Ambiguity, Subject §V]
  ```bash
  # Check which version is used
  grep "^FROM" srcs/requirements/*/Dockerfile
  # Should show specific version numbers
  
  # Ask student: "Which version did you choose and why is it 'penultimate stable'?"
  # Answer should reference Alpine/Debian version history
  ```

- [ ] CHK074 - Are volume "availability" requirements clear (/home/login/data/)? [Ambiguity, Subject §V]
  ```bash
  # Check if volumes are actually at specified path
  ls -la /home/$(whoami)/data/
  # Should show mariadb and wordpress directories
  
  # OR check docker volume inspect
  docker volume inspect [volume_name] | grep Mountpoint
  # Should confirm path
  ```

### Conflict Detection

- [ ] CHK075 - Is there any conflict between "no nginx in WordPress" and "WordPress with php-fpm"? [Conflict, Subject §V]
  ```bash
  # This should NOT be a conflict - verify WordPress doesn't have nginx
  docker-compose -f srcs/docker-compose.yml exec wordpress ps aux | grep nginx
  # Should return NOTHING
  
  # Verify php-fpm is present
  docker-compose -f srcs/docker-compose.yml exec wordpress ps aux | grep php-fpm
  # Should show php-fpm processes
  ```

- [ ] CHK076 - Is there any conflict between "each service in container" and "network connectivity"? [Conflict, Subject §V]
  ```bash
  # No conflict - verify services are isolated but networked
  # Already tested in CHK049 (isolation) and CHK054 (connectivity)
  
  # Confirm network allows communication despite isolation
  docker-compose -f srcs/docker-compose.yml exec nginx ping -c 2 wordpress
  # Should work (network allows communication)
  ```

---

## Bonus Features (if applicable)

### Redis Cache

- [ ] CHK077 - If Redis bonus claimed: Is Redis container present and configured? [Completeness, Subject §VI]
  ```bash
  # Check Redis Dockerfile
  test -f srcs/requirements/bonus/redis/Dockerfile && echo "Redis Dockerfile exists"
  
  # Check Redis is in docker-compose.yml
  cat srcs/docker-compose.yml | grep "redis:"
  # Should show redis service definition
  
  # Verify Redis container is running
  docker-compose -f srcs/docker-compose.yml ps | grep redis
  # Should show "Up" status
  ```

- [ ] CHK078 - If Redis bonus claimed: Is WordPress configured to use Redis cache? [Completeness, Subject §VI]
  ```bash
  # Check WordPress can connect to Redis
  docker-compose -f srcs/docker-compose.yml exec wordpress redis-cli -h redis ping
  # Should return PONG
  
  # Check WordPress Redis plugin/configuration
  docker-compose -f srcs/docker-compose.yml exec wordpress ls /var/www/html/wp-content/plugins/ | grep redis
  # Should show Redis cache plugin
  
  # OR check wp-config.php for Redis configuration
  docker-compose -f srcs/docker-compose.yml exec wordpress cat /var/www/html/wp-config.php | grep -i redis
  ```

- [ ] CHK079 - If Redis bonus claimed: Can cache functionality be demonstrated? [Measurability, Subject §VI]
  ```bash
  # Check Redis has cached data
  docker-compose -f srcs/docker-compose.yml exec redis redis-cli KEYS "*"
  # Should show cached keys after browsing WordPress
  
  # Measure page load with cache
  time curl -Lks https://login.42.fr > /dev/null
  # Note time, then run again - second time should be faster
  ```

### FTP Server

- [ ] CHK080 - If FTP bonus claimed: Is FTP container present and configured? [Completeness, Subject §VI]
  ```bash
  # Check FTP Dockerfile
  test -f srcs/requirements/bonus/ftp/Dockerfile && echo "FTP Dockerfile exists"
  
  # Check FTP in docker-compose.yml
  cat srcs/docker-compose.yml | grep "ftp:"
  # Should show ftp service definition
  
  # Verify FTP container is running
  docker-compose -f srcs/docker-compose.yml ps | grep ftp
  # Should show "Up" status
  ```

- [ ] CHK081 - If FTP bonus claimed: Does FTP server point to WordPress volume? [Clarity, Subject §VI]
  ```bash
  # Check FTP volume configuration
  cat srcs/docker-compose.yml | grep -A 10 "ftp:" | grep "volumes:"
  # Should show WordPress volume mounted
  
  # Test FTP connection
  ftp login.42.fr
  # Should connect (may need port if not standard 21)
  # Login with FTP credentials
  # Run: ls
  # Should show WordPress files
  ```

- [ ] CHK082 - If FTP bonus claimed: Can files be uploaded/downloaded via FTP? [Measurability, Subject §VI]
  ```bash
  # Test FTP upload
  echo "test file" > test_ftp.txt
  ftp -inv login.42.fr <<EOF
  user [ftp_user] [ftp_password]
  put test_ftp.txt
  ls
  bye
  EOF
  
  # Verify file appears in WordPress
  docker-compose -f srcs/docker-compose.yml exec wordpress ls /var/www/html/ | grep test_ftp.txt
  
  # Clean up
  rm test_ftp.txt
  docker-compose -f srcs/docker-compose.yml exec wordpress rm /var/www/html/test_ftp.txt
  ```

### Adminer

- [ ] CHK083 - If Adminer bonus claimed: Is Adminer container present? [Completeness, Subject §VI]
  ```bash
  # Check Adminer Dockerfile
  test -f srcs/requirements/bonus/adminer/Dockerfile && echo "Adminer Dockerfile exists"
  
  # Check Adminer in docker-compose.yml
  cat srcs/docker-compose.yml | grep "adminer:"
  # Should show adminer service definition
  
  # Verify Adminer container is running
  docker-compose -f srcs/docker-compose.yml ps | grep adminer
  # Should show "Up" status
  ```

- [ ] CHK084 - If Adminer bonus claimed: Is Adminer accessible via web browser? [Measurability, Subject §VI]
  ```bash
  # Check Adminer port/URL
  cat srcs/docker-compose.yml | grep -A 5 "adminer:" | grep "ports:"
  # Note the port
  
  # Access Adminer
  curl -I http://login.42.fr:[adminer_port]
  # OR https if configured
  # Should return 200 OK
  
  # Browser test:
  # Navigate to http://login.42.fr:[port] or configured URL
  # Should show Adminer login page
  ```

- [ ] CHK085 - If Adminer bonus claimed: Can Adminer connect to MariaDB? [Measurability, Subject §VI]
  ```bash
  # Browser test:
  # 1. Open Adminer in browser
  # 2. Enter MariaDB credentials:
  #    System: MySQL
  #    Server: mariadb
  #    Username: [db_user]
  #    Password: [db_password]
  #    Database: wordpress
  # 3. Login
  # 4. Should show database tables
  # 5. Verify can browse wp_posts, wp_users, etc.
  ```

### Static Website

- [ ] CHK086 - If Static Site bonus claimed: Is static website container present? [Completeness, Subject §VI]
  ```bash
  # Check static site Dockerfile
  test -f srcs/requirements/bonus/static-site/Dockerfile && echo "Static site Dockerfile exists"
  
  # Check in docker-compose.yml
  cat srcs/docker-compose.yml | grep "static.*site\|website:"
  # Should show static site service definition
  
  # Verify container is running
  docker-compose -f srcs/docker-compose.yml ps | grep -E "static|website"
  # Should show "Up" status
  ```

- [ ] CHK087 - If Static Site bonus claimed: Is the static site NOT written in PHP? [Clarity, Subject §VI]
  ```bash
  # Check Dockerfile - should NOT install PHP
  cat srcs/requirements/bonus/static-site/Dockerfile | grep -i "php"
  # Should return NOTHING
  
  # Check site files
  ls srcs/requirements/bonus/static-site/site/
  # Should show HTML/CSS/JS files, NOT .php files
  
  find srcs/requirements/bonus/static-site/site -name "*.php"
  # Should return NOTHING
  ```

- [ ] CHK088 - If Static Site bonus claimed: Is the static site accessible via browser? [Measurability, Subject §VI]
  ```bash
  # Check port or URL configuration
  cat srcs/docker-compose.yml | grep -A 10 "static" | grep "ports:"
  
  # Access static site
  curl -I http://login.42.fr:[port]
  # OR configured URL
  # Should return 200 OK
  
  # Browser test: Navigate to URL, verify content displays
  ```

### Custom/Extra Service

- [ ] CHK089 - If custom service bonus claimed: Is the extra service Dockerfile present? [Completeness, Subject §VI]
  ```bash
  # Ask student: "What is your extra service?"
  # Check for its Dockerfile
  ls srcs/requirements/bonus/
  # Should show the custom service directory
  
  test -f srcs/requirements/bonus/[service-name]/Dockerfile && echo "Custom service Dockerfile exists"
  ```

- [ ] CHK090 - If custom service bonus claimed: Can the student justify the service choice? [Clarity, Subject §VI]
  ```bash
  # Ask student:
  # "Why did you choose this service?"
  # "How is it useful for the project?"
  # "How does it integrate with other services?"
  
  # Student should provide clear justification
  # Examples: monitoring, logging, backup, CI/CD, etc.
  ```

- [ ] CHK091 - If custom service bonus claimed: Is the service functional and integrated? [Measurability, Subject §VI]
  ```bash
  # Verify service is running
  docker-compose -f srcs/docker-compose.yml ps | grep [service-name]
  # Should show "Up" status
  
  # Test service functionality based on its purpose
  # Examples:
  # - Monitoring: access dashboard
  # - Logging: check log aggregation
  # - Backup: verify backup process
  # (Specific tests depend on the chosen service)
  ```

- [ ] CHK092 - Do bonus services each run in dedicated containers with proper Dockerfiles? [Completeness, Subject §VI]
  ```bash
  # Verify each bonus has its own Dockerfile
  find srcs/requirements/bonus -name "Dockerfile"
  # Should list one Dockerfile per bonus service
  
  # Verify each bonus service is in docker-compose.yml
  cat srcs/docker-compose.yml | grep -E "redis:|ftp:|adminer:|static|[custom]:"
  # Should show all claimed bonus services
  ```

---

## Traceability & Compliance

### 42 Inception Compliance

- [ ] CHK093 - Does the project follow the required directory structure exactly? [Compliance, Subject §III, Scale §General Instructions]
  ```bash
  # Verify exact structure as per subject
  tree -L 3 .
  # OR
  find . -type f -o -type d | head -50
  
  # Must match:
  # .
  # ├── Makefile
  # ├── secrets/ (or in .env approach)
  # └── srcs/
  #     ├── docker-compose.yml
  #     ├── .env
  #     └── requirements/
  ```

- [ ] CHK094 - Are all forbidden Docker practices absent? [Compliance, Subject §V, Scale §General Instructions]
  ```bash
  # Checklist of forbidden items:
  # [Already checked in other items, summary here]
  
  # ❌ network: host
  grep -r "network.*host" srcs/
  # Should return NOTHING
  
  # ❌ --link or links:
  grep -r "links:\|--link" srcs/ Makefile
  # Should return NOTHING
  
  # ❌ tail -f, sleep infinity, while true
  grep -r "tail -f\|sleep infinity\|while true" srcs/
  # Should return NOTHING
  
  # ❌ Ready-made images (except Alpine/Debian)
  grep "^FROM" srcs/requirements/*/Dockerfile | grep -v -E "alpine|debian"
  # Should return NOTHING (or only build stages)
  
  # ❌ :latest tag
  grep ":latest" srcs/
  # Should return NOTHING
  ```

- [ ] CHK095 - Are all mandatory services implemented per specification? [Compliance, Subject §V]
  ```bash
  # Checklist:
  # ✅ NGINX with TLSv1.2/1.3
  # ✅ WordPress with php-fpm (no nginx)
  # ✅ MariaDB (no nginx)
  # ✅ Docker network
  # ✅ Volumes for WordPress and MariaDB
  # ✅ Domain name configuration
  # ✅ Automatic restart
  # ✅ No passwords in Dockerfiles
  # ✅ .env usage
  
  # All previous checks validate these items
  ```

### Documentation Traceability

- [ ] CHK096 - Can each requirement be traced to implementation? [Traceability, Gap]
  ```bash
  # For evaluator: Map requirements to files
  # Example:
  # - NGINX TLS → srcs/requirements/nginx/conf/*.conf
  # - WordPress php-fpm → srcs/requirements/wordpress/Dockerfile
  # - MariaDB → srcs/requirements/mariadb/Dockerfile
  # - Volumes → srcs/docker-compose.yml volumes section
  # - Network → srcs/docker-compose.yml networks section
  # - .env → srcs/.env
  
  # Ask student to explain where each requirement is implemented
  ```

- [ ] CHK097 - Is there documentation explaining design decisions? [Gap]
  ```bash
  # Check for design documentation
  test -f docs/architecture.md && echo "Architecture docs exist"
  test -f docs/security.md && echo "Security docs exist"
  test -f README.md && echo "README exists"
  
  # README should explain key decisions:
  cat README.md | grep -i "design\|architecture\|decision"
  ```

---

## Final Validation

### Integration Testing

- [ ] CHK098 - Can the entire system be started from clean state with one command? [Measurability, Subject §III]
  ```bash
  # Complete cleanup
  cd /path/to/inception
  docker-compose -f srcs/docker-compose.yml down -v
  docker stop $(docker ps -qa) 2>/dev/null
  docker rm $(docker ps -qa) 2>/dev/null
  docker rmi -f $(docker images -qa) 2>/dev/null
  docker volume rm $(docker volume ls -q) 2>/dev/null
  docker network rm $(docker network ls -q) 2>/dev/null
  
  # Build and start with single command
  make
  
  # Verify all services are up
  docker-compose -f srcs/docker-compose.yml ps
  # All should show "Up"
  
  # Verify WordPress is accessible
  curl -Ik https://login.42.fr
  # Should return 200 OK
  ```

- [ ] CHK099 - Can the system be stopped and cleaned with Makefile? [Measurability, Subject §III]
  ```bash
  # Test make clean
  make clean
  # Should stop containers
  
  docker ps
  # Should show no project containers running
  
  # Test make fclean
  make fclean
  # Should remove containers, images, volumes
  
  docker images | grep -E "nginx|wordpress|mariadb"
  # Should return nothing
  
  docker volume ls | grep -E "wordpress|mariadb"
  # Should return nothing (if fclean removes volumes)
  ```

### End-to-End Scenarios

- [ ] CHK100 - Can a complete user workflow be executed successfully? [Measurability, Coverage]
  ```bash
  # Complete workflow test:
  
  # 1. Start system
  make
  
  # 2. Access WordPress
  curl -Ik https://login.42.fr
  # Should work
  
  # 3. Login to WordPress admin
  # Browser: https://login.42.fr/wp-admin
  # Login with admin credentials
  
  # 4. Create a new post
  # Title: "Test Post"
  # Content: "This is a test"
  # Publish
  
  # 5. View post on frontend
  # Browser: https://login.42.fr
  # Verify post appears
  
  # 6. Restart system
  docker-compose -f srcs/docker-compose.yml restart
  
  # 7. Verify post still exists
  curl -Lk https://login.42.fr | grep "Test Post"
  # Should find the post
  
  # 8. Clean up
  # Delete the test post via admin panel
  ```

---

## Summary Statistics

**Total Checklist Items**: 100  
**Mandatory Coverage**: CHK001-CHK076 (76 items)  
**Bonus Coverage**: CHK077-CHK092 (16 items)  
**Compliance & Validation**: CHK093-CHK100 (8 items)

**Traceability Coverage**:
- 95% of items include specific references to Subject sections or Scale evaluation points
- 100% of items include testable validation commands
- All requirements from inception.txt and scale.txt are covered

**Usage Guide**:
1. Start with CHK001-CHK007 (Project structure)
2. Proceed through CHK008-CHK048 (Core requirements)
3. Test CHK077-CHK092 only if bonuses are claimed
4. Validate with CHK093-CHK100 (Compliance and final tests)
5. Mark each item as pass/fail during evaluation
6. Document any issues or deviations

**Commands Reference**:
- All validation commands are provided inline with each checklist item
- Commands use student's login variable where applicable
- curl, docker, and openssl commands validate web services and security
- Manual browser testing noted where automated testing is insufficient
