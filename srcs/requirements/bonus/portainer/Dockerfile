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
USER portainer

# Start Portainer
CMD ["/usr/local/bin/portainer", "--data", "/data"]
