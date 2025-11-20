FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y wget tar ca-certificates curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/portainer/portainer/releases/download/2.11.1/portainer-2.11.1-linux-amd64.tar.gz && \
    tar -xzf portainer-2.11.1-linux-amd64.tar.gz -C /usr/local && \
    rm portainer-2.11.1-linux-amd64.tar.gz && \
    chmod +x /usr/local/portainer/portainer && \
    chmod +x /usr/local/portainer/docker-compose

RUN mkdir -p /data

ENV PATH="/usr/local/portainer:$PATH"

EXPOSE 9000
EXPOSE 9443

CMD ["/usr/local/portainer/portainer", "--data", "/data"]
