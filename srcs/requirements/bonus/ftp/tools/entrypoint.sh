#!/bin/sh
set -e

: "${FTP_USER:=ftpuser}"
: "${FTP_PASSWORD:=ftp_password}"

# Crée l'utilisateur s'il n'existe pas
if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  useradd -m -d "/home/${FTP_USER}" -s /usr/sbin/nologin "$FTP_USER"
fi

# Applique le mot de passe
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

# Force la création du répertoire wordpress après montage du volume
# (important car Docker monte le volume APRÈS la création initiale)
if [ ! -d "/home/${FTP_USER}/wordpress" ]; then
  mkdir -p "/home/${FTP_USER}/wordpress"
fi

# Assure les droits corrects
chown -R "${FTP_USER}:${FTP_USER}" "/home/${FTP_USER}"

echo "✅ FTP ready: user=${FTP_USER}, home=/home/${FTP_USER}/wordpress"

exec /usr/sbin/vsftpd /etc/vsftpd.conf