#!/bin/sh
# T014: Integration test for Adminer
set -e
docker-compose up -d adminer
sleep 5
curl -s http://localhost:8081/ | grep -qi 'Adminer' || { echo 'Adminer not running'; exit 1; }
echo 'Adminer test passed.'
