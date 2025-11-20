FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y redis-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir -p /var/lib/redis && \
    chown -R redis:redis /var/lib/redis

EXPOSE 6379

USER redis

CMD ["redis-server", "--protected-mode", "no"]
