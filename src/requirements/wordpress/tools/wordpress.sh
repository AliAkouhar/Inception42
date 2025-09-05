# #!/bin/bash

# mkdir -p /var/www/wordpress
# cd /var/www/wordpress

# wp core download --allow-root

# cp wp-config-sample.php wp-config.php

# sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '${MYSQL_DATABASE}' );/" wp-config.php
# sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '${MYSQL_USER}' );/" wp-config.php
# sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '${MYSQL_PASSWORD}' );/" wp-config.php
# sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'mariadb' );/" wp-config.php

# sleep 10

# wp core install \
#   --url="${DOMAIN_NAME}" \
#   --title="${SITE_TITLE}" \
#   --admin_user="${WP_ADMIN_USER}" \
#   --admin_password="${WP_ADMIN_PASSWORD}" \
#   --admin_email="${WP_ADMIN_EMAIL}" --skip-email \
#   --allow-root

# wp user create \
#     "${WP_USER}" "${WP_USER_EMAIL}" \
#     --user_pass="${WP_USER_PASSWORD}" \
#     --role=editor \
#     --allow-root

# wp theme activate twentytwentyfour --allow-root

# mkdir -p /run/php
# php-fpm7.4 -F
#!/bin/bash

# Ensure WordPress root directory exists
mkdir -p /var/www/wordpress
cd /var/www/wordpress

# --- WordPress installation block ---
# Run only if wp-config.php does not exist (first-time setup)
if [ ! -f wp-config.php ]; then
    echo "[INFO] Fresh WordPress setup..."

    # Download WordPress core files
    wp core download --allow-root

    # Copy default config and replace DB credentials with environment variables
    cp wp-config-sample.php wp-config.php
    sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '${MYSQL_DATABASE}' );/" wp-config.php
    sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '${MYSQL_USER}' );/" wp-config.php
    sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '${MYSQL_PASSWORD}' );/" wp-config.php
    sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'mariadb' );/" wp-config.php

    # Give MariaDB some time to initialize
    sleep 10

    # Install WordPress with admin user
    wp core install \
      --url="${DOMAIN_NAME}" \
      --title="${SITE_TITLE}" \
      --admin_user="${WP_ADMIN_USER}" \
      --admin_password="${WP_ADMIN_PASSWORD}" \
      --admin_email="${WP_ADMIN_EMAIL}" --skip-email \
      --allow-root

    # Create an extra editor user (only if it does not already exist)
    if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1; then
        wp user create \
          "${WP_USER}" "${WP_USER_EMAIL}" \
          --user_pass="${WP_USER_PASSWORD}" \
          --role=editor \
          --allow-root
    else
        echo "[INFO] User ${WP_USER} already exists, skipping creation."
    fi

    # Activate default theme (idempotent – no error if already active)
    wp theme activate twentytwentyfour --allow-root
else
    echo "[INFO] WordPress already installed, skipping setup."
fi

# Ensure PHP-FPM socket directory exists and start service
mkdir -p /run/php
php-fpm7.4 -F
