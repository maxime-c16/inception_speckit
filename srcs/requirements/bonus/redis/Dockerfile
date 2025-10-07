FROM debian:bullseye

# Install Redis
RUN apt-get update && \
    apt-get install -y redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy Redis configuration if needed
# COPY conf/redis.conf /etc/redis/redis.conf

# Create redis user directories
RUN mkdir -p /var/lib/redis && \
    chown -R redis:redis /var/lib/redis

# Expose Redis port
EXPOSE 6379

# Run as redis user
USER redis

# Start Redis (password will be set via command in docker-compose.yml)
CMD ["redis-server", "--protected-mode", "no"]
