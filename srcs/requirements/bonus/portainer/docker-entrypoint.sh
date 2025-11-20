#!/bin/sh
set -e

echo "=== Portainer starting ==="
echo "Standalone docker-compose: $(/usr/local/bin/docker-compose --version 2>/dev/null || echo 'NOT FOUND')"
echo "Portainer docker-compose: $(/opt/portainer/docker-compose --version 2>/dev/null || echo 'NOT FOUND')"
ls -lh /usr/local/bin/docker-compose /opt/portainer/docker-compose 2>/dev/null || true
echo "=========================="

exec /usr/local/bin/portainer "$@"
