#!/bin/sh
set -e

: "${WP_DOMAIN_NAME:=localhost}"

# Génération du certificat si absent
if [ ! -f /etc/nginx/ssl/server.crt ] || [ ! -f /etc/nginx/ssl/server.key ]; then
  echo "[nginx] Generating self-signed certificate for ${WP_DOMAIN_NAME}..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=FR/ST=Occitanie/L=Perpignan/OU=42/O=42/CN=${WP_DOMAIN_NAME}"
  chmod 600 /etc/nginx/ssl/server.key
fi

# Substituer la variable ${WP_DOMAIN_NAME} dans la conf
sed "s|\${WP_DOMAIN_NAME}|${WP_DOMAIN_NAME}|g" \
  /etc/nginx/templates/nginx.conf.template \
  > /etc/nginx/conf.d/default.conf

nginx -t   # tester la conf
exec nginx -g 'daemon off;'