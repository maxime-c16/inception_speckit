

FROM nginx:alpine
COPY ./site /usr/share/nginx/html
EXPOSE 8080
## Ensure runtime directories exist and are writable by the nginx user
RUN mkdir -p /run /var/cache/nginx /var/cache/nginx/client_temp \
	&& chown -R nginx:nginx /run /var/cache/nginx

USER nginx
