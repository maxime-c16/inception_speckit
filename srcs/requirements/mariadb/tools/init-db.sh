#!/bin/bash
set -e

# Start MariaDB in the background for initialization
mysqld_safe --skip-networking --nowatch &
MYSQL_PID=$!

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
for i in {1..30}; do
    if mysqladmin ping --silent; then
        echo "MariaDB is up!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 1
done

# Check if database needs initialization
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Initializing database ${MYSQL_DATABASE}..."
    
    # Secure the installation and create database
    mysql -u root <<-EOSQL
        -- Secure the installation
        DELETE FROM mysql.user WHERE User='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        
        -- Set root password
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        
        -- Create database
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        
        -- Create user and grant privileges
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        
        -- Flush privileges
        FLUSH PRIVILEGES;
EOSQL

    echo "Database ${MYSQL_DATABASE} initialized successfully!"
else
    echo "Database ${MYSQL_DATABASE} already exists, skipping initialization."
fi

# Stop the background MariaDB
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown || mysqladmin -u root shutdown

# Start MariaDB in foreground
echo "Starting MariaDB..."
exec mysqld_safe
