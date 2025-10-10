#!/bin/sh
set -eu

: "${FTP_USER:=ftpuser}"
: "${FTP_PASSWORD:=ftp_password}"

# Résous l’IP passive : FTP_PASV_ADDRESS > VM_IP > IP primaire du conteneur
if [ -n "${FTP_PASV_ADDRESS:-}" ]; then
  PASV_IP="$FTP_PASV_ADDRESS"
elif [ -n "${VM_IP:-}" ]; then
  PASV_IP="$VM_IP"
else
  PASV_IP="$(hostname -I | awk '{print $1}')"
fi
export FTP_PASV_ADDRESS="$PASV_IP"

# Création utilisateur si besoin
if ! id -u "$FTP_USER" >/dev/null 2>&1; then
  useradd -m -d "/home/${FTP_USER}" -s /usr/sbin/nologin "$FTP_USER"
fi
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

# Racine et droits
mkdir -p "/home/${FTP_USER}/wordpress"
chown -R "${FTP_USER}:${FTP_USER}" "/home/${FTP_USER}"

# Conf finale à partir du template
envsubst '${FTP_PASV_ADDRESS}' < /etc/vsftpd.conf.tmpl > /etc/vsftpd.conf

echo "✅ FTP ready: user=${FTP_USER}, home=/home/${FTP_USER}/wordpress, PASV on ${FTP_PASV_ADDRESS}"

exec /usr/sbin/vsftpd /etc/vsftpd.conf