FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y \
        php \
        php-mysql \
        php-mysqli \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php && \
    chown -R www-data:www-data /var/www/html

EXPOSE 8080

USER www-data

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
