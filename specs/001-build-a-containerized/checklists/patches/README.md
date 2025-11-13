# Patch Application Guide

This directory contains patch scripts to fix issues identified during the Inception project evaluation.

## Patches Overview

| Patch | Priority | Issue | Description |
|-------|----------|-------|-------------|
| 001 | Medium | CHK005 | Move .env to srcs/ for strict compliance |
| 002 | High | CHK092 | Diagnose and fix Portainer restart loop |
| 003 | Low | CHK088 | Verify Redis-WordPress integration |

## Application Instructions

### Prerequisites

Before applying patches:
```bash
cd /home/macauchy/inception_speckit
make down  # Stop all services
```

### Patch 001: Move .env to srcs/

**Issue:** .env file should be in `srcs/` directory per subject requirements

**Apply:**
```bash
./specs/001-build-a-containerized/checklists/patches/001-move-env-to-srcs.sh
```

**What it does:**
- Creates backup of .env, Makefile, .gitignore
- Copies .env to srcs/.env
- Updates Makefile to reference srcs/.env
- Updates .gitignore to exclude srcs/.env

**Verify:**
```bash
# Check file exists
ls -la srcs/.env

# Check Makefile updated
grep "srcs/.env" Makefile

# Test system
make up
docker ps
```

**Rollback if needed:**
```bash
mv .env.backup .env
mv Makefile.backup Makefile
rm srcs/.env
```

---

### Patch 002: Fix Portainer

**Issue:** Portainer container in continuous restart loop (exit code 1)

**Apply:**
```bash
./specs/001-build-a-containerized/checklists/patches/002-fix-portainer.sh
```

**What it does:**
- Displays container status and logs
- Shows configuration details
- Checks volume permissions
- Identifies port conflicts
- Provides recommendations

**Common fixes identified by script:**

1. **Volume permission issues:**
   ```bash
   sudo chown -R $USER:$USER /home/macauchy/data/portainer
   # or
   sudo chown -R root:root /home/macauchy/data/portainer
   ```

2. **Dockerfile issues:**
   - Check `srcs/requirements/bonus/portainer/Dockerfile`
   - Should be: `FROM portainer/portainer-ce:alpine` or similar
   - Should NOT have custom CMD/ENTRYPOINT

3. **docker-compose.yml issues:**
   - Verify volume: `/var/run/docker.sock:/var/run/docker.sock`
   - Verify volume: `portainer_data:/data`
   - Verify port: `9443:9443` (or change if conflict)

**Verify:**
```bash
make up
docker ps | grep portainer  # Should show "Up" not "Restarting"
curl -k https://localhost:9443  # Should respond
```

---

### Patch 003: Verify Redis

**Issue:** Redis authentication configured, need to verify WordPress integration

**Apply:**
```bash
./specs/001-build-a-containerized/checklists/patches/003-verify-redis.sh
```

**What it does:**
- Tests Redis authentication
- Checks WordPress-Redis connectivity
- Verifies Redis Object Cache plugin
- Checks wp-config.php configuration
- Tests actual caching functionality

**If fixes needed:**

1. **Install WordPress Redis plugin:**
   ```bash
   docker exec wordpress wp plugin install redis-cache --activate \
     --path=/var/www/html --allow-root
   ```

2. **Add Redis config to wp-config.php:**
   - Edit `srcs/requirements/wordpress/tools/setup-wordpress.sh`
   - Add before `wp config create`:
   ```bash
   cat >> /var/www/html/wp-config.php << 'EOF'
   define('WP_REDIS_HOST', 'redis');
   define('WP_REDIS_PORT', 6379);
   define('WP_REDIS_PASSWORD', getenv('REDIS_PASSWORD'));
   define('WP_REDIS_DATABASE', 0);
   EOF
   ```

3. **Rebuild WordPress:**
   ```bash
   make down
   make up
   ```

**Verify:**
```bash
# Check Redis has data
docker exec redis redis-cli -a "$REDIS_PASSWORD" DBSIZE

# Check plugin status
docker exec wordpress wp plugin list --path=/var/www/html --allow-root | grep redis

# Visit WordPress admin at: https://yourdomain.com/wp-admin
# Go to Settings > Redis to see cache status
```

---

## Recommended Application Order

Apply patches in this order:

1. **First:** Patch 001 (move .env)
   - Affects all services
   - Apply before testing others

2. **Second:** Patch 002 (fix Portainer)
   - Critical for bonus points
   - Follow script recommendations

3. **Third:** Patch 003 (verify Redis)
   - Enhancement/verification
   - Ensures proper caching

## Testing After All Patches

```bash
# Stop everything
make down

# Start fresh
make up

# Check all services
docker ps

# Run evaluation checklist
cd /home/macauchy/inception_speckit/specs/001-build-a-containerized/checklists
# Review evaluation.md items CHK005, CHK088, CHK092
```

## Backup Strategy

All patches create backups automatically:
- `.env.backup`
- `Makefile.backup`
- `.gitignore.backup`

Keep these until you confirm everything works.

## Rollback

If anything goes wrong:

```bash
# Stop services
make down

# Restore from backups
mv .env.backup .env
mv Makefile.backup Makefile
rm srcs/.env

# Rebuild
make up
```

## Score Impact

After applying all patches successfully:

- **Current Score:** 93/100
  - Mandatory: 76/76 ✅
  - Bonus: 15/16 (Portainer failing)
  - Compliance: 8/8 ✅

- **Expected Score After Patches:** 100/100
  - Mandatory: 76/76 ✅
  - Bonus: 16/16 ✅ (if Portainer fixed)
  - Compliance: 8/8 ✅

## Need Help?

If patches don't resolve issues:

1. Check detailed logs:
   ```bash
   docker logs <container_name>
   ```

2. Review ISSUES_AND_FIXES.md for detailed explanations

3. Check evaluation.md for specific test commands

4. Verify subject requirements in `/home/macauchy/inception_speckit/inception.txt`
