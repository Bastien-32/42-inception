#!/bin/sh
set -e

# SQL d'init depuis .env
cat > /tmp/init.sql <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Si le datadir du volume est vide, on l'initialise
if [ ! -d /var/lib/mysql/mysql ]; then
  echo "[init] Initializing datadir..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
fi

# Démarre MariaDB sous l'utilisateur mysql
exec mysqld --user=mysql --init-file=/tmp/init.sql