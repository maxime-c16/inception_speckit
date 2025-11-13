#!/bin/bash
# Patch 003: Verify Redis authentication and WordPress integration
# Issue: CHK088 - Redis requires authentication, verify WordPress plugin integration

set -e

echo "=========================================="
echo "Patch 003: Redis Verification"
echo "=========================================="
echo ""

# Check if running from project root
if [ ! -f "Makefile" ]; then
    echo "❌ Error: Must run from project root (where Makefile is located)"
    exit 1
fi

echo "Step 1: Checking Redis container status..."
if docker ps --filter "name=redis" | grep -q redis; then
    REDIS_CONTAINER=$(docker ps --filter "name=redis" --format "{{.Names}}")
    echo "✅ Redis container is running: $REDIS_CONTAINER"
else
    echo "❌ Redis container not found or not running"
    echo "   Run 'make up' first to start services"
    exit 1
fi
echo ""

echo "Step 2: Testing Redis authentication..."
echo "----------------------------------------"

# Try without password (should fail)
echo "Testing connection without password (should fail with NOAUTH):"
if docker exec "$REDIS_CONTAINER" redis-cli PING 2>&1 | grep -q "NOAUTH"; then
    echo "✅ Redis correctly requires authentication"
else
    echo "⚠️  Redis may not require authentication (security concern)"
fi
echo ""

# Try with password from environment
echo "Testing connection with password from .env:"
REDIS_PASSWORD=$(grep "^REDIS_PASSWORD=" srcs/.env 2>/dev/null || grep "^REDIS_PASSWORD=" .env 2>/dev/null | cut -d= -f2)

if [ -z "$REDIS_PASSWORD" ]; then
    echo "❌ REDIS_PASSWORD not found in .env file"
    echo "   Add REDIS_PASSWORD=yourpassword to .env"
    exit 1
fi

if docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" PING 2>&1 | grep -q "PONG"; then
    echo "✅ Redis authentication successful with password"
else
    echo "❌ Redis authentication failed"
    echo "   Check redis.conf and verify password configuration"
fi
echo "----------------------------------------"
echo ""

echo "Step 3: Checking Redis configuration..."
echo "----------------------------------------"
docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" CONFIG GET requirepass 2>&1 | grep -v "Warning"
docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" CONFIG GET maxmemory-policy 2>&1 | grep -v "Warning"
echo "----------------------------------------"
echo ""

echo "Step 4: Verifying WordPress container connectivity to Redis..."
if docker ps --filter "name=wordpress" | grep -q wordpress; then
    WORDPRESS_CONTAINER=$(docker ps --filter "name=wordpress" --format "{{.Names}}")
    echo "✅ WordPress container found: $WORDPRESS_CONTAINER"
    
    echo ""
    echo "Testing Redis connection from WordPress container:"
    echo "----------------------------------------"
    
    # Get Redis host from docker-compose or use default
    REDIS_HOST="redis"
    
    if docker exec "$WORDPRESS_CONTAINER" which redis-cli >/dev/null 2>&1; then
        echo "Testing with redis-cli from WordPress container:"
        docker exec "$WORDPRESS_CONTAINER" redis-cli -h "$REDIS_HOST" -a "$REDIS_PASSWORD" PING 2>&1 | grep -v "Warning"
    else
        echo "redis-cli not available in WordPress container"
        echo "Testing network connectivity to Redis port 6379:"
        if docker exec "$WORDPRESS_CONTAINER" nc -zv "$REDIS_HOST" 6379 2>&1; then
            echo "✅ Network connection to Redis successful"
        else
            echo "⚠️  Cannot connect to Redis from WordPress"
        fi
    fi
    echo "----------------------------------------"
else
    echo "❌ WordPress container not found"
fi
echo ""

echo "Step 5: Checking WordPress Redis plugin..."
echo "----------------------------------------"

