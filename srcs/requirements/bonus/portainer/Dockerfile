FROM debian:bullseye

# Install wget and tar
RUN apt-get update && \
    apt-get install -y wget tar && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Portainer
RUN wget https://github.com/portainer/portainer/releases/download/2.19.1/portainer-2.19.1-linux-amd64.tar.gz && \
    tar -xvf portainer-2.19.1-linux-amd64.tar.gz && \
    mv portainer/portainer /usr/local/bin/ && \
    rm -rf portainer portainer-2.19.1-linux-amd64.tar.gz

# Create portainer user
RUN useradd -r -s /bin/false portainer && \
    mkdir -p /data && \
    chown -R portainer:portainer /data

# Expose Portainer port
EXPOSE 9000

# Run as portainer user
# Do not switch to a non-root user so Portainer can access the Docker socket bind-mounted from the host
# Install Docker Compose CLI plugin so Portainer's compose deployer can initialize
RUN mkdir -p /usr/libexec/docker/cli-plugins /usr/local/lib/docker/cli-plugins && \
        wget -q -O /usr/libexec/docker/cli-plugins/docker-compose \
            https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 && \
    chmod +x /usr/libexec/docker/cli-plugins/docker-compose && \
    cp /usr/libexec/docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Keep running as root so the container can access the host docker socket and the compose plugin
# Start Portainer
CMD ["/usr/local/bin/portainer", "--data", "/data"]
