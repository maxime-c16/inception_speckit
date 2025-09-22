#!/bin/sh
# T009: Integration test for NGINX TLS and proxy
set -e
docker-compose up -d nginx wordpress static
sleep 10
echo | openssl s_client -connect localhost:443 -servername login.42.fr 2>/dev/null | grep -q 'BEGIN CERTIFICATE' || { echo 'TLS not enabled on 443'; exit 1; }
curl -k https://localhost/ | grep -qi 'wordpress' || { echo 'WordPress not proxied by NGINX'; exit 1; }
curl -k https://localhost/static/ | grep -qi 'Static Site' || { echo 'Static site not proxied by NGINX'; exit 1; }
echo 'NGINX TLS and proxy test passed.'
