#!/bin/bash
set -e

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --skip-networking --skip-syslog --nowatch &
MYSQL_PID=$!

echo "Waiting for MariaDB to start..."
for i in {1..30}; do
    if mysqladmin ping --silent; then
        echo "MariaDB is up!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 1
done

run_sql_no_auth() {
    mysql -u root "$@"
}

chown -R mysql:mysql /var/lib/mysql

if [ ! -f "/var/lib/mysql/.db_initialized" ]; then
    if run_sql_no_auth -e "SELECT 1;" >/dev/null 2>&1; then
        echo "Root login works, running initialization SQL"
        run_sql_no_auth <<-EOSQL
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER//\'/\'\'}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD//\'/\'\'}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL
    else
        echo "Root login failed (access denied). Restarting server with --skip-grant-tables to initialize."
        mysqladmin shutdown || true
        sleep 2
        mysqld_safe --skip-networking --skip-grant-tables --skip-syslog --nowatch &
        for i in {1..30}; do
            if mysqladmin ping --silent; then
                echo "MariaDB (skip-grant-tables) is up"
                break
            fi
            echo "Waiting for (skip-grant-tables) start... ($i/30)"
            sleep 1
        done

        mysql -u root <<-EOSQL
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
UPDATE mysql.user SET plugin='mysql_native_password', authentication_string=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE User='root' AND Host='localhost';
EOSQL

        echo "Initialization SQL applied while skip-grant-tables enabled. Restarting MariaDB normally."
        mysqladmin shutdown || true
        sleep 2
        mysqld_safe --skip-networking --skip-syslog --nowatch &
        for i in {1..30}; do
            if mysqladmin ping --silent; then
                echo "MariaDB restarted normally"
                break
            fi
            sleep 1
        done
    fi

    touch /var/lib/mysql/.db_initialized
    echo "Database ${MYSQL_DATABASE} initialization finished."
else
    echo "Database ${MYSQL_DATABASE} already exists, skipping initialization."
fi

mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown || mysqladmin -u root shutdown || true

echo "Starting MariaDB..."
exec mysqld_safe --bind-address=0.0.0.0 --skip-syslog
