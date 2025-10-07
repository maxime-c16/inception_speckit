FROM debian:bullseye

# Install lighttpd (simple, non-PHP web server)
RUN apt-get update && \
    apt-get install -y lighttpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy static website content
COPY site/ /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Expose HTTP port
EXPOSE 80

# Run as www-data user
USER www-data

# Start lighttpd
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
