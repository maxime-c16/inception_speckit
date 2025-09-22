#!/bin/sh
# T034: Reproducibility test: teardown and redeploy, verify data persistence
set -e
docker-compose up -d mariadb wordpress
sleep 10
# Create a test DB/table
docker-compose exec mariadb mysql -uwp_user -pexample_pw -e "CREATE TABLE IF NOT EXISTS wordpress.test_table (id INT);"
docker-compose down
docker-compose up -d mariadb wordpress
sleep 10
docker-compose exec mariadb mysql -uwp_user -pexample_pw -e "SHOW TABLES IN wordpress;" | grep -q test_table || { echo 'Data not persisted after redeploy'; exit 1; }
echo 'Reproducibility test passed.'
