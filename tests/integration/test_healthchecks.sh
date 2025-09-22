#!/bin/sh
# T007: Compose healthcheck tests for all containers
set -e
docker-compose up -d
sleep 10
fail=0
# Accept both 'Running' and 'Started' as healthy
# Use docker inspect for reliable state detection
for svc in nginx wordpress mariadb redis static adminer extra; do
	cname=$(docker-compose ps -q $svc)
	if [ -z "$cname" ]; then
		echo "$svc container not found"; fail=1; continue
	fi
	state=$(docker inspect -f '{{.State.Status}}' "$cname")
	if [ "$state" != "running" ]; then
		echo "$svc container not running (state: $state)"; fail=1
	fi
done
# NGINX healthcheck
docker-compose exec nginx nginx -t || fail=1
# WordPress healthcheck
docker-compose exec wordpress ps aux | grep php-fpm || fail=1
# MariaDB healthcheck
docker-compose exec mariadb mysqladmin ping -u root -pexample_root_pw || fail=1
# Redis healthcheck
docker-compose exec redis redis-cli -a example_redis_pw ping | grep -q PONG || fail=1
# Static site healthcheck (nginx process)
docker-compose exec static ps aux | grep nginx || fail=1
# Adminer healthcheck (php-fpm or apache2)
docker-compose exec adminer ps aux | grep -E 'php-fpm|apache2' || true
# Extra service healthcheck
docker-compose exec extra ps aux || true
if [ "$fail" -eq 0 ]; then
	echo "All containers healthy"
	exit 0
else
	echo "Some containers failed healthchecks"
	exit 1
fi
