
FROM nginx:alpine
COPY ./conf /etc/nginx/conf.d
EXPOSE 443
## Ensure runtime directories exist and are writable by the nginx user
RUN mkdir -p /run /var/cache/nginx /var/cache/nginx/client_temp \
	&& chown -R nginx:nginx /run /var/cache/nginx

# Ensure certificate and key have safe permissions (key only readable by owner)
RUN if [ -f /etc/nginx/conf.d/cert.pem ]; then chmod 644 /etc/nginx/conf.d/cert.pem; fi \
	&& if [ -f /etc/nginx/conf.d/key.pem ]; then chmod 600 /etc/nginx/conf.d/key.pem; fi

USER nginx
