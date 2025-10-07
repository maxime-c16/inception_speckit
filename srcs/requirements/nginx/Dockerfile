FROM debian:bullseye

# Install NGINX and OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories for certificates and web content
RUN mkdir -p /etc/nginx/ssl && \
    chown -R www-data:www-data /etc/nginx/ssl

# Copy NGINX configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy entrypoint script
COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Expose HTTPS port
EXPOSE 443

# Use entrypoint script to generate certificate and start NGINX (runs as root, then switches to www-data)
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
