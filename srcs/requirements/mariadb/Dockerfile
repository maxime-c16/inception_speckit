FROM debian:bullseye

# Install MariaDB server
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 755 /var/run/mysqld

# Copy initialization script
COPY tools/init-db.sh /usr/local/bin/init-db.sh
RUN chmod +x /usr/local/bin/init-db.sh

# Copy MariaDB configuration if needed
# COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Expose MariaDB port
EXPOSE 3306

# Run initialization script and start MariaDB as root (init script will manage permissions/start as needed)
CMD ["/usr/local/bin/init-db.sh"]
