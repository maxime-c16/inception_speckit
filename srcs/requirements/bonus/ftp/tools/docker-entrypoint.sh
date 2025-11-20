#!/bin/bash
set -e

if ! id -u "${FTP_USER}" > /dev/null 2>&1; then
    useradd -m -d "/home/${FTP_USER}" -s /bin/bash "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASS}" | chpasswd
fi

mkdir -p "/home/${FTP_USER}/wordpress"
chown -R "${FTP_USER}:${FTP_USER}" "/home/${FTP_USER}"

mkdir -p /var/run/vsftpd/empty

exec /usr/sbin/vsftpd /etc/vsftpd.conf
