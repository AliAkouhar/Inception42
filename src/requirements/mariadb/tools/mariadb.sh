#!/bin/bash
echo "[INFO] Ensuring database and user exist..."

# Start MariaDB in the background
mysqld_safe --skip-networking &
sleep 10

# Create DB and user (idempotent)
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Shut down temporary instance
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Start MariaDB normally
exec mysqld_safe