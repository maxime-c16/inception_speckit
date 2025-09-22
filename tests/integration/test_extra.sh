#!/bin/sh
# T015: Integration test for extra service
set -e
docker-compose up -d extra
sleep 5
docker-compose ps | grep -q extra || { echo 'Extra service not running'; exit 1; }
echo 'Extra service test passed.'
