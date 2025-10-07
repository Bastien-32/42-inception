#!/bin/sh
set -e

until mysqladmin ping -h"${MYSQL_HOST:-mariadb}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
  echo "[wp] Waiting for MariaDB construction..."
  sleep 1
done
echo "[wp] MariaDB is up."

DOCROOT=/var/www/wordpress
mkdir -p "$DOCROOT"
chown -R www-data:www-data "$DOCROOT"

# 1) Générer wp-config.php si absent
if [ ! -f "$DOCROOT/wp-config.php" ]; then
  echo "[wp] Generating wp-config.php..."
  wp config create \
    --path="$DOCROOT" \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="${MYSQL_HOST:-mariadb}" \
    --dbprefix=wp_ \
    --allow-root
fi

# 2) Installer le site si pas encore installé
if ! wp core is-installed --path="$DOCROOT" --allow-root >/dev/null 2>&1; then
  echo "[wp] Running wp core install..."
  wp core install \
    --path="$DOCROOT" \
    --url="${WP_DOMAIN_NAME}" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
fi

# 3) installer un autre Utilisateur
if ! wp user get "$WP_USER_LOGIN" --path="$DOCROOT" --allow-root >/dev/null 2>&1; then
  wp user create "$WP_USER_LOGIN" "$WP_USER_EMAIL" \
	--path="$DOCROOT" \
	--user_pass="$WP_USER_PASSWORD" \
	--role=author \
	--allow-root
fi

# 4) Plugin Redis + activation du cache
# (Active le plugin Redis et nettoie le cache proprement)
wp --path="$DOCROOT" plugin install redis-cache --activate --allow-root || true
wp --path="$DOCROOT" redis enable --allow-root || true

# Purge le cache si la commande existe (flush-cache ou cache flush)
if wp --path="$DOCROOT" help redis 2>/dev/null | grep -q 'flush-cache'; then
  wp --path="$DOCROOT" redis flush-cache --allow-root || true
else
  wp --path="$DOCROOT" cache flush --allow-root || true
fi

# 5) Démarrer PHP-FPM
exec /usr/sbin/php-fpm8.2 -F