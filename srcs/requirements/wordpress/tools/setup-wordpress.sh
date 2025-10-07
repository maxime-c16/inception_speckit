#!/bin/bash
set -e

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"${WORDPRESS_DB_HOST}" --silent; do
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
        cat >> /var/www/html/wp-config.php <<EOF

/* Redis Cache Configuration */
define('WP_REDIS_HOST', '${REDIS_HOST}');
define('WP_REDIS_PASSWORD', '${REDIS_PASSWORD}');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_DATABASE', 0);
define('WP_CACHE_KEY_SALT', 'inception_');
EOF
    fi
    
    # Install WordPress (only if not already installed)
    if ! wp core is-installed --allow-root 2>/dev/null; then
        echo "Installing WordPress..."
        wp core install \
            --url="https://macauchy.42.fr" \
            --title="Inception WordPress" \
            --admin_user="wpuser" \
            --admin_password="SecurePass123!" \
            --admin_email="wpuser@macauchy.42.fr" \
            --allow-root
        
        echo "WordPress installed successfully!"
    fi
    
    # Create a second user (non-admin)
    if ! wp user get editor --allow-root 2>/dev/null; then
        wp user create editor editor@macauchy.42.fr \
            --role=editor \
            --user_pass="EditorPass123!" \
            --allow-root || true
    fi
    
    # Install and activate Redis Object Cache plugin if Redis is configured
    if [ -n "${REDIS_HOST}" ]; then
        wp plugin install redis-cache --activate --allow-root || true
        wp redis enable --allow-root || true
    fi
else
    echo "WordPress already configured."
fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/html

# Start PHP-FPM in foreground
echo "Starting PHP-FPM..."
exec php-fpm7.4 -F
