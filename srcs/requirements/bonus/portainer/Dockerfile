FROM debian:bullseye

# Install dependencies
RUN apt-get update && \
    apt-get install -y wget tar ca-certificates curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Portainer with all its assets
RUN wget https://github.com/portainer/portainer/releases/download/2.11.1/portainer-2.11.1-linux-amd64.tar.gz && \
    tar -xzf portainer-2.11.1-linux-amd64.tar.gz -C /usr/local && \
    rm portainer-2.11.1-linux-amd64.tar.gz && \
    chmod +x /usr/local/portainer/portainer && \
    chmod +x /usr/local/portainer/docker-compose

# Create data directory
RUN mkdir -p /data

# Set up PATH to include Portainer binaries
ENV PATH="/usr/local/portainer:$PATH"

# Expose Portainer ports
EXPOSE 9000
EXPOSE 9443

# Start Portainer
CMD ["/usr/local/portainer/portainer", "--data", "/data"]
