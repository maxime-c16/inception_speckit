#!/bin/bash
set -e

### Start MariaDB in the background for initialization
mysqld_safe --skip-networking --nowatch &
MYSQL_PID=$!

### Wait for MariaDB to start (socket up)
echo "Waiting for MariaDB to start..."
for i in {1..30}; do
    if mysqladmin ping --silent; then
        echo "MariaDB is up!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 1
done

### Helper: run SQL via root (no password)
run_sql_no_auth() {
    mysql -u root "$@"
}

### Ensure permissions on data directory (host bind mounts can change ownership)
chown -R mysql:mysql /var/lib/mysql

### Initialize database if missing
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Initializing database ${MYSQL_DATABASE}..."

    # Try a simple root command to see if root can run SQL
    if run_sql_no_auth -e "SELECT 1;" >/dev/null 2>&1; then
        echo "Root login works, running initialization SQL"
        run_sql_no_auth <<-EOSQL
            DELETE FROM mysql.user WHERE User='';
            DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
            DROP DATABASE IF EXISTS test;
            DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
            CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
            CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
            GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
            FLUSH PRIVILEGES;
EOSQL
    else
        echo "Root login failed (access denied). Restarting server with --skip-grant-tables to initialize."
        # Stop the current server and restart with skip-grant-tables so we can write grants
        mysqladmin shutdown || true
        sleep 2
        mysqld_safe --skip-networking --skip-grant-tables --nowatch &
        for i in {1..30}; do
            if mysqladmin ping --silent; then
                echo "MariaDB (skip-grant-tables) is up"
                break
            fi
            echo "Waiting for (skip-grant-tables) start... ($i/30)"
            sleep 1
        done

        # Now run SQL to create DB and user directly
        mysql -u root <<-EOSQL
            CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
            CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
            GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
            FLUSH PRIVILEGES;
EOSQL

        echo "Initialization SQL applied while skip-grant-tables enabled. Restarting MariaDB normally."
        mysqladmin shutdown || true
        sleep 2
        mysqld_safe --skip-networking --nowatch &
        for i in {1..30}; do
            if mysqladmin ping --silent; then
                echo "MariaDB restarted normally"
                break
            fi
            sleep 1
        done

        run_sql_no_auth <<-EOSQL
            DELETE FROM mysql.user WHERE User='';
            DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
            DROP DATABASE IF EXISTS test;
            DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
            CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
            CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
            GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
            FLUSH PRIVILEGES;
EOSQL
    fi

    echo "Database ${MYSQL_DATABASE} initialization finished."
else
    echo "Database ${MYSQL_DATABASE} already exists, skipping initialization."
fi

# Stop any background server started for initialization
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown || mysqladmin -u root shutdown || true

# Start MariaDB in foreground, binding to all interfaces so other containers can connect
echo "Starting MariaDB..."
exec mysqld_safe --bind-address=0.0.0.0
