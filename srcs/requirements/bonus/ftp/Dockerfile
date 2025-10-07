FROM debian:bullseye

# Install vsftpd FTP server
RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create FTP user directory
RUN mkdir -p /home/ftpuser

# Expose FTP ports
EXPOSE 21 21000-21010

# Run entrypoint
CMD ["/usr/local/bin/docker-entrypoint.sh"]
