FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx openssl gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -f /etc/nginx/sites-available/default

RUN mkdir -p /etc/nginx/ssl && \
    chown -R www-data:www-data /etc/nginx/ssl

RUN mkdir -p /etc/nginx/templates
COPY conf/default.conf /etc/nginx/templates/default.conf.template

COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN chown -R www-data:www-data /var/www/html

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
