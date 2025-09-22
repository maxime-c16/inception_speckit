#!/bin/sh
# T008: Security scan test for images
set -e
echo "Scanning for secrets with trufflehog..."
trufflehog filesystem --fail --no-update . || { echo 'Secrets found!'; exit 1; }
echo "Scanning Docker images for vulnerabilities..."
for svc in nginx wordpress mariadb redis ftp static adminer extra; do
	img=$(docker-compose config | grep image | grep $svc | awk '{print $2}')
	if [ -n "$img" ]; then
		docker scan "$img" || true
	fi
done
echo "Security scan complete."
