#!/bin/sh
# T010: Integration test for WordPress + MariaDB
set -e
docker-compose up -d wordpress mariadb
sleep 10
docker-compose exec mariadb mysql -uwp_user -pexample_pw -e 'SHOW DATABASES;' | grep -q wordpress || { echo 'WordPress DB missing'; exit 1; }
curl -k https://localhost/ | grep -qi 'wordpress' || { echo 'WordPress not running'; exit 1; }
echo 'WordPress + MariaDB integration test passed.'
