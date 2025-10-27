#!/bin/sh
set -e

until mysqladmin ping -h"${MYSQL_HOST:-mariadb}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
  echo "[wp] Waiting for MariaDB construction..."
  sleep 1
done
echo "[wp] MariaDB is up."

# 1) Générer wp-config.php si absent
if [ ! -f wp-config.php ]; then
  echo "[wp] Generating wp-config.php..."
  wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="${MYSQL_HOST:-mariadb}" \
    --dbprefix=wp_ \
    --allow-root
fi

# 2) Installer le site si pas encore installé
if ! wp core is-installed --allow-root >/dev/null 2>&1; then
  echo "[wp] Running wp core install..."
  wp core install \
    --url="${WP_DOMAIN_NAME}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
  echo "[wp] Forcing HTTPS for siteurl and home..."
  wp option update siteurl "https://${WP_DOMAIN_NAME}" --allow-root || true
  wp option update home "https://${WP_DOMAIN_NAME}" --allow-root || true
fi

# 3) installer un autre Utilisateur
if ! wp user get "$WP_USER_LOGIN" --allow-root >/dev/null 2>&1; then
  wp user create "$WP_USER_LOGIN" "$WP_USER_EMAIL" \
	--user_pass="$WP_USER_PASSWORD" \
	--role=author \
	--allow-root
fi

# 4) Redis: config constants + plugin + drop-in
# Plugin + drop-in
wp plugin install redis-cache --activate --allow-root || true
wp redis enable --force --allow-root || true

# Purge propre
wp redis flush --allow-root || wp cache flush --allow-root || true

# 5) Démarrer PHP-FPM
exec /usr/sbin/php-fpm8.2 -F