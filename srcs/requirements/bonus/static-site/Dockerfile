FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y lighttpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY site/ /var/www/html/

RUN chown -R www-data:www-data /var/www/html

RUN mkdir -p /run/lighttpd && chown -R www-data:www-data /run/lighttpd
RUN touch /run/lighttpd.pid && chown www-data:www-data /run/lighttpd.pid

EXPOSE 80

USER www-data

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
