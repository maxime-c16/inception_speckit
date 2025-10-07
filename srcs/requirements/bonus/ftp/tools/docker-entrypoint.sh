#!/bin/bash
set -e

# Create FTP user if it doesn't exist
if ! id -u ${FTP_USER} > /dev/null 2>&1; then
    useradd -m -d /home/${FTP_USER} -s /bin/bash ${FTP_USER}
    echo "${FTP_USER}:${FTP_PASS}" | chpasswd
fi

# Configure vsftpd
cat > /etc/vsftpd.conf <<EOF
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
allow_writeable_chroot=YES
user_sub_token=\$USER
local_root=/home/\$USER
EOF

# Create necessary directories
mkdir -p /var/run/vsftpd/empty

# Start vsftpd
exec /usr/sbin/vsftpd /etc/vsftpd.conf
