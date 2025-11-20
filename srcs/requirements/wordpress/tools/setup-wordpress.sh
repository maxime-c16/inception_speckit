#!/bin/bash
set -e

# Required configuration (with sane defaults)
DOMAIN_NAME=${DOMAIN_NAME:-macauchy.42.fr}
SITE_URL=${WORDPRESS_SITE_URL:-"https://${DOMAIN_NAME}"}
SITE_TITLE=${WORDPRESS_TITLE:-"Inception WordPress"}

ADMIN_USER=${WORDPRESS_ADMIN_USER:-wpowner}
ADMIN_PASS=${WORDPRESS_ADMIN_PASSWORD:-}
ADMIN_EMAIL=${WORDPRESS_ADMIN_EMAIL:-wpowner@example.com}

SECONDARY_USER=${WORDPRESS_SECONDARY_USER:-wpeditor}
SECONDARY_PASS=${WORDPRESS_SECONDARY_USER_PASSWORD:-}
SECONDARY_EMAIL=${WORDPRESS_SECONDARY_USER_EMAIL:-wpeditor@example.com}

# Validate admin username requirement from subject
if echo "${ADMIN_USER}" | grep -qi 'admin'; then
    echo "[ERROR] WORDPRESS_ADMIN_USER (${ADMIN_USER}) must not contain 'admin'." >&2
    exit 1
fi

if [ -z "${ADMIN_PASS}" ] || [ -z "${SECONDARY_PASS}" ]; then
    echo "[ERROR] WORDPRESS_ADMIN_PASSWORD and WORDPRESS_SECONDARY_USER_PASSWORD must be provided." >&2
    exit 1
fi

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping \
    -h"${WORDPRESS_DB_HOST}" \
    -u"${WORDPRESS_DB_USER}" \
    -p"${WORDPRESS_DB_PASSWORD}" \
    --silent 2>/dev/null; do
    echo "MariaDB is unavailable - sleeping"
    sleep 2
done
echo "MariaDB is up!"

# Download WordPress if not already present
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress not found, downloading..."
    
    # Download WordPress
    wp core download --allow-root || true
    
    # Create wp-config.php
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root
    
    # Add Redis configuration to wp-config.php
    if [ -n "${REDIS_HOST}" ] && [ -n "${REDIS_PASSWORD}" ]; then
        wp config set WP_REDIS_HOST "${REDIS_HOST}" --type=constant --allow-root
        wp config set WP_REDIS_PASSWORD "${REDIS_PASSWORD}" --type=constant --allow-root
        wp config set WP_REDIS_PORT 6379 --type=constant --raw --allow-root
        wp config set WP_REDIS_DATABASE 0 --type=constant --raw --allow-root
        wp config set WP_CACHE_KEY_SALT 'inception_' --type=constant --allow-root
        wp config set WP_REDIS_GRACEFUL true --type=constant --raw --allow-root
        wp config set WP_CACHE true --type=constant --raw --allow-root
    fi
    
    # Install WordPress (only if not already installed)
    if ! wp core is-installed --allow-root 2>/dev/null; then
        echo "Installing WordPress..."
        wp core install \
            --url="${SITE_URL}" \
            --title="${SITE_TITLE}" \
            --admin_user="${ADMIN_USER}" \
            --admin_password="${ADMIN_PASS}" \
            --admin_email="${ADMIN_EMAIL}" \
            --allow-root
        
            echo "WordPress installed successfully!"
    fi
else
    echo "WordPress already configured."
fi

    # Ensure administrator account matches requirements
    if wp user get "${ADMIN_USER}" --allow-root >/dev/null 2>&1; then
        wp user update "${ADMIN_USER}" \
            --role=administrator \
            --user_pass="${ADMIN_PASS}" \
            --user_email="${ADMIN_EMAIL}" \
            --allow-root >/dev/null
    else
        wp user create "${ADMIN_USER}" "${ADMIN_EMAIL}" \
            --role=administrator \
            --user_pass="${ADMIN_PASS}" \
            --allow-root >/dev/null
    fi

    # Ensure secondary user exists with editor role
    if wp user get "${SECONDARY_USER}" --allow-root >/dev/null 2>&1; then
        wp user update "${SECONDARY_USER}" \
            --role=editor \
            --user_pass="${SECONDARY_PASS}" \
            --user_email="${SECONDARY_EMAIL}" \
            --allow-root >/dev/null
    else
        wp user create "${SECONDARY_USER}" "${SECONDARY_EMAIL}" \
            --role=editor \
            --user_pass="${SECONDARY_PASS}" \
            --allow-root >/dev/null
    fi

    # Refresh site metadata (idempotent)
    wp option update siteurl "${SITE_URL}" --allow-root >/dev/null
    wp option update home "${SITE_URL}" --allow-root >/dev/null
    wp option update blogname "${SITE_TITLE}" --allow-root >/dev/null

    # Install and activate Redis Object Cache plugin if Redis is configured
    if [ -n "${REDIS_HOST}" ]; then
        wp plugin install redis-cache --activate --allow-root >/dev/null 2>&1 || true
        wp redis enable --allow-root >/dev/null 2>&1 || true
    fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/html

# Start PHP-FPM in foreground
echo "Starting PHP-FPM..."
exec php-fpm8.2 -F
