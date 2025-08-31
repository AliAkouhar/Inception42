#!/bin/bash

mkdir -p /var/www/wordpress
cd /var/www/wordpress

wp core download --allow-root

mv wp-config-sample.php wp-config.php

sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '${MYSQL_DATABASE}' );/" wp-config.php
sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '${MYSQL_USER}' );/" wp-config.php
sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '${MYSQL_PASSWORD}' );/" wp-config.php
sed -i "s/localhost/mariadb/" wp-config.php

sleep 10

wp core install \
  --url="${DOMAIN_NAME}" \
  --title="${SITE_TITLE}" \
  --admin_user="${WP_ADMIN_USER}" \
  --admin_password="${WP_ADMIN_PASSWORD}" \
  --admin_email="${WP_ADMIN_EMAIL}" --skip-email \
  --allow-root

wp user create \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASSWORD}" \
    --role=editor \
    --allow-root

wp theme activate twentytwentyfour --allow-root

sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i \
define('WP_REDIS_CLIENT', 'phpredis');\ndefine('WP_REDIS_HOST', 'redis');\ndefine('WP_REDIS_PORT', 6379);\ndefine('WP_CACHE', true);
" wp-config.php

wp plugin install redis-cache --activate --allow-root

wp redis enable --allow-root --path=/var/www/wordpress

mkdir -p /run/php
php-fpm7.4 -F