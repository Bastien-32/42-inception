#!/bin/sh
set -e

SSL_DIR=/etc/nginx/ssl

mkdir -p "$SSL_DIR"

# Cert auto-signé si absent (SAN = WP_DOMAIN_NAME)
if [ ! -f "$SSL_DIR/server.crt" ] || [ ! -f "$SSL_DIR/server.key" ]; then
  echo "[nginx] Generating self-signed certificate for ${WP_DOMAIN_NAME}…"
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/server.key" \
    -out    "$SSL_DIR/server.crt" \
    -subj "/C=FR/ST=Occitanie/L=Perpignan/O=42/OU=42/CN=${WP_DOMAIN_NAME}" \
    -addext "subjectAltName=DNS:${WP_DOMAIN_NAME}"
fi

nginx -t

exec nginx -g 'daemon off;'