# Check if Redis Object Cache plugin exists
if docker exec "$WORDPRESS_CONTAINER" test -d /var/www/html/wp-content/plugins/redis-cache 2>/dev/null; then
    echo "✅ Redis Object Cache plugin installed"
    
    # Check if plugin is active
    if docker exec "$WORDPRESS_CONTAINER" wp plugin list --path=/var/www/html --allow-root 2>/dev/null | grep redis-cache | grep -q active; then
        echo "✅ Redis Object Cache plugin is active"
    else
        echo "⚠️  Redis Object Cache plugin installed but not active"
        echo ""
        echo "To activate the plugin:"
        echo "  docker exec $WORDPRESS_CONTAINER wp plugin activate redis-cache --path=/var/www/html --allow-root"
    fi
else
    echo "⚠️  Redis Object Cache plugin not found"
    echo ""
    echo "To install Redis Object Cache plugin:"
    echo "  docker exec $WORDPRESS_CONTAINER wp plugin install redis-cache --activate --path=/var/www/html --allow-root"
fi
echo "----------------------------------------"
echo ""

echo "Step 6: Checking WordPress wp-config.php for Redis configuration..."
echo "----------------------------------------"
if docker exec "$WORDPRESS_CONTAINER" grep -q "WP_REDIS" /var/www/html/wp-config.php 2>/dev/null; then
    echo "Redis configuration found in wp-config.php:"
    docker exec "$WORDPRESS_CONTAINER" grep "WP_REDIS" /var/www/html/wp-config.php 2>/dev/null || echo "No WP_REDIS constants defined"
else
    echo "⚠️  No Redis configuration in wp-config.php"
    echo ""
    echo "Add these lines to wp-config.php before 'That's all, stop editing!':"
    echo ""
    echo "define('WP_REDIS_HOST', 'redis');"
    echo "define('WP_REDIS_PORT', 6379);"
    echo "define('WP_REDIS_PASSWORD', '$REDIS_PASSWORD');"
    echo "define('WP_REDIS_DATABASE', 0);"
    echo "define('WP_CACHE_KEY_SALT', 'inception_');"
fi
echo "----------------------------------------"
echo ""

echo "Step 7: Testing actual cache functionality..."
echo "----------------------------------------"

# Test if WordPress is actually writing to Redis
KEYS_COUNT=$(docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" DBSIZE 2>/dev/null | grep -v "Warning")
echo "Current keys in Redis: $KEYS_COUNT"

if [ "$KEYS_COUNT" != "0" ]; then
    echo "✅ Redis contains data (likely from WordPress)"
    echo ""
    echo "Sample keys:"
    docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" --scan --count 10 2>/dev/null | head -5 | grep -v "Warning"
else
    echo "⚠️  Redis is empty (no cached data yet)"
    echo "   This is normal if WordPress cache plugin is not configured"
fi
echo "----------------------------------------"
echo ""

echo "=========================================="
echo "Redis Verification Complete"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - Redis authentication: $(docker exec "$REDIS_CONTAINER" redis-cli -a "$REDIS_PASSWORD" PING 2>&1 | grep -q "PONG" && echo "✅ Working" || echo "❌ Failed")"
echo "  - WordPress connectivity: Check output above"
echo "  - Plugin status: Check output above"
echo "  - Active caching: Check keys count above"
echo ""
echo "Next Steps:"
echo ""
echo "1. If plugin not installed:"
echo "   docker exec $WORDPRESS_CONTAINER wp plugin install redis-cache --activate --path=/var/www/html --allow-root"
echo ""
echo "2. If wp-config.php needs Redis constants:"
echo "   Edit srcs/requirements/wordpress/tools/setup-wordpress.sh"
echo "   Add Redis configuration before wp config create"
echo "   Rebuild: make re"
echo ""
echo "3. Verify cache is working:"
echo "   - Visit WordPress site multiple times"
echo "   - Run this script again to check key count increases"
echo "   - Or check WordPress admin: Settings > Redis"
