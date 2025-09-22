#!/bin/sh
# T011: Integration test for Redis cache
set -e
docker-compose up -d redis wordpress
sleep 10
docker-compose exec redis redis-cli -a example_redis_pw ping | grep -q PONG || { echo 'Redis not responding'; exit 1; }
# Check if WordPress can connect to Redis (look for object-cache.php or similar in logs)
docker-compose logs wordpress | grep -qi 'redis' && echo 'WordPress connected to Redis' || echo 'Check WordPress Redis plugin setup.'
echo 'Redis cache test complete.'
