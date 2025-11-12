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

# Ensure lighttpd can create its pid file when running as www-data
RUN mkdir -p /run/lighttpd && chown -R www-data:www-data /run/lighttpd
# Create the pid file path that lighttpd expects and make it writable by www-data
RUN touch /run/lighttpd.pid && chown www-data:www-data /run/lighttpd.pid

# Expose HTTP port
EXPOSE 80

# Run as www-data user
USER www-data

# Start lighttpd
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
