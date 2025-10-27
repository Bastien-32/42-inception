#!/bin/sh
set -eu

if ! id -u "$FTP_USER" >/dev/null 2>&1; then
    useradd -m -d "/home/${FTP_USER}" -s /bin/bash "$FTP_USER"
fi

echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

mkdir -p "/home/${FTP_USER}/wordpress"
chown -R "${FTP_USER}:${FTP_USER}" "/home/${FTP_USER}"

sed -i "s|^pasv_address=.*|pasv_address=${FTP_PASV_ADDRESS}|" /etc/vsftpd.conf

exec /usr/sbin/vsftpd /etc/vsftpd.conf