#!/bin/bash
set -e

DOMAIN_NAME=${DOMAIN_NAME:-macauchy.42.fr}

envsubst '$DOMAIN_NAME' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

if [ ! -f /etc/nginx/ssl/cert.pem ] || [ ! -f /etc/nginx/ssl/key.pem ]; then
    echo "Generating self-signed TLS certificate for ${DOMAIN_NAME}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out /etc/nginx/ssl/cert.pem \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Student/CN=${DOMAIN_NAME}"
    
    chown www-data:www-data /etc/nginx/ssl/cert.pem /etc/nginx/ssl/key.pem
    chmod 644 /etc/nginx/ssl/cert.pem
    chmod 600 /etc/nginx/ssl/key.pem
    
    echo "Certificate generated successfully for ${DOMAIN_NAME}!"
else
    echo "Certificate already exists."
fi

exec nginx -g 'daemon off;'
