FROM debian:bullseye

# Install PHP and required extensions for Adminer
RUN apt-get update && \
    apt-get install -y \
        php7.4 \
        php7.4-mysql \
        php7.4-mysqli \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download Adminer
RUN mkdir -p /var/www/html && \
    wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php && \
    chown -R www-data:www-data /var/www/html

# Expose port
EXPOSE 8080

# Run as www-data user
USER www-data

# Start PHP built-in server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
