#!/bin/sh

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	/usr/bin/mariadbd --user=mysql --skip-networking &
	pid=$!

	until mysqladmin ping --silent; do
		sleep 1
	done

	mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
CREATE DATABASE IF NOT EXISTS $(cat /run/secrets/db_name);
CREATE USER IF NOT EXISTS '$(cat /run/secrets/db_user)'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
GRANT ALL PRIVILEGES ON $(cat /run/secrets/db_name).* TO '$(cat /run/secrets/db_user)'@'%';
FLUSH PRIVILEGES;
EOF

	mysqladmin -u root -p"$(cat /run/secrets/db_root_password)" shutdown
	wait $pid
fi

exec "$@"
