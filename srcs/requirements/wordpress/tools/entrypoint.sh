#!/bin/sh
set -e

: "${WORDPRESS_DB_NAME:?missing}"
: "${WORDPRESS_DB_USER:?missing}"
: "${WORDPRESS_DB_PASSWORD:?missing}"
: "${WORDPRESS_DB_HOST:=mariadb}"

DOCROOT=/var/www/html
SRC=/usr/src/wordpress-src
WPCFG="$DOCROOT/wp-config.php"

# 1) Si le volume est vide, copie WordPress depuis l'image
if [ ! -f "$DOCROOT/wp-load.php" ]; then
  mkdir -p "$DOCROOT"
  cp -a "$SRC/." "$DOCROOT/"
  chown -R www-data:www-data "$DOCROOT"
fi

# 2) Génère wp-config.php si absent
if [ ! -f "$WPCFG" ]; then
  cp "$DOCROOT/wp-config-sample.php" "$WPCFG"
  sed -ri "s/database_name_here/${WORDPRESS_DB_NAME}/" "$WPCFG"
  sed -ri "s/username_here/${WORDPRESS_DB_USER}/"     "$WPCFG"
  sed -ri "s/password_here/${WORDPRESS_DB_PASSWORD}/" "$WPCFG"
  sed -ri "s/localhost/${WORDPRESS_DB_HOST}/"         "$WPCFG"

  # Salts aléatoires
  for K in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
    RAND=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' </dev/urandom | head -c 64 || true)
    sed -ri "s/define\('$K',\s*'put your unique phrase here'\);/define('$K', '$RAND');/" "$WPCFG"
  done

  chown -R www-data:www-data "$DOCROOT"
fi

# 3) Démarrer PHP-FPM (détecte le bon binaire : php-fpm ou php-fpm8.x)
if command -v php-fpm >/dev/null 2>&1; then
  BIN=php-fpm
else
  BIN=$(ls /usr/sbin/php-fpm* 2>/dev/null | head -n1)
fi
exec "$BIN" -F