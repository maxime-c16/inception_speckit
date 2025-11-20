FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /home/ftpuser

EXPOSE 21 21000-21010

CMD ["/usr/local/bin/docker-entrypoint.sh"]
