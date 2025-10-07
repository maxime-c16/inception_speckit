FROM debian:bullseye

# Install PHP-FPM and required PHP extensions for WordPress
RUN apt-get update && \
    apt-get install -y \
        php7.4-fpm \
        php7.4-mysql \
        php7.4-curl \
        php7.4-gd \
        php7.4-mbstring \
        php7.4-xml \
        php7.4-xmlrpc \
        php7.4-zip \
        php7.4-intl \
        php7.4-redis \
        curl \
        wget \
        unzip \
        mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install WP-CLI for WordPress management
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/' /etc/php/7.4/fpm/pool.d/www.conf && \
    mkdir -p /run/php && \
    chown -R www-data:www-data /run/php

# Copy WordPress setup script
COPY tools/setup-wordpress.sh /usr/local/bin/setup-wordpress.sh
RUN chmod +x /usr/local/bin/setup-wordpress.sh

# Set working directory
WORKDIR /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Run as www-data user
USER www-data

# Run setup script
CMD ["/usr/local/bin/setup-wordpress.sh"]
