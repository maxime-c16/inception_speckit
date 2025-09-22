#!/bin/sh
# T013: Integration test for static site
set -e
docker-compose up -d static
sleep 5
curl -s http://localhost:8080/ | grep -qi 'Static Site' || { echo 'Static site not served'; exit 1; }
echo 'Static site test passed.'